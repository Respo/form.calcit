import assert from 'node:assert/strict';
import test from 'node:test';
import * as clt from '../js-out/calcit.core.mjs';
import { use_form, form_plugin_get, form_plugin_render, form_plugin_reset, render_input, render_select_popup } from '../js-out/form.core.mjs';
import { form_items, comp_container } from '../js-out/form.comp.container.mjs';
import { store } from '../js-out/form.schema.mjs';
import { decode_store } from '../js-out/form.types.mjs';
import { updater } from '../js-out/form.updater.mjs';
import { new_reel, record_op } from '../js-out/reel.typed.mjs';
import { make_string } from '../js-out/respo.render.html.mjs';
import { component_$q_, component_tree } from '../js-out/respo.util.detect.mjs';

const t = clt.init_tags(['cursor', 'data', 'states', 'name', 'place', 'value', 'event', 'input', 'click', 'tree', 'children', 'some', 'none', 'custom', 'form-example', 'items']);
const map = clt._$n__$M_;
const list = clt._$L_;
const nth = (value, index) => clt.option_$o_unwrap(clt.nth(value, index));
const field = (value, key) => clt.option_$o_unwrap(clt.get(value, key));
const cursor = list('form-test');
const states = (data) => data === undefined ? map(t.cursor, cursor) : map(t.cursor, cursor, t.data, data);

function findEvent(node, tag, accept = () => true) {
  if (component_$q_(node)) {
    const tree = component_tree(node);
    if (clt._$n_enum_$o_nth(tree, 0) === t.some) return findEvent(clt.option_$o_unwrap(tree), tag, accept);
    return;
  }
  const events = clt.get(node, t.event);
  if (clt._$n_enum_$o_nth(events, 0) === t.some) {
    const event = clt.get(clt.option_$o_unwrap(events), tag);
    if (clt._$n_enum_$o_nth(event, 0) === t.some && accept(node)) return clt.option_$o_unwrap(event);
  }
  const tree = clt.get(node, t.tree);
  if (clt._$n_enum_$o_nth(tree, 0) === t.some) return findEvent(clt.option_$o_unwrap(tree), tag, accept);
  const children = clt.get(node, t.children);
  if (clt._$n_enum_$o_nth(children, 0) === t.some) {
    const childNodes = clt.option_$o_unwrap(children);
    const pairs = clt.list_$q_(childNodes) ? childNodes : clt.to_pairs(childNodes);
    for (let i = 0; i < clt.count(pairs); i++) {
      const found = findEvent(nth(nth(pairs, i), 1), tag, accept);
      if (found) return found;
    }
  }
}

test('form plugin reads persisted state and renders all item types', () => {
  const plugin = use_form(states(map(t.name, 'Alice')), form_items);
  assert.equal(field(form_plugin_get(plugin), t.name), 'Alice');
  const html = make_string(form_plugin_render(plugin));
  for (const label of ['Name', 'Place', 'Kind', 'Counter', 'Nothing selected']) assert.match(html, new RegExp(label));
});

test('input callback extracts text from the Respo event', () => {
  const input = render_input('', nth(form_items, 0), (_dispatch, pairs) => {
    assert.equal(field(pairs, t.name), t.name);
    assert.equal(field(pairs, t.value), 'Alice');
  });
  field(field(input, t.event), t.input)(map(t.value, 'Alice'), () => {});
});

test('form edits dispatch one states Enum keyed by the actual field name', () => {
  const plugin = use_form(states(map(t.place, 'Shanghai')), list(nth(form_items, 0)));
  const callback = findEvent(form_plugin_render(plugin), t.input);
  assert.equal(typeof callback, 'function');
  callback(map(t.value, 'Alice'), (...args) => {
    assert.equal(args.length, 1);
    const op = args[0];
    assert.equal(clt._$n_enum_$o_nth(op, 0), t.states);
    const data = clt._$n_enum_$o_nth(op, 2);
    assert.equal(field(data, t.name), 'Alice');
    assert.equal(field(data, t.place), 'Shanghai');
    assert.equal(clt._$n_enum_$o_nth(clt.get(data, t.value), 0), t.none);
    assert.doesNotThrow(() => updater(store, op, 'test-op', 1));
  });
});

test('custom renderer increments its own field through the same dispatcher', () => {
  const plugin = use_form(states(map(t.custom, 3)), list(nth(form_items, 3)));
  findEvent(form_plugin_render(plugin), t.click)(null, (op) => {
    assert.equal(field(clt._$n_enum_$o_nth(op, 2), t.custom), 4);
  });
});

test('state operations survive updater and typed Reel replay into the rendered form', () => {
  const inputStates = map(t.cursor, list(t['form-example'], t.items));
  const plugin = use_form(inputStates, list(nth(form_items, 0)));
  let reel = new_reel(store);
  findEvent(form_plugin_render(plugin), t.input)(map(t.value, 'Alice'), (op) => {
    reel = record_op(updater, reel, op, 'input-op', 1);
  });
  assert.match(make_string(comp_container(reel)), /Alice/);
});

test('reset supports omitted and explicit Option data without changing cursor', () => {
  const plugin = use_form(states(map(t.name, 'Alice')), form_items);
  for (const data of [undefined, clt._PCT__$o__$o_(clt.Option, t.some, map(t.name, 'Bob'))]) {
    let op;
    const capture = (...args) => { assert.equal(args.length, 1); op = args[0]; };
    if (data === undefined) form_plugin_reset(plugin, capture);
    else form_plugin_reset(plugin, capture, data);
    assert.equal(clt._$n__$e_(clt._$n_enum_$o_nth(op, 1), cursor), true);
    const payload = clt._$n_enum_$o_nth(op, 2);
    if (data === undefined) assert.equal(clt.count(payload), 0);
    else assert.equal(field(payload, t.name), 'Bob');
  }
});

test('Alerts menu item Enum is normalized to persisted selection data and Clear to nil', () => {
  const menuTags = clt.init_tags(['select', 'show?', 'kind', 'a', 'display']);
  let result;
  const menu = render_select_popup(
    map(t.cursor, cursor, menuTags.select, map(t.data, map(menuTags['show?'], true))),
    cursor, clt._PCT__$o__$o_(clt.Option, t.none), nth(form_items, 2),
    (_dispatch, pairs) => { result = field(pairs, t.value); }
  );
  const choose = findEvent(menu, t.click, node => /<span[^>]*>A<\/span>/.test(make_string(node)) && !/<span[^>]*>B<\/span>/.test(make_string(node)));
  assert.equal(typeof choose, 'function');
  choose(null, () => {});
  assert.equal(field(result, t.value), menuTags.a);
  assert.equal(field(result, menuTags.display), 'A');
  const clear = findEvent(menu, t.click, node => /<span[^>]*>Clear<\/span>/.test(make_string(node)) && !/<span[^>]*>A<\/span>/.test(make_string(node)));
  assert.equal(typeof clear, 'function');
  clear(null, () => {});
  assert.equal(result, null);
});

test('typed Reel demo renders and persisted store decoder rejects malformed data', () => {
  assert.match(make_string(comp_container(new_reel(store))), /Submit/);
  assert.equal(clt._$n_enum_$o_nth(decode_store(map(t.states, map())), 0), t.some);
  for (const invalid of [null, 1, map(), map(t.states, 1)]) assert.equal(clt._$n_enum_$o_nth(decode_store(invalid), 0), t.none);
});
