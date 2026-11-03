---
description: Bastion threat model for the whole system or one feature (STRIDE, OWASP, MITRE ATLAS for AI).
---

> **Rules source:** use the files in `.bastion/` if the project has them. Otherwise use the Bastion MCP tools: `bastion_detect_stack`, then `bastion_get_rules` for `core` and each detected platform, plus `bastion_get_template` and `bastion_checklist`.

Build a threat model for: $ARGUMENTS (default: the whole project).

1. Read `.bastion/BASTION.md` Section 3 and `.bastion/templates/threat-model.md`.
2. Draw a Mermaid data-flow diagram with actors, processes, data stores, external services, and trust boundaries.
3. For each element and boundary crossing, list STRIDE threats. Add MITRE ATLAS threats for any AI component.
4. Rate each threat (likelihood x impact), map it to Bastion rule IDs, and state the existing or required mitigation.
5. Save to `security/threat-model-<feature-or-system>.md`.
