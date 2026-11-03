#!/usr/bin/env node
// =====================================================================
// BASTION MCP SERVER | Security Rules for AI Coding Agents
// Transport: stdio. Read-only: no network, no shell, no file writes.
// =====================================================================
import { McpServer, ResourceTemplate } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import {
  loadData, stripChrome, findRule, searchRules, getChecklist,
  countRules, detectStack, reviewSnippet,
} from './lib.js';

const data = loadData();
const READ_ONLY = { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false };
const text = (t) => ({ content: [{ type: 'text', text: t }] });
const fail = (t) => ({ content: [{ type: 'text', text: t }], isError: true });
const platformIds = data.platforms.map((p) => p.id);

// ---------------------------------------------------------------------
// CLI flags
// ---------------------------------------------------------------------
const arg = process.argv[2];
if (arg === '--version' || arg === '-v') {
  console.log(data.version);
  process.exit(0);
}
if (arg === '--help' || arg === '-h') {
  console.log(`bastion-mcp ${data.version}
Bastion security rules as a read-only MCP server (stdio).

Usage:
  bastion-mcp              Start the MCP server on stdio
  bastion-mcp --self-test  Print rule and platform counts, then exit
  bastion-mcp --version    Print version

Add to Claude Code for all repos:
  claude mcp add --scope user bastion -- npx -y bastion-security-mcp`);
  process.exit(0);
}
if (arg === '--self-test') {
  const counts = countRules(data);
  console.log(JSON.stringify({
    version: data.version,
    dataRoot: data.root,
    rules: data.rules.length,
    platforms: data.platforms.length,
    prompts: Object.keys(data.commands).length,
    templates: Object.keys(data.templates).length,
    byFile: counts,
  }, null, 2));
  process.exit(0);
}

// ---------------------------------------------------------------------
// Server
// ---------------------------------------------------------------------
const server = new McpServer(
  { name: 'bastion', title: 'Bastion Security Rules', version: data.version },
  {
    instructions:
      'Bastion provides security rules for AI coding agents. Before writing or reviewing security-relevant code, ' +
      'call bastion_detect_stack on the project, then bastion_get_rules for "core" and each detected platform. ' +
      'Never violate the 12 Red Lines (bastion_red_lines). Cite rule IDs (for example AUTH-04) in findings and commits. ' +
      'Use the bastion prompts (secure, audit, review, release) for full workflows.',
  },
);

server.registerTool('bastion_list_platforms', {
  title: 'List Bastion platforms',
  description: 'List every Bastion platform rule file with its ID, rule count, and what it covers.',
  inputSchema: {},
  annotations: READ_ONLY,
}, async () => {
  const counts = countRules(data);
  const rows = data.platforms.map((p) => `| ${p.id} | ${counts[`rules/platforms/${p.file}`] || 0} | ${p.description} |`);
  return text([
    `Bastion v${data.version}: ${data.rules.length} rules (${counts['BASTION.md']} core).`,
    '',
    '| Platform ID | Rules | Covers |',
    '|---|---|---|',
    ...rows,
  ].join('\n'));
});

server.registerTool('bastion_get_rules', {
  title: 'Get Bastion rules',
  description: 'Get the full rule text for "core" (all projects), "lite" (compact core), or a platform ID such as nextjs, wordpress, android, financial-banking.',
  inputSchema: {
    platform: z.string().describe('"core", "lite", or a platform ID from bastion_list_platforms'),
  },
  annotations: READ_ONLY,
}, async ({ platform }) => {
  const id = platform.trim().toLowerCase();
  if (id === 'core') return text(stripChrome(data.core));
  if (id === 'lite') return text(stripChrome(data.lite));
  if (data.platformDocs[id]) return text(stripChrome(data.platformDocs[id]));
  return fail(`Unknown platform "${platform}". Valid: core, lite, ${platformIds.join(', ')}`);
});

