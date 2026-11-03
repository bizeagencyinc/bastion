<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

<img src="../assets/logo.svg" width="56" alt="Bastion logo" />

**BASTION** | Security Rules for AI Coding Agents

`docs/quick-start.md` | Quick Start | v2.3.0

</div>

---
<!-- ========================================================== -->

# Quick Start

## 1. Get Bastion

```bash
git clone https://github.com/bizeagencyinc/bastion.git
```

Or download the ZIP from the GitHub release page and extract it.

## 2. Install into your project

**macOS / Linux / WSL / Git Bash**

```bash
./bastion/scripts/install.sh ~/projects/my-app --with-ci
```

**Windows PowerShell**

```powershell
# If scripts are blocked, allow them for this session only:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\bastion\scripts\install.ps1 -Target C:\projects\my-app -WithCI
```

The installer:

1. Copies the rules into `my-app/.bastion/`.
2. Detects your stack (for example Next.js + Supabase + Stripe) and records it in `.bastion/ACTIVE_PLATFORMS`.
3. Writes native rule files for Claude Code, Cursor, Copilot, Windsurf, Cline, Codex, and Gemini CLI.
4. Adds slash commands, the guard hook, VS Code tasks, `.gitignore` secret patterns, and (with `--with-ci`) a GitHub security workflow.

## 3. Check what was detected

```bash
cat .bastion/ACTIVE_PLATFORMS
```

Wrong or missing platform? Re-run with an explicit list:

```bash
./bastion/scripts/install.sh ~/projects/my-app --platforms nextjs,supabase-firebase,payments
```

## 4. Run your first audit

Open the project in Claude Code (terminal or VS Code) and type:

```text
/bastion-audit
```

In Cursor or Copilot Chat, run the same command from the prompt menu, or ask: "Run a Bastion audit".

The report is saved to `security/bastion-audit-<date>.md` with a scorecard grade.

## 5. Fix and ship

```text
/bastion-harden all critical and high
/bastion-release
```

## 6. Commit the rules

Commit `.bastion/` and the generated tool files so your whole team and CI use the same rules:

```bash
git add .bastion CLAUDE.md AGENTS.md GEMINI.md .claude .cursor .github .windsurf .clinerules .vscode .gitignore
git commit -m "chore(security): add Bastion v2.3.0 security rules"
```

## Updating

Pull the latest Bastion and run the installer again. It replaces only Bastion-owned files and blocks.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Quick Start | MIT License | Created by <a href="https://bizeagency.com">Muhammad Faisal</a> | <a href="../README.md">Home</a> | Next: <a href="integrations.md">Tool Integrations</a></sub>
</div>
<!-- ========================================================== -->
