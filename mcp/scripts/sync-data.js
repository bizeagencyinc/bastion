// Copies the Bastion rule data from the repo root into mcp/data so the npm package is self-contained.
// Runs automatically on `npm pack` / `npm publish` (prepack).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const mcpDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const repo = path.resolve(mcpDir, '..');
const out = path.join(mcpDir, 'data');

const items = ['BASTION.md', 'rules', 'templates', 'integrations/commands'];

fs.rmSync(out, { recursive: true, force: true });
for (const item of items) {
  const src = path.join(repo, item);
  const dst = path.join(out, item);
  if (!fs.existsSync(src)) throw new Error(`Missing ${src}`);
  fs.mkdirSync(path.dirname(dst), { recursive: true });
  fs.cpSync(src, dst, { recursive: true });
}
for (const f of ['LICENSE']) fs.copyFileSync(path.join(repo, f), path.join(mcpDir, f));
console.log(`Bastion data synced to ${path.relative(repo, out)}/`);
