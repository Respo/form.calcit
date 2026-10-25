import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {readFileSync,writeFileSync,mkdirSync,readdirSync,statSync} from 'node:fs';
import {createHash} from 'node:crypto';
assert.equal(process.env.GITHUB_ACTIONS,'true');assert.equal(process.platform,'linux');
const run=(exe,args)=>execFileSync(exe,args,{encoding:'utf8',maxBuffer:64e6,stdio:['pipe','pipe','pipe']});
assert.equal(run('calcit',['-v']).trim(),'0.30.1');
const norm=v=>Array.isArray(v)?v.map(norm):v&&typeof v==='object'?Object.fromEntries(Object.entries(v).map(([k,x])=>[k,k==='__edn_set'?x.map(norm).sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b))):k==='schema'&&Array.isArray(x)&&x[0]==='{}'?['{}',...x.slice(1).map(norm).sort((a,b)=>a[0].localeCompare(b[0]))]:norm(x)])):v;
const q=(...args)=>{const r=JSON.parse(run('calcit',['query',...args,'--format','json']));assert.deepEqual(r.diagnostics||[],[]);return norm(r.data);};
const p=JSON.parse(readFileSync('reviewed-source.json')),expected=structuredClone(p.before);assert.equal(p.sites.length,2);assert.equal(p.before.defs.length,40);
for(const s of p.sites){let n=expected.defs.find(d=>d.id===s.definition).code;for(const i of s.path.split('.').map(Number))n=n[i];assert.deepEqual(n,s.before);n[0]='.merge';}
const views=()=>{const namespaces=[],defs=[];for(const ns of q('ns').namespaces){const info=q('ns',ns);namespaces.push(info);const names=run('calcit',['query','defs',ns]).split('\n').filter(x=>/^  \S/.test(x)).map(x=>x.trim().split(' ')[0]);assert.equal(names.length,info.definition_count);for(const n of names)defs.push(q('def',ns+'/'+n));}return {config:q('config'),namespaces,defs};};
const blob=()=>run('git',['hash-object','calcit.cirru']).trim();
const guard=()=>{for(const[f,h]of Object.entries(p.ordinaryBlobs))assert.equal(run('git',['hash-object',f]).trim(),h,f);};
mkdirSync('acceptance',{recursive:true});const mode=process.argv[2],phase=process.argv[3];
if(mode==='before'){
 assert.equal(blob(),p.blob);assert.deepEqual(views(),norm(p.before));guard();
 assert.ok(!p.before.defs.some(d=>d.id.endsWith('/merge')));assert.ok(!JSON.stringify(p.before.namespaces).includes('"merge"'));
 for(const[i,s]of p.sites.entries()){
  const show=JSON.parse(run('calcit',['tree','show',s.definition,'--path','@'+s.path,'--format','json']));assert.deepEqual(show.tree,s.before);writeFileSync('acceptance/tree-'+i+'.json',JSON.stringify(show));
  const t=JSON.parse(run('calcit',['query','type-at',s.definition,'--path','@'+s.path+'.1','--format','json']));writeFileSync('acceptance/type-'+i+'.json',JSON.stringify(t));assert.deepEqual(t.diagnostics,[]);assert.equal(t.data.inferred_type,":: 'Map 'Tag 'Dynamic");const m=t.data.static_methods.find(m=>m.name==='.merge');assert.equal(m.status,'open');assert.equal(m.definition,'calcit.core/merge');assert.equal(m.rest_type,'map<tag, dynamic>');assert.equal(m.return_type,'map<tag, dynamic>');
 }
 writeFileSync('acceptance/merge-producer.json',JSON.stringify(q('def','calcit.core/merge')));writeFileSync('acceptance/before-source.json',JSON.stringify(views()));
}else if(mode==='apply'){
 assert.equal(blob(),p.blob);assert.deepEqual(views(),norm(p.before));guard();
 const operations=p.sites.map(s=>['tree','replace',s.definition,'--path','@'+s.path+'.0','--input-format','json-ast','--code',JSON.stringify('.merge')]);writeFileSync('acceptance/operations.json',JSON.stringify(operations));
 const args=['edit','transaction','--file','acceptance/operations.json','--format','json'],preview=JSON.parse(run('calcit',[...args,'--dry-run']));assert.ok(preview.scoped_revision);assert.equal(blob(),p.blob);writeFileSync('acceptance/preview.json',JSON.stringify(preview));writeFileSync('acceptance/applied.json',run('calcit',[...args,'--expect-revision',preview.scoped_revision]));assert.deepEqual(views(),norm(expected));guard();writeFileSync('acceptance/expected-source.json',JSON.stringify(norm(expected)));writeFileSync('acceptance/modified-blob.txt',blob());
}else if(mode==='after'){
 assert.deepEqual(views(),norm(expected));guard();assert.equal(blob(),readFileSync('acceptance/modified-blob.txt','utf8'));writeFileSync('acceptance/after-source.json',JSON.stringify(views()));
}else if(mode==='gates'){
 assert.ok(['before','after'].includes(phase));const source=blob(),log=(name,args)=>{try{writeFileSync('acceptance/'+phase+'-'+name,run('calcit',args));}catch(e){writeFileSync('acceptance/'+phase+'-'+name,e.stdout||'');writeFileSync('acceptance/'+phase+'-'+name+'.stderr',e.stderr||'');throw e;}};
 const canonical=JSON.parse(run('calcit',['edit','transaction','--code','[["edit","format"]]','--dry-run','--format','json']));assert.equal(canonical.changed,false);writeFileSync('acceptance/'+phase+'-canonical.json',JSON.stringify(canonical));
 log('strict.json',['fix','--workflow','strict','--verify','--format','json']);const strict=JSON.parse(readFileSync('acceptance/'+phase+'-strict.json'));assert.equal(strict.data.workflow.status,'passed');assert.deepEqual(strict.diagnostics,[]);
 log('all.json',['--check-only','--all-defs','--format','json']);log('own.json',['--check-only',...p.before.namespaces.filter(n=>n.definition_count>0).flatMap(n=>['--ns',n.namespace]),'--summary-only','--format','json']);
 for(const[k,field]of [['unsafe-coerce','hits'],['dynamic-method','findings'],['deprecated-call','calls']]){log(k+'.json',['analyze','weak-types','--only',k,'--summary-only','--format','json']);assert.equal(JSON.parse(readFileSync('acceptance/'+phase+'-'+k+'.json')).data.summary[field],0);}
 log('docs.log',['docs','check-md','README.md','--snapshot','calcit.cirru','--failures-only']);log('compile.log',['js']);
 process.env.VITE_BASE_URL='./';writeFileSync('acceptance/'+phase+'-build.log',run('yarn',['vite','build','--base=./']));writeFileSync('acceptance/'+phase+'-tests.tap',run('node',['--test','scripts/form-regression.test.mjs']));
 const files=[];function visit(dir){for(const n of readdirSync(dir).sort()){const f=dir+'/'+n;if(statSync(f).isDirectory())visit(f);else if(f.endsWith('.mjs'))files.push({path:f,sha256:createHash('sha256').update(readFileSync(f)).digest('hex')});}}visit('js-out');writeFileSync('acceptance/'+phase+'-js.json',JSON.stringify(files));
 if(phase==='after')assert.deepEqual(files,JSON.parse(readFileSync('acceptance/before-js.json')),'Map method migration must preserve all generated module bytes');
 guard();assert.equal(blob(),source);
}else throw Error('unsupported mode');