server.registerTool('bastion_get_rule', {
  title: 'Get one Bastion rule',
  description: 'Look up a single rule by ID (for example AUTH-04, NEXT-02, FIN-14, RED-01).',
  inputSchema: { id: z.string().describe('Rule ID, with or without the BAS- prefix') },
  annotations: READ_ONLY,
}, async ({ id }) => {
  const r = findRule(data, id);
  if (!r) return fail(`Rule "${id}" not found. Use bastion_search_rules to find rules by keyword.`);
  return text(`**${r.id}** [${r.level}] ${r.text}\n\nSection: ${r.section}\nFile: ${r.file}`);
});

server.registerTool('bastion_search_rules', {
  title: 'Search Bastion rules',
  description: 'Keyword search across all rules, optionally within one platform. Example: "webhook signature", "row level security", "passkeys".',
  inputSchema: {
    query: z.string().min(2),
    platform: z.string().optional().describe('Optional platform ID, or "core"'),
    limit: z.number().int().min(1).max(50).optional(),
  },
  annotations: READ_ONLY,
}, async ({ query, platform, limit }) => {
  const hits = searchRules(data, query, { platform: platform === 'core' ? undefined : platform, limit: limit || 15 })
    .filter((r) => platform !== 'core' || r.file === 'BASTION.md');
  if (!hits.length) return text(`No rules matched "${query}".`);
  return text(hits.map((r) => `- **${r.id}** [${r.level}] ${r.text}  _(${r.file})_`).join('\n'));
});

server.registerTool('bastion_red_lines', {
  title: 'The 12 Red Lines',
  description: 'Return the 12 non-negotiable Bastion Red Lines that block any release.',
  inputSchema: {},
  annotations: READ_ONLY,
}, async () => {
  const reds = data.rules.filter((r) => r.id.startsWith('RED-'));
  return text(reds.map((r) => `- **${r.id}** ${r.text}`).join('\n'));
});

server.registerTool('bastion_detect_stack', {
  title: 'Detect project stack',
  description: 'Read-only scan of a local project folder (file names and manifest files such as package.json) to decide which Bastion platform rules apply. Ignores node_modules, vendor, build folders.',
  inputSchema: { path: z.string().describe('Absolute path to the project root') },
  annotations: READ_ONLY,
}, async ({ path }) => {
  try {
    const res = detectStack(data, path);
    const lines = res.platforms.map((p) => `- **${p.id}** (${p.file}): ${p.signals.join('; ')}`);
    return text([
      `Project: ${res.project} (${res.scanned_entries} entries scanned)`,
      res.platforms.length ? 'Detected platforms:' : 'No platform detected. Use core rules and pick platforms manually.',
      ...lines,
      '',
      `Next: call bastion_get_rules for "core"${res.platforms.map((p) => `, "${p.id}"`).join('')}.`,
    ].join('\n'));
  } catch (e) {
    return fail(String(e.message || e));
  }
});

