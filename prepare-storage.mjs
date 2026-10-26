import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {readFileSync,writeFileSync,mkdirSync,copyFileSync,cpSync,readdirSync,statSync} from 'node:fs';
import {createHash} from 'node:crypto';
assert.equal(process.env.GITHUB_ACTIONS,'true');assert.equal(process.platform,'linux');
const run=(exe,args)=>execFileSync(exe,args,{encoding:'utf8',maxBuffer:64e6,stdio:['ignore','pipe','pipe']});
assert.equal(run('calcit',['-v']).trim(),'0.30.1');run('calcit',['docs','agents','--contract']);
function schema(v){if(!Array.isArray(v))return v;if(v[0]==='{}')return ['{}',...v.slice(1).sort((a,b)=>a[0].localeCompare(b[0]))];if(v[0]==='::'&&["'Fn",':fn'].includes(v[1]))return [v[0],v[1],schema(v[2])];return v;}
const norm=v=>Array.isArray(v)?v.map(norm):v&&typeof v==='object'?Object.fromEntries(Object.entries(v).map(([k,x])=>[k,k==='__edn_set'?x.map(norm).sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b))):k==='schema'?schema(norm(x)):norm(x)])):v;
const q=(...args)=>{const r=JSON.parse(run('calcit',['query',...args,'--format','json']));assert.deepEqual(r.diagnostics||[],[]);return norm(r.data);};
const typeTree=v=>Array.isArray(v)?v[0]==='{}'?['{}',...v.slice(1).map(typeTree).sort((a,b)=>a[0].localeCompare(b[0]))]:v.map(typeTree):v;
const p=JSON.parse(readFileSync('reviewed-source.json'));assert.equal(p.operations.length,2);assert.equal(p.before.defs.length,40);
const blob=()=>run('git',['hash-object','calcit.cirru']).trim(),guard=()=>{for(const[f,h]of Object.entries(p.ordinaryBlobs))assert.equal(run('git',['hash-object',f]).trim(),h,f);};
const views=()=>{const namespaces=[],defs=[];for(const ns of q('ns').namespaces){const info=q('ns',ns);namespaces.push(info);const names=run('calcit',['query','defs',ns]).split('\n').filter(x=>/^  \S/.test(x)).map(x=>x.trim().split(' ')[0]);assert.equal(names.length,info.definition_count);for(const n of names)defs.push(q('def',ns+'/'+n));}return {config:q('config'),namespaces,defs};};
mkdirSync('acceptance',{recursive:true});assert.equal(blob(),p.blob);guard();
writeFileSync('acceptance/operations.json',JSON.stringify(p.operations));const args=['edit','transaction','--file','acceptance/operations.json','--format','json'];
const preview=JSON.parse(run('calcit',[...args,'--dry-run']));assert.ok(preview.scoped_revision);assert.equal(blob(),p.blob);writeFileSync('acceptance/preview.json',JSON.stringify(preview));
const before=views();assert.deepEqual(before,norm(p.before));writeFileSync('acceptance/before-source.json',JSON.stringify(before));
const beforeSchema=q('schema','form.main/main!');assert.deepEqual(typeTree(beforeSchema.tree),typeTree(p.schemaInput));writeFileSync('acceptance/before-schema.json',JSON.stringify(beforeSchema));
function gate(phase){
  const original=blob(),log=(name,args)=>{try{const text=run('calcit',args);writeFileSync('acceptance/'+phase+'-'+name,text);return text;}catch(e){writeFileSync('acceptance/'+phase+'-'+name,e.stdout||'');writeFileSync('acceptance/'+phase+'-'+name+'.stderr',e.stderr||'');throw e;}};
  const canonical=JSON.parse(log('canonical.json',['edit','transaction','--code','[["edit","format"]]','--dry-run','--format','json']));assert.equal(canonical.changed,false);
  const strict=JSON.parse(log('strict.json',['fix','--workflow','strict','--verify','--format','json']));assert.equal(strict.data.workflow.status,'passed');assert.deepEqual(strict.diagnostics,[]);
  log('all.json',['--check-only','--all-defs','--format','json']);log('own.json',['--check-only',...p.before.namespaces.filter(n=>n.definition_count>0).flatMap(n=>['--ns',n.namespace]),'--summary-only','--format','json']);
  for(const[k,field]of [['unsafe-coerce','hits'],['dynamic-method','findings'],['deprecated-call','calls']])assert.equal(JSON.parse(log(k+'.json',['analyze','weak-types','--only',k,'--summary-only','--format','json'])).data.summary[field],0);
  log('docs.log',['docs','check-md','README.md','--snapshot','calcit.cirru','--failures-only']);log('compile.log',['js']);
  writeFileSync('acceptance/'+phase+'-build.log',run('yarn',['vite','build','--base=./']));writeFileSync('acceptance/'+phase+'-tests.log',run('node',['--test','scripts/form-regression.test.mjs']));
  const files=[];function visit(dir){for(const n of readdirSync(dir).sort()){const f=dir+'/'+n;if(statSync(f).isDirectory())visit(f);else if(f.endsWith('.mjs'))files.push({path:f,sha256:createHash('sha256').update(readFileSync(f)).digest('hex')});}}visit('js-out');writeFileSync('acceptance/'+phase+'-js.json',JSON.stringify(files));
  if(phase==='after'){const old=JSON.parse(readFileSync('acceptance/before-js.json'));assert.deepEqual(files.map(f=>f.path),old.map(f=>f.path));const changed=files.filter((f,i)=>f.sha256!==old[i].sha256).map(f=>f.path);assert.deepEqual(changed,['js-out/form.main.mjs']);writeFileSync('acceptance/changed-js.json',JSON.stringify(changed));}
  mkdirSync('runtime/'+phase,{recursive:true});cpSync('dist','runtime/'+phase+'/dist',{recursive:true});guard();assert.equal(blob(),original);
}
gate('before');assert.equal(blob(),p.blob);assert.deepEqual(views(),norm(p.before));guard();
writeFileSync('acceptance/applied.json',run('calcit',[...args,'--expect-revision',preview.scoped_revision]));
const afterSchema=q('schema','form.main/main!');assert.deepEqual(typeTree(afterSchema.tree),typeTree(p.schemaInput));writeFileSync('acceptance/after-schema.json',JSON.stringify(afterSchema));
const after=views();writeFileSync('acceptance/after-source.json',JSON.stringify(after));assert.deepEqual(after,norm(p.expected));guard();
gate('after');assert.deepEqual(views(),norm(p.expected));guard();
writeFileSync('acceptance/summary.json',JSON.stringify({repo:p.repo,base:p.base,beforeBlob:p.blob,afterBlob:blob(),definitions:40,namespaces:8,changedDefinitions:1,operations:2,originalNodeTestsBeforeAndAfter:8,nativeAttachedTests:0,ordinaryFilesPreserved:Object.keys(p.ordinaryBlobs).length,limits:'No application startup/browser/storage operation; full bad-archive/startup/60second/unload/refresh acceptance still requires separate isolated test authorization. No COS/deploy/release or schema/unsafe budget relaxation.'}));
mkdirSync('prepared-source',{recursive:true});copyFileSync('calcit.cirru','prepared-source/calcit.cirru');
