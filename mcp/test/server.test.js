// End-to-end tests: start the real server over stdio and call it like an MCP client would.
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import path from 'node:path';
import fs from 'node:fs';
import os from 'node:os';
import { fileURLToPath } from 'node:url';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { loadData } from '../src/lib.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const serverPath = path.join(here, '..', 'src', 'index.js');
let client;

before(async () => {
  client = new Client({ name: 'bastion-test', version: '1.0.0' });
  await client.connect(new StdioClientTransport({ command: process.execPath, args: [serverPath], stderr: 'ignore' }));
});
after(async () => { await client?.close(); });

const callText = async (name, args = {}) => {
  const r = await client.callTool({ name, arguments: args });
  return { text: r.content.map((c) => c.text).join('\n'), isError: !!r.isError };
};

test('rule IDs are unique and counted', () => {
  const data = loadData();
  const ids = data.rules.map((r) => r.id);
  const dupes = ids.filter((id, i) => ids.indexOf(id) !== i);
  assert.deepEqual(dupes, [], `duplicate rule IDs: ${dupes.join(', ')}`);
  assert.ok(data.rules.length >= 600);
  assert.equal(data.rules.filter((r) => r.id.startsWith('RED-')).length, 12);
});

test('every tool is read-only and closed-world', async () => {
  const { tools } = await client.listTools();
  assert.ok(tools.length >= 9);
  for (const t of tools) {
    assert.equal(t.annotations?.readOnlyHint, true, `${t.name} must be read-only`);
    assert.equal(t.annotations?.openWorldHint, false, `${t.name} must not reach the network`);
  }
});

test('get core and platform rules', async () => {
  const core = await callText('bastion_get_rules', { platform: 'core' });
  assert.match(core.text, /RED-01/);
  assert.doesNotMatch(core.text, /BASTION HEADER/);
  const fin = await callText('bastion_get_rules', { platform: 'financial-banking' });
  assert.match(fin.text, /FIN-14/);
  const bad = await callText('bastion_get_rules', { platform: 'cobol' });
  assert.equal(bad.isError, true);
});

test('lookup and search', async () => {
  const r = await callText('bastion_get_rule', { id: 'BAS-next-02' });
  assert.match(r.text, /Server Action/);
  const s = await callText('bastion_search_rules', { query: 'webhook signature' });
  assert.match(s.text, /(PAY-08|API-06|FIN-44)/);
  const reds = await callText('bastion_red_lines');
  assert.equal((reds.text.match(/RED-\d\d/g) || []).length, 12);
});

test('detect stack on a fixture project', async () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'bastion-'));
  fs.writeFileSync(path.join(dir, 'package.json'), JSON.stringify({ dependencies: { next: '15', mongoose: '8', stripe: '1' } }));
  fs.writeFileSync(path.join(dir, 'next.config.js'), 'module.exports = {}');
  fs.mkdirSync(path.join(dir, 'node_modules', 'x'), { recursive: true });
  fs.writeFileSync(path.join(dir, 'node_modules', 'x', 'wp-config.php'), '');
  const r = await callText('bastion_detect_stack', { path: dir });
  assert.match(r.text, /nextjs/);
  assert.match(r.text, /nosql-databases/);
  assert.match(r.text, /payments/);
  assert.doesNotMatch(r.text, /wordpress/, 'node_modules must be ignored');
});

test('snippet review flags red lines and passes clean code', async () => {
  const key = 'AKIA' + 'A'.repeat(16);
  const bad = await callText('bastion_review_snippet', {
    code: `const k = "${key}";\ndb.query("SELECT * FROM users WHERE id = " + req.query.id);\nconst total = parseFloat(amount);`,
  });
  assert.match(bad.text, /RED-01/);
  assert.match(bad.text, /RED-04/);
  assert.match(bad.text, /FIN-10/);
  assert.doesNotMatch(bad.text, new RegExp(key), 'secrets must be redacted');
  const good = await callText('bastion_review_snippet', { code: 'const x = await db.query("SELECT 1 WHERE id = $1", [id]);' });
  assert.match(good.text, /No pattern-level issues/);
});

test('templates and checklists', async () => {
  const list = await callText('bastion_get_template');
  assert.match(list.text, /ledger-double-entry\.sql/);
  const t = await callText('bastion_get_template', { name: 'ledger' });
  assert.match(t.text, /post_journal/);
  const c = await callText('bastion_checklist', { platform: 'wordpress' });
  assert.match(c.text, /verify-checksums/);
  const dod = await callText('bastion_checklist', { platform: 'core' });
  assert.match(dod.text, /Red Lines are clear/);
});

test('prompts and resources', async () => {
  const { prompts } = await client.listPrompts();
  const names = prompts.map((p) => p.name);
  for (const n of ['secure', 'audit', 'review', 'release', 'fintech-audit', 'site-audit']) assert.ok(names.includes(n), n);
  const p = await client.getPrompt({ name: 'secure', arguments: { target: 'the payments module' } });
  assert.match(p.messages[0].content.text, /the payments module/);
  const { resources } = await client.listResources();
  assert.ok(resources.some((r) => r.uri === 'bastion://rules/core'));
  assert.ok(resources.some((r) => r.uri === 'bastion://rules/platform/nextjs'));
  const res = await client.readResource({ uri: 'bastion://rules/platform/android' });
  assert.match(res.contents[0].text, /AND-01/);
});