server.registerTool('bastion_checklist', {
  title: 'Release checklist',
  description: 'Return the release checklist for a platform, or the Security Definition of Done for "core".',
  inputSchema: { platform: z.string() },
  annotations: READ_ONLY,
}, async ({ platform }) => {
  const id = platform.trim().toLowerCase();
  if (id === 'core') {
    const m = data.core.match(/## 26\. Security Definition of Done\s*\n([\s\S]*?)(?=\n## )/);
    return text(m ? m[1].trim() : 'Definition of Done not found.');
  }
  const doc = data.platformDocs[id];
  if (!doc) return fail(`Unknown platform "${platform}".`);
  return text(getChecklist(doc) || `No release checklist in ${id}. Use the core Definition of Done.`);
});

server.registerTool('bastion_review_snippet', {
  title: 'Quick security review of code',
  description: 'Fast local pattern check of a code snippet against common Red Line and rule violations (secrets, SQL injection, shell exec, disabled TLS, token storage, float money, weak hashes). Heuristic: confirm each hit manually and do a full review for anything important.',
  inputSchema: {
    code: z.string().max(200000),
    filename: z.string().optional(),
  },
  annotations: READ_ONLY,
}, async ({ code, filename }) => {
  const findings = reviewSnippet(code);
  if (!findings.length) return text(`No pattern-level issues found${filename ? ` in ${filename}` : ''}. This is a heuristic check, not a full review.`);
  return text([
    `${findings.length} potential issue(s)${filename ? ` in ${filename}` : ''}:`,
    ...findings.map((f) => `- [BAS-${f.rule}] ${f.severity} line ${f.line}: ${f.message}\n  \`${f.evidence}\``),
    '',
    'Use bastion_get_rule for the full rule text of each ID.',
  ].join('\n'));
});

server.registerTool('bastion_get_template', {
  title: 'Get a Bastion template',
  description: 'Return a template or hardened config file (threat model, findings report, SECURITY.md, security.txt, Next.js CSP, nginx, .htaccess, wp-config, Android network config, macOS entitlements, Supabase RLS, MongoDB, Redis, double-entry ledger, GitHub security workflow). Call without a name to list them.',
  inputSchema: { name: z.string().optional() },
  annotations: READ_ONLY,
}, async ({ name }) => {
  const names = Object.keys(data.templates).sort();
  if (!name) return text(`Templates:\n${names.map((n) => `- ${n} (${data.templates[n].path})`).join('\n')}`);
  const t = data.templates[name] || data.templates[names.find((n) => n.toLowerCase().includes(name.toLowerCase()))];
  if (!t) return fail(`Template "${name}" not found. Available: ${names.join(', ')}`);
  const { readFileSync } = await import('node:fs');
  return text(`File: ${t.path}\n\n${readFileSync(t.abs, 'utf8')}`);
});

// ---------------------------------------------------------------------
// Prompts: one per Bastion workflow
// ---------------------------------------------------------------------
const PROMPT_PREAMBLE =
  'Rules source: if the project has a `.bastion/` folder, read the files there. ' +
  'Otherwise use the Bastion MCP tools: bastion_detect_stack, then bastion_get_rules for "core" and each detected platform, ' +
  'bastion_get_template for templates, and bastion_checklist for release checklists. ' +
  'Where the steps mention `.bastion/PROJECT-RULES.md`, create it in the project if it does not exist.\n\n';

for (const [name, cmd] of Object.entries(data.commands)) {
  const short = name.replace(/^bastion-/, '');
  server.registerPrompt(short, {
    title: `Bastion: ${short}`,
    description: cmd.description,
    argsSchema: { target: z.string().optional().describe('Target, scope, URL, or extra instructions') },
  }, ({ target }) => ({
    messages: [{
      role: 'user',
      content: { type: 'text', text: PROMPT_PREAMBLE + cmd.body.replace(/\$ARGUMENTS/g, target && target.trim() ? target.trim() : '(not specified: use the default)') },
    }],
  }));
}

// ---------------------------------------------------------------------
// Resources
// ---------------------------------------------------------------------
server.registerResource('core', 'bastion://rules/core', {
  title: 'Bastion core rules', description: 'BASTION.md core master rules', mimeType: 'text/markdown',
}, async (uri) => ({ contents: [{ uri: uri.href, mimeType: 'text/markdown', text: stripChrome(data.core) }] }));

server.registerResource('lite', 'bastion://rules/lite', {
  title: 'Bastion lite rules', description: 'Compact core rules for small context windows', mimeType: 'text/markdown',
}, async (uri) => ({ contents: [{ uri: uri.href, mimeType: 'text/markdown', text: stripChrome(data.lite) }] }));

server.registerResource('platform', new ResourceTemplate('bastion://rules/platform/{id}', {
  list: async () => ({
    resources: data.platforms.map((p) => ({ uri: `bastion://rules/platform/${p.id}`, name: p.id, description: p.description, mimeType: 'text/markdown' })),
  }),
  complete: { id: (v) => platformIds.filter((x) => x.startsWith(v)) },
}), { title: 'Bastion platform rules', mimeType: 'text/markdown' }, async (uri, { id }) => {
  const doc = data.platformDocs[id];
  if (!doc) throw new Error(`Unknown platform ${id}`);
  return { contents: [{ uri: uri.href, mimeType: 'text/markdown', text: stripChrome(doc) }] };
});

// ---------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------
const transport = new StdioServerTransport();
await server.connect(transport);
console.error(`Bastion MCP v${data.version} ready: ${data.rules.length} rules, ${data.platforms.length} platforms (read-only).`);
