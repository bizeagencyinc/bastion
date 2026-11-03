---
description: Bastion full pipeline. Analyze the app or website, run security checks, plan, fix with approval, then adapt the project rules to what was found.
---

> **Rules source:** use the files in `.bastion/` if the project has them. Otherwise use the Bastion MCP tools: `bastion_detect_stack`, then `bastion_get_rules` for `core` and each detected platform, plus `bastion_get_template` and `bastion_checklist`.

You are running the Bastion **SECURE** pipeline. Target: $ARGUMENTS (default: this whole project).
Work through the phases in order. Show a short status table after each phase.

## Phase 1: Analyze

1. Read `.bastion/BASTION.md`, `.bastion/PROJECT-RULES.md`, and every file in `.bastion/ACTIVE_PLATFORMS`.
2. Detect the real stack: languages, frameworks, databases, ORMs, hosting, CI/CD, AI features, payments, mobile and desktop targets. Compare with `ACTIVE_PLATFORMS`.
3. If you detect a platform that is not active, load its file from `.bastion/rules/platforms/` now and list it as "newly detected".
4. Map the attack surface: public routes, API endpoints, Server Actions, webhooks, admin areas, file uploads, auth flows, money flows, database access paths, third-party scripts, secrets locations (names only, never values).

## Phase 2: Security Check

Run every check that is available, and say which tools were missing:

| Check | Commands (use what is installed) |
|---|---|
| Secrets | `gitleaks detect --redact --no-banner`, or `trufflehog filesystem .` |
| Dependencies | `npm audit` / `pnpm audit`, `composer audit`, `pip-audit`, `osv-scanner scan source -r .`, `flutter pub outdated` |
| Static analysis | `semgrep scan --config p/default --metrics=off`, `bandit -r .`, framework linters |
| Config and IaC | `trivy fs --scanners misconfig,secret .` |
| Framework checks | `python manage.py check --deploy`, `php artisan about`, `wp core verify-checksums`, Supabase Security Advisor |

Then do a manual review against the 12 Red Lines and the loaded platform rules, focusing on authz on every endpoint, input validation, injection, secrets, session handling, and database access control.

Write all findings in the Bastion finding format to `security/bastion-secure-<YYYY-MM-DD>.md`, with the scorecard grade.

## Phase 3: Plan

Produce a remediation plan grouped as:

- **Phase A: Fix now** (Critical, High, Red Lines)
- **Phase B: Harden** (Medium, missing defenses, CI gates)
- **Phase C: Architecture** (larger changes)

For each item: finding ID, rule ID, files, approach, risk of the change, test to prove it.

**STOP here and ask the user to approve the plan** (all, some IDs, or none). Do not change code before approval.

## Phase 4: Fix (approved items only)

For each approved item, in severity order:
1. Make the smallest safe change.
2. Add a test that fails before and passes after.
3. Commit with `fix(<area>): <summary> [<RULE-ID>]` (only if the user allows commits).
4. Ask again before anything destructive, credential rotation, infrastructure, or production change.

## Phase 5: Adapt the Rules

Update the rules so the same problems cannot return:

1. Edit `.bastion/PROJECT-RULES.md` (keep its header and footer):
   - Add the project profile: stack, risk tier, data classes, markets, compliance needs.
   - Add project-specific rules with prefix `PRJ` and the next free number. Each rule must name exact files, functions, or patterns from this codebase, for example: `PRJ-04 [MUST] All routes under app/api/admin/ call requireAdmin() from lib/auth.ts.`
   - Record accepted risks with owner and review date.
   - Never weaken or remove a core or platform rule; project rules may only add or tighten.
2. If new platforms were detected, regenerate the tool files:
   - macOS / Linux / Git Bash: `bash .bastion/scripts/install.sh . --platforms <comma list of all platforms>`
   - Windows: `powershell -ExecutionPolicy Bypass -File .bastion/scripts/install.ps1 -Target . -Platforms <list>`
   Otherwise run the same command without `--platforms` to refresh the generated files from `PROJECT-RULES.md`.

## Phase 6: Verify

Re-run the Phase 2 checks, update the report with before and after scorecard grades, and finish with:
- What was fixed (with rule IDs)
- What is still open and why
- New project rules added
- Recommended next run date
