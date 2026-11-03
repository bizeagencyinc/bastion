---
description: Bastion INCIDENT mode. Guided containment, evidence preservation, credential rotation plan, and notification checklist.
---

> **Rules source:** use the files in `.bastion/` if the project has them. Otherwise use the Bastion MCP tools: `bastion_detect_stack`, then `bastion_get_rules` for `core` and each detected platform, plus `bastion_get_template` and `bastion_checklist`.

You are in Bastion **INCIDENT** mode. Situation: $ARGUMENTS

Rules: never delete logs or evidence; never run destructive commands without explicit approval; propose before acting.

1. Triage: what is affected, since when, what data classes, is it ongoing.
2. Containment plan (proposed, not executed): isolate hosts, disable compromised accounts and keys, block attacker IPs, put the site in maintenance mode if needed.
3. Evidence: list logs, snapshots, and artifacts to preserve and how.
4. Credential rotation list: every secret that could be exposed, owner, rotation steps, order.
5. Root cause hypotheses ranked by likelihood with how to confirm each.
6. Eradication and recovery steps.
7. Notification checklist: customers, payment providers, regulators (for example GDPR 72 hours), hosting provider.
8. Post-incident actions mapped to Bastion rule IDs.

Write everything to `security/incident-<YYYY-MM-DD>.md`.
