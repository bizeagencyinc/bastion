// =====================================================================
// BASTION MCP | Core library
// Pure, read-only functions: no network, no shell execution, no writes.
// =====================================================================
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));

/** Find the Bastion data folder: packaged copy first, then the repo root (development). */
export function resolveDataRoot() {
  const candidates = [
    process.env.BASTION_DATA_DIR,
    path.join(HERE, '..', 'data'),
    path.join(HERE, '..', '..'),
  ].filter(Boolean);
  for (const c of candidates) {
    if (fs.existsSync(path.join(c, 'BASTION.md')) && fs.existsSync(path.join(c, 'rules', 'manifest.txt'))) {
      return path.resolve(c);
    }
  }
  throw new Error('Bastion data not found. Set BASTION_DATA_DIR or reinstall the package.');
}

const RULE_RX = /^\s*-\s+\*\*([A-Z]+-\d{2})\*\*\s+\[(MUST NOT|MUST|SHOULD NOT|SHOULD|MAY)\]\s+(.*)$/;
const RED_RX = /^\s*\d+\.\s+`(RED-\d{2})`\s+(.*)$/;

/** Parse rule lines from a Markdown rule file. */
export function parseRules(markdown, file) {
  const rules = [];
  let section = '';
  for (const line of markdown.split(/\r?\n/)) {
    const h = line.match(/^#{2,3}\s+(.*)$/);
    if (h) { section = h[1].trim(); continue; }
    let m = line.match(RULE_RX);
    if (m) { rules.push({ id: m[1], level: m[2], text: m[3].trim(), section, file }); continue; }
    m = line.match(RED_RX);
    if (m) rules.push({ id: m[1], level: 'MUST NOT', text: m[2].trim(), section: 'The 12 Red Lines', file });
  }
  return rules;
}

/** Strip the decorative HTML header and footer blocks to save tokens. */
export function stripChrome(md) {
  return md
    .replace(/<!-- =+ BASTION HEADER =+ -->[\s\S]*?<!-- =+ -->\s*/m, '')
    .replace(/---\s*\n<!-- =+ BASTION FOOTER =+ -->[\s\S]*$/m, '')
    .trim() + '\n';
}

function walk(dir, maxDepth, depth = 0, out = []) {
  if (depth > maxDepth) return out;
  let entries = [];
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch { return out; }
  for (const e of entries) {
    out.push({ abs: path.join(dir, e.name), name: e.name, isDir: e.isDirectory(), depth: depth });
    if (out.length > 30000) return out;
  }
  return out;
}

export function loadData(root = resolveDataRoot()) {
  const read = (p) => fs.readFileSync(path.join(root, p), 'utf8');
  const version = (read('BASTION.md').match(/v(\d+\.\d+\.\d+)/) || [])[1] || 'unknown';

  const platforms = read('rules/manifest.txt')
    .split(/\r?\n/)
    .filter((l) => l.trim() && !l.trim().startsWith('#'))
    .map((l) => {
      const [id, file, globs, signals, description] = l.split('|');
      return { id, file, globs: globs.split(','), signals: signals.split(';'), description };
    });

  const core = read('BASTION.md');
  const lite = read('rules/BASTION-LITE.md');
  const platformDocs = {};
  for (const p of platforms) platformDocs[p.id] = read(path.join('rules', 'platforms', p.file));

  const rules = [
    ...parseRules(core, 'BASTION.md'),
    ...platforms.flatMap((p) => parseRules(platformDocs[p.id], `rules/platforms/${p.file}`)),
  ];

  const commands = {};
  const cmdDir = path.join(root, 'integrations', 'commands');
  for (const f of fs.readdirSync(cmdDir).filter((f) => f.endsWith('.md')).sort()) {
    const raw = fs.readFileSync(path.join(cmdDir, f), 'utf8');
    const fm = raw.match(/^---\n([\s\S]*?)\n---\n/);
    const description = fm ? (fm[1].match(/description:\s*(.*)/) || [])[1] || '' : '';
    commands[f.replace(/\.md$/, '')] = { description, body: fm ? raw.slice(fm[0].length) : raw };
  }

  const templates = {};
  const tplRoot = path.join(root, 'templates');
  const stack = [tplRoot];
  while (stack.length) {
    const d = stack.pop();
    for (const e of fs.readdirSync(d, { withFileTypes: true })) {
      const abs = path.join(d, e.name);
      if (e.isDirectory()) stack.push(abs);
      else templates[e.name] = { path: path.relative(root, abs).split(path.sep).join('/'), abs };
    }
  }

  return { root, version, platforms, core, lite, platformDocs, rules, commands, templates };
}

// ---------------------------------------------------------------------
// Queries
// ---------------------------------------------------------------------
export function findRule(data, id) {
  const want = id.trim().toUpperCase().replace(/^BAS-/, '');
  return data.rules.find((r) => r.id === want) || null;
}

export function searchRules(data, query, { platform, limit = 15 } = {}) {
  const tokens = query.toLowerCase().split(/[^a-z0-9.+#-]+/).filter((t) => t.length > 1);
  if (!tokens.length) return [];
  let pool = data.rules;
  if (platform) {
    const p = data.platforms.find((x) => x.id === platform);
    const file = p ? `rules/platforms/${p.file}` : 'BASTION.md';
    pool = pool.filter((r) => r.file === file);
  }
  return pool
    .map((r) => {
      const hay = `${r.id} ${r.section} ${r.text}`.toLowerCase();
      let score = 0;
      for (const t of tokens) if (hay.includes(t)) score += r.text.toLowerCase().includes(t) ? 2 : 1;
      if (r.level.startsWith('MUST')) score += 0.1;
      return { r, score };
    })
    .filter((x) => x.score >= Math.max(1, tokens.length * 0.6))
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map((x) => x.r);
}

export function getChecklist(markdown) {
  const m = markdown.match(/^##\s+[^\n]*Release Checklist\s*\n([\s\S]*?)(?=\n---|\n##\s|(?![\s\S]))/m);
  return m ? m[1].trim() : null;
}

export function countRules(data) {
  const byFile = {};
  for (const r of data.rules) byFile[r.file] = (byFile[r.file] || 0) + 1;
  return byFile;
}

// ---------------------------------------------------------------------
// Stack detection (read-only, bounded)
// ---------------------------------------------------------------------
const PRUNE = new Set(['node_modules', 'vendor', '.git', 'build', 'dist', '.next', '.bastion', 'Pods', '.dart_tool', 'venv', '.venv', '__pycache__', '.gradle', 'target']);

function globToRegex(g) {
  return new RegExp('^' + g.replace(/[.+^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '.*').replace(/\?/g, '.') + '$');
}

function collect(root, maxDepth) {
  const out = [];
  const queue = [{ dir: root, depth: 0 }];
  while (queue.length && out.length < 30000) {
    const { dir, depth } = queue.shift();
    for (const e of walk(dir, 0)) {
      out.push({ ...e, depth });
      if (e.isDir && !PRUNE.has(e.name) && depth < maxDepth) queue.push({ dir: e.abs, depth: depth + 1 });
    }
  }
  return out;
}

export function detectStack(data, projectDir) {
  const dir = path.resolve(projectDir);
  const st = fs.statSync(dir, { throwIfNoEntry: false });
  if (!st || !st.isDirectory()) throw new Error(`Not a directory: ${dir}`);

  const entries = collect(dir, 4);
  const shallowFiles = entries.filter((e) => !e.isDir && e.depth <= 2);
  const cache = new Map();
  const readSmall = (abs) => {
    if (cache.has(abs)) return cache.get(abs);
    let txt = '';
    try { if (fs.statSync(abs).size <= 2_000_000) txt = fs.readFileSync(abs, 'utf8'); } catch { /* ignore */ }
    cache.set(abs, txt);
    return txt;
  };

  const results = [];
  for (const p of data.platforms) {
    const matched = [];
    for (const sig of p.signals) {
      if (sig.startsWith('name:')) {
        const rx = globToRegex(sig.slice(5));
        const hit = entries.find((e) => rx.test(e.name) && !PRUNE.has(e.name));
        if (hit) matched.push(`${sig} -> ${path.relative(dir, hit.abs)}`);
      } else if (sig.startsWith('dir:')) {
        const d = path.join(dir, sig.slice(4));
        if (fs.existsSync(d) && fs.statSync(d).isDirectory()) matched.push(sig);
      } else if (sig.startsWith('grep:')) {
        const rest = sig.slice(5);
        const i = rest.indexOf(':');
        const file = rest.slice(0, i);
        const text = rest.slice(i + 1);
        const hit = shallowFiles.find((e) => e.name === file && readSmall(e.abs).includes(text));
        if (hit) matched.push(`${sig} -> ${path.relative(dir, hit.abs)}`);
      }
      if (matched.length >= 3) break;
    }
    if (matched.length) results.push({ id: p.id, file: `rules/platforms/${p.file}`, description: p.description, signals: matched });
  }
  return { project: dir, scanned_entries: entries.length, platforms: results };
}

// ---------------------------------------------------------------------
// Snippet review: fast local heuristics mapped to rule IDs
// ---------------------------------------------------------------------
const CHECKS = [
  { id: 'RED-01', sev: 'Critical', rx: /(AKIA[0-9A-Z]{16}|sk_live_[0-9A-Za-z]{20,}|gh[pousr]_[0-9A-Za-z]{36,}|sk-ant-(api|admin)\d{2}-[\w-]{20,}|sk-proj-[\w-]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----)/, msg: 'Hardcoded secret or private key.' },
  { id: 'SEC-01', sev: 'High', rx: /(postgres(ql)?|mysql|mongodb(\+srv)?|rediss?):\/\/[^:\s/"'`]+:[^@\s/"'`$<{]{6,}@/i, msg: 'Database connection string with an embedded password.' },
  { id: 'RED-04', sev: 'High', rx: /(SELECT|INSERT|UPDATE|DELETE)\b[^;\n]*(\+\s*\w+|\$\{[^}]+\}|%s|\.format\(|f["'][^"']*\{)/i, msg: 'SQL built with string concatenation or interpolation.' },
  { id: 'INPUT-06', sev: 'High', rx: /\b(eval|new Function|exec\s*\(|execSync\s*\(|shell_exec|system\s*\(|passthru|popen|subprocess\.[a-z_]+\([^)]*shell\s*=\s*True)/, msg: 'Dynamic code or shell execution.' },
  { id: 'RED-05', sev: 'High', rx: /(rejectUnauthorized\s*:\s*false|verify\s*=\s*False|NODE_TLS_REJECT_UNAUTHORIZED\s*=\s*['"]?0|InsecureSkipVerify\s*:\s*true|badCertificateCallback[^;]*=>\s*true|NSAllowsArbitraryLoads|cleartextTrafficPermitted="true"|CURLOPT_SSL_VERIFYPEER\s*,\s*(false|0))/, msg: 'TLS verification disabled or cleartext traffic allowed.' },
  { id: 'AUTH-15', sev: 'Medium', rx: /(localStorage|sessionStorage|AsyncStorage)\.(setItem)\(\s*['"`][^'"`]*(token|jwt|session|auth)/i, msg: 'Auth token stored in web or app storage readable by scripts.' },
  { id: 'FE-07', sev: 'Medium', rx: /(dangerouslySetInnerHTML|v-html|\{@html|\.innerHTML\s*=|bypassSecurityTrust)/, msg: 'Raw HTML rendering; sanitize or avoid.' },
  { id: 'FIN-10', sev: 'High', rx: /\b(parseFloat|toFixed|Number)\s*\([^)]*(amount|price|balance|total|fee)|\b(float|double)\s+(amount|price|balance|total|fee)/i, msg: 'Floating point used for money.' },
  { id: 'AUTH-02', sev: 'High', rx: /\b(md5|sha1)\s*\(|createHash\(\s*['"](md5|sha1)['"]\)/i, msg: 'Weak hash; never use for passwords or signatures.' },
  { id: 'PY-03', sev: 'High', rx: /\b(pickle\.loads?|yaml\.load\((?![^)]*SafeLoader)|unserialize\s*\()/, msg: 'Unsafe deserialization.' },
  { id: 'NODE-11', sev: 'Medium', rx: /\[(req|request)\.(body|query|params)\.[a-zA-Z_]+\]\s*=/, msg: 'Dynamic property assignment from request input (prototype pollution risk).' },
  { id: 'BAAS-03', sev: 'Critical', rx: /NEXT_PUBLIC_[A-Z_]*(SERVICE_ROLE|SECRET)|EXPO_PUBLIC_[A-Z_]*(SECRET|SERVICE_ROLE)|VITE_[A-Z_]*(SECRET|SERVICE_ROLE)/, msg: 'Server secret exposed through a public client environment variable.' },
  { id: 'API-05', sev: 'Medium', rx: /Access-Control-Allow-Origin['"]?\s*[:,]\s*['"]\*['"][\s\S]{0,200}Allow-Credentials['"]?\s*[:,]\s*['"]?true|origin\s*:\s*true\s*,\s*credentials\s*:\s*true/i, msg: 'CORS reflects any origin with credentials.' },
  { id: 'WP-21', sev: 'High', rx: /permission_callback['"]?\s*=>\s*['"]__return_true['"]/, msg: 'WordPress REST route open to everyone; check it is read-only public data.' },
  { id: 'RED-12', sev: 'Medium', rx: /(DEBUG\s*=\s*True|APP_DEBUG\s*=\s*true|WP_DEBUG_DISPLAY['"]?\s*,\s*true|display_errors\s*=\s*On)/i, msg: 'Debug output enabled.' },
  { id: 'CRYPTO-02', sev: 'Medium', rx: /Math\.random\(\)[^;\n]*(token|secret|password|otp|code|key)|\brand\(\)|mt_rand\(/i, msg: 'Non-cryptographic randomness for security values.' },
];

export function reviewSnippet(code) {
  const lines = code.split(/\r?\n/);
  const findings = [];
  for (const c of CHECKS) {
    lines.forEach((line, i) => {
      if (c.rx.test(line)) findings.push({ rule: c.id, severity: c.sev, line: i + 1, message: c.msg, evidence: redact(line.trim()).slice(0, 160) });
    });
  }
  const order = { Critical: 0, High: 1, Medium: 2, Low: 3 };
  return findings.sort((a, b) => order[a.severity] - order[b.severity] || a.line - b.line);
}

function redact(s) {
  return s
    .replace(/(AKIA)[0-9A-Z]{12}/g, '$1************')
    .replace(/(sk_live_|sk-ant-|sk-proj-|gh[pousr]_)[\w-]{6,}/g, '$1********')
    .replace(/(:\/\/[^:\s/]+:)[^@\s]+@/g, '$1********@');
}
