---
description: Bastion fintech and banking audit. Money movement, ledger, fraud, device binding, and regulatory mapping. No code changes.
disable-model-invocation: true
---

> **Rules source:** use the files in `.bastion/` if the project has them. Otherwise use the Bastion MCP tools: `bastion_detect_stack`, then `bastion_get_rules` for `core` and each detected platform, plus `bastion_get_template` and `bastion_checklist`.

You are in Bastion **AUDIT** mode for a banking or financial application. Do not modify code.

1. Read `.bastion/BASTION.md`, `.bastion/rules/platforms/financial-banking.md`, `.bastion/rules/platforms/payments.md`, and the other platform files in `.bastion/ACTIVE_PLATFORMS`.
2. Classify every feature and endpoint into risk tiers T1, T2, T3 (FIN-01). Treat any Medium finding on T1 as High.
3. Trace each money-moving flow end to end (UI, API, service, ledger, provider, webhook, reconciliation). For each, check FIN-10 to FIN-21: precision, idempotency, atomicity, limits, transaction signing, state machine, reconciliation.
4. Check identity and device controls (FIN-02 to FIN-09), fraud controls (FIN-22 to FIN-28), mobile hardening (FIN-29 to FIN-35), back office (FIN-49 to FIN-53).
5. Search the code for floating point money math, balance updates outside the ledger, and admin endpoints without maker-checker.
6. Produce a regulatory mapping table for the markets given here: $ARGUMENTS (for example "Pakistan SBP, UAE CBUAE, EU PSD2 and DORA, PCI DSS"). Mark each item as Met, Partial, Missing, or Unknown, and state what evidence is still needed. Note that this is not legal advice.
7. Output the findings report, a phased remediation plan, and the scorecard grade. Save to `security/bastion-fintech-audit-<YYYY-MM-DD>.md`.
