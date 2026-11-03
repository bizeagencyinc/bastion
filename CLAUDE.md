# CLAUDE.md: Working on the Bastion Repository

This file guides Claude Code when maintaining **this repository** (the Bastion ruleset itself). It is not the file that gets installed into user projects; the installer writes its own block into each target project's `CLAUDE.md`.

## What this repo is

Bastion v2.3.0: a versioned security rulebook (692 rule IDs, 21 platform files) for AI coding agents, plus installers that generate native rule files for Claude Code, Cursor, Copilot, Windsurf, Cline, Codex (AGENTS.md), Gemini CLI, and VS Code.

## Layout

- `BASTION.md`: core rules. Routing table in Section 3 must list every platform file.
- `rules/platforms/*.md`: one file per platform. Each has the standard header and footer blocks.
- `rules/manifest.txt`: `id|file|globs|detection signals|description`. Every platform file needs one line.
- `rules/BASTION-LITE.md`: compact core used for Windsurf. Keep under 10,000 characters.
- `integrations/commands/`: slash commands shared by Claude Code, Cursor, and Copilot. Only `description` in frontmatter.
- `hooks/guard.sh`: PreToolUse hook. Exit 2 blocks. Patterns are `name|regex` lines in a heredoc.
- `scripts/install.sh` and `scripts/install.ps1`: must stay feature-identical.
- `templates/`: copied into projects as `.bastion/templates/`. `templates/PROJECT-RULES.md` seeds each project's `.bastion/PROJECT-RULES.md`, which installers must never overwrite.
- `scripts/build-cover.py` generates `assets/cover.svg`; `assets/cover.png` (1280x640) is rendered from it.

## MCP server and plugin

- `mcp/src/lib.js` (pure functions) and `mcp/src/index.js` (server). Keep every tool read-only with `readOnlyHint: true` and `openWorldHint: false`; never add network, shell, or file-write code (CI greps for it).
- `cd mcp && npm test` runs end-to-end tests over stdio.
- `npm run build:plugin` regenerates `plugin/` (skills from `integrations/commands`, hook, bundled server, data). Commit the result; CI fails if `plugin/` is out of sync.
- Versions must match in `mcp/package.json`, `mcp/server.json`, and the plugin manifest (publish workflow checks this).
- Validate with `claude plugin validate ./plugin` and `claude plugin validate .`.

## House rules

1. Follow `BASTION.md` yourself while editing this repo (it is dogfooded).
2. Rule IDs are permanent. New rules take the next free number. Retired rules are marked `[RETIRED]`, never deleted or renumbered.
3. One requirement per rule, starting with **[MUST]**, **[MUST NOT]**, **[SHOULD]**, or **[MAY]**.
4. Do not use long dashes (the em dash character) anywhere. Use hyphens, colons, or commas.
5. Version string appears in headers, footers, installers, README badge, cover, `mcp/package.json`, `mcp/server.json`, and `CHANGELOG.md`. Bump all together, then rebuild the plugin.
6. When adding a platform: create the file, add a manifest line, add a routing row in `BASTION.md` Section 3, add a README table row, update rule totals, update `CHANGELOG.md`.
7. Verify standards and library versions with a web search before writing version-specific rules.

## Checks to run before every commit

```bash
bash -n scripts/install.sh && bash -n hooks/guard.sh
shellcheck -S warning scripts/install.sh hooks/guard.sh
# rule count (update README if it changed)
grep -cE '^\s*(- \*\*|[0-9]+\. `)[A-Z]+-[0-9]{2}' BASTION.md rules/platforms/*.md | awk -F: '{s+=$2} END {print s}'
# no em dashes
! grep -rn $'\xe2\x80\x94' --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=dist .
# installer smoke test
T=$(mktemp -d); echo '{"dependencies":{"next":"15","mongoose":"8"}}' > $T/package.json; touch $T/next.config.js
./scripts/install.sh "$T" --with-ci && cat "$T/.bastion/ACTIVE_PLATFORMS"
```

Regenerate the cover with `python3 scripts/build-cover.py` (edit the lists in that file), then render it:

```bash
node -e "const {chromium}=require('playwright');(async()=>{const b=await chromium.launch();const p=await b.newPage({viewport:{width:1280,height:640}});await p.goto('file://'+process.cwd()+'/assets/cover.svg');await p.screenshot({path:'assets/cover.png'});await b.close()})()"
```

## Commit style

Conventional Commits with rule IDs: `feat(rules): add NOSQL-39 for Valkey cluster bus [NOSQL-39]`.
