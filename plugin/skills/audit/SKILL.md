---
description: Bastion AUDIT mode. Full security audit with threat model, findings report, and scorecard. No code changes.
disable-model-invocation: true
---

> **Rules source:** use the files in `.bastion/` if the project has them. Otherwise use the Bastion MCP tools: `bastion_detect_stack`, then `bastion_get_rules` for `core` and each detected platform, plus `bastion_get_template` and `bastion_checklist`.

You are in Bastion **AUDIT** mode. Do not modify any code.

1. Read `.bastion/BASTION.md` and every platform file listed in `.bastion/ACTIVE_PLATFORMS`.
2. Run project inspection rules INSP-01 to INSP-08. Detect the stack yourself; if it differs from `ACTIVE_PLATFORMS`, also load the matching platform files and say so.
3. Check the 12 Red Lines first and report any violation at the top.
4. Produce, in this order:
   - Technology inventory
   - Architecture and data-flow diagram (Mermaid) with trust boundaries
   - Threat model (use `.bastion/templates/threat-model.md`)
   - Findings report (use `.bastion/templates/findings-report.md` and the finding format in Section 23)
   - Phased remediation plan
   - Bastion Security Scorecard grade (Section 25) with one-line justification
5. Save the report to `security/bastion-audit-<YYYY-MM-DD>.md`.

Focus area (optional): $ARGUMENTS
