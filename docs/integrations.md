<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

<img src="../assets/logo.svg" width="56" alt="Bastion logo" />

**BASTION** | Security Rules for AI Coding Agents

`docs/integrations.md` | Tool Integrations | v2.3.0

</div>

---
<!-- ========================================================== -->

# Tool Integrations

> Prefer zero files in your repos? Use the MCP server or the Claude Code plugin instead: see [mcp.md](mcp.md).

All integrations are generated from the same source files, so every tool follows identical rules. Tool file formats change often; if a tool stops loading a file, check its current documentation and open an issue.

## Claude Code (terminal, VS Code, JetBrains, desktop, web)

| File | Purpose |
|---|---|
| `CLAUDE.md` | A marked block with `@.bastion/BASTION.md` and `@` imports for each active platform file. Claude Code loads imports at session start. |
| `.claude/commands/bastion-*.md` | Slash commands. Type `/bastion` to see them. |
| `.claude/settings.json` | `permissions.deny` stops reads of `.env`, keys, keystores, and service accounts; `permissions.ask` requires approval for pushes and deploys; `hooks.PreToolUse` runs the guard hook. |
| `.bastion/hooks/guard.sh` | Blocks secrets in writes and dangerous shell commands (exit code 2). |

If you already had `.claude/settings.json`, the installer keeps yours. Merge the `permissions` and `hooks` sections from `integrations/claude/settings.json` by hand.

Check that rules are loaded: run `/memory` in Claude Code.

## VS Code

| File | Purpose |
|---|---|
| `.vscode/extensions.json` | Recommends Claude Code, Copilot Chat, SonarLint, Semgrep, Snyk, ESLint, YAML, EditorConfig, markdownlint |
| `.vscode/settings.json` | Enables Copilot instruction files and prompt files, blocks force push, hides secrets from search |
| `.vscode/tasks.json` | **Terminal > Run Task > Bastion: Full local scan** runs gitleaks, osv-scanner, semgrep, and trivy |

Install the scanners once: `brew install gitleaks osv-scanner semgrep trivy` (macOS) or `winget` / `scoop` on Windows.

## GitHub Copilot (VS Code, Visual Studio, JetBrains, github.com)

| File | Purpose |
|---|---|
| `.github/copilot-instructions.md` | Short block pointing to the Bastion files |
| `.github/instructions/bastion-core.instructions.md` | Full core rules, `applyTo: "**"` |
| `.github/instructions/bastion-<platform>.instructions.md` | Platform rules with `applyTo` globs |
| `.github/prompts/bastion-*.prompt.md` | Reusable prompts (type `/bastion-audit` in Copilot Chat) |

## Cursor

| File | Purpose |
|---|---|
| `.cursor/rules/bastion-core.mdc` | `alwaysApply: true` |
| `.cursor/rules/bastion-<platform>.mdc` | Auto-attached by `globs` |
| `.cursor/commands/bastion-*.md` | Custom commands |

## Windsurf

| File | Purpose |
|---|---|
| `.windsurf/rules/bastion-core.md` | `trigger: always_on`, uses the compact `BASTION-LITE.md` to stay within rule size limits |
| `.windsurf/rules/bastion-<platform>.md` | `trigger: glob` |

## Cline and Roo Code

`.clinerules/bastion-core.md` plus one file per active platform.

## OpenAI Codex, Jules, Amp, and other AGENTS.md readers

`AGENTS.md` gets a marked block telling the agent to read the core and platform files before any task.

## Gemini CLI

`GEMINI.md` gets a marked block with `@` imports.

## Any other agent or chat tool

Paste `BASTION.md` (or `rules/BASTION-LITE.md` for short context windows) plus the relevant platform files as the system prompt or first message.

## Project rules

`.bastion/PROJECT-RULES.md` is created once and never overwritten. `/bastion-secure` adds `PRJ` rules there after each audit. Re-run the installer (`bash .bastion/scripts/install.sh .` or `.bastion\scripts\install.ps1 -Target .`) to copy the updated project rules into Cursor, Copilot, Windsurf, and Cline files. Claude Code and Gemini CLI read it directly through `@` imports.

## Marked blocks

Shared files (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.github/copilot-instructions.md`) use these markers:

```text
<!-- BASTION:START -->
...
<!-- BASTION:END -->
```

Everything outside the markers is yours and is never changed.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Tool Integrations | MIT License | Created by <a href="https://bizeagency.com">BIZ E-Agency Inc</a> | <a href="../README.md">Home</a> | Next: <a href="customizing.md">Customizing</a></sub>
</div>
<!-- ========================================================== -->
