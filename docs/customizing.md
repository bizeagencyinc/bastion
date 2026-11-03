<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

<img src="../assets/logo.svg" width="56" alt="Bastion logo" />

**BASTION** | Security Rules for AI Coding Agents

`docs/customizing.md` | Customizing and Writing Rules | v2.3.0

</div>

---
<!-- ========================================================== -->

# Customizing Bastion

## Add a platform

1. Copy any file in `rules/platforms/` as a starting point, for example `rules/platforms/rust.md`.
2. Pick a unique prefix (for example `RUST`) and number rules from `RUST-01`.
3. Keep the header and footer blocks so the file matches the rest of the repo.
4. Add one line to `rules/manifest.txt`:

   ```text
   rust|rust.md|**/*.rs,**/Cargo.toml|name:Cargo.toml|Rust security rules
   ```

5. Run `./scripts/install.sh --list` to confirm it appears.

## Rule writing standard

| Do | Do not |
|---|---|
| One requirement per rule | Combine unrelated controls |
| Start with **[MUST]**, **[MUST NOT]**, **[SHOULD]**, or **[MAY]** | Use vague words like "consider" without a keyword |
| Name the exact API, flag, or setting | Say "use best practices" |
| Make it testable or reviewable | Write goals that cannot be checked |
| Reference a template when one exists | Paste long code into rules |

## Rule ID policy

- IDs are permanent. If a rule is removed, mark it `[RETIRED]` and keep the number.
- New rules get the next free number in their prefix.
- Changes to rule meaning go in `CHANGELOG.md`.

## Organization overrides

Create `rules/platforms/org-overrides.md` with your company rules (prefix `ORG`) and a manifest line whose detection signal always matches, for example `dir:.bastion`. Org rules should only make rules stricter, never weaker.

## Severity mapping for findings

| Severity | Typical trigger |
|---|---|
| Critical | Red Line violation with direct exploit path, exposed secret, unauthenticated data access |
| High | MUST violation with realistic exploit path |
| Medium | MUST violation needing extra conditions, or defense-in-depth gap |
| Low | SHOULD violation |
| Info | Hardening suggestion |

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Customizing | MIT License | Created by <a href="https://bizeagency.com">Muhammad Faisal</a> | <a href="../README.md">Home</a> | <a href="quick-start.md">Quick Start</a></sub>
</div>
<!-- ========================================================== -->
