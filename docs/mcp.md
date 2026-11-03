<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

<img src="../assets/logo.svg" width="56" alt="Bastion logo" />

**BASTION** | Security Rules for AI Coding Agents

`docs/mcp.md` | MCP Server and Claude Code Plugin | v2.3.0

</div>

---
<!-- ========================================================== -->

# MCP Server and Claude Code Plugin

Bastion ships three ways. Pick one, or combine them.

| Way | Best for | Works in |
|---|---|---|
| **Claude Code plugin** | One install for all repos: skills, guard hook, and an offline MCP server | Claude Code (terminal, VS Code, JetBrains, desktop) |
| **MCP server** (`bastion-security-mcp`) | Any MCP client, all repos, no files added to projects | Claude Code, Claude Desktop, Cursor, VS Code Copilot, Windsurf, Gemini CLI, Codex |
| **Installer** (`scripts/install.sh`) | Committing rules into a repo so the whole team and CI share them | Every tool, plus CI |

## 1. Claude Code plugin (recommended)

```bash
claude plugin marketplace add bizeagencyinc/bastion
claude plugin install bastion@bastion-security
```

You get, in every repository:

- Skills: `/bastion:secure`, `/bastion:audit`, `/bastion:harden`, `/bastion:review`, `/bastion:threat-model`, `/bastion:build`, `/bastion:release`, `/bastion:incident`, `/bastion:fintech-audit`, `/bastion:site-audit`
- `security-rules` skill that Claude loads by itself when code touches auth, data, payments, or secrets
- The guard hook (blocks secrets and dangerous commands)
- The Bastion MCP server, bundled into the plugin as one file: no `npm install`, no network

Update: `claude plugin marketplace update bastion-security`.

## 2. MCP server in any client

Use the npm package so every client gets the same version:

| Client | Where | Config |
|---|---|---|
| Claude Code (all repos) | shell | `claude mcp add --scope user bastion -- npx -y bastion-security-mcp` |
| Claude Code (one repo, shared with team) | `.mcp.json` | `{"mcpServers":{"bastion":{"command":"npx","args":["-y","bastion-security-mcp"]}}}` |
| Claude Desktop | `claude_desktop_config.json` | same `mcpServers` block |
| Cursor | `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` | same `mcpServers` block |
| VS Code | user `mcp.json` or `.vscode/mcp.json` | `{"servers":{"bastion":{"type":"stdio","command":"npx","args":["-y","bastion-security-mcp"]}}}` |
| Windsurf | `~/.codeium/windsurf/mcp_config.json` | same `mcpServers` block |
| Gemini CLI | `~/.gemini/settings.json` | same `mcpServers` block |
| Codex CLI | `~/.codex/config.toml` | `[mcp_servers.bastion]` with `command = "npx"`, `args = ["-y", "bastion-security-mcp"]` |

The installer can write the project files for you: `./scripts/install.sh <project> --with-mcp`.

To pin a version for reproducibility, use `bastion-security-mcp@2.3.0`.

## What the server offers

**Tools** (all read-only): `bastion_detect_stack`, `bastion_get_rules`, `bastion_get_rule`, `bastion_search_rules`, `bastion_red_lines`, `bastion_checklist`, `bastion_review_snippet`, `bastion_get_template`, `bastion_list_platforms`.

**Prompts**: `secure`, `audit`, `harden`, `review`, `threat-model`, `build`, `release`, `incident`, `fintech-audit`, `site-audit`.

**Resources**: `bastion://rules/core`, `bastion://rules/lite`, `bastion://rules/platform/{id}`.

## Trust

The server never writes files, runs commands, reads secrets, or uses the network. It is published with npm provenance and listed in the official MCP Registry. Full details and self-check commands: [mcp/SECURITY-MODEL.md](../mcp/SECURITY-MODEL.md).

To auto-approve its tools in Claude Code, add to `~/.claude/settings.json`:

```json
{ "permissions": { "allow": ["mcp__bastion"] } }
```

For the plugin version the tool prefix is `mcp__plugin_bastion_bastion`.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | MCP and Plugin | MIT License | Created by <a href="https://bizeagency.com">BIZ E-Agency Inc</a> | <a href="../README.md">Home</a> | <a href="integrations.md">Tool Integrations</a></sub>
</div>
<!-- ========================================================== -->
