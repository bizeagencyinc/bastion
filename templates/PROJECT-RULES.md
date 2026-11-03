<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`.bastion/PROJECT-RULES.md` | Project-Specific Rules | v2.3.0 | Prefix: `PRJ`

</div>

---
<!-- ========================================================== -->

# Project-Specific Security Rules

> This file belongs to this project. The installer creates it once and never overwrites it.
> `/bastion-secure` adds rules here after each audit. Project rules may only add or tighten; they never weaken core or platform rules.

## Project Profile

| Field | Value |
|---|---|
| Project | (fill in) |
| Stack | (languages, frameworks, databases, hosting) |
| Risk tier | T1 / T2 / T3 |
| Data classes | Public / Internal / Confidential / Restricted |
| Markets and compliance | (for example GDPR, PCI DSS, SBP, DORA) |
| Last Bastion audit | (date and grade) |

## Project Rules

<!-- Example:
- **PRJ-01** [MUST] Every route under `app/api/admin/` calls `requireAdmin()` from `lib/auth.ts` before any database access.
-->

## Accepted Risks

| ID | Finding | Reason | Owner | Review by |
|---|---|---|---|---|

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Project Rules | Updated by /bastion-secure | Bastion by <a href="https://bizeagency.com">Muhammad Faisal</a></sub>
</div>
<!-- ========================================================== -->
