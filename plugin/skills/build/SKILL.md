---
description: Bastion BUILD mode. Build a new feature that is secure by default from the first line.
disable-model-invocation: true
---

> **Rules source:** use the files in `.bastion/` if the project has them. Otherwise use the Bastion MCP tools: `bastion_detect_stack`, then `bastion_get_rules` for `core` and each detected platform, plus `bastion_get_template` and `bastion_checklist`.

You are in Bastion **BUILD** mode. Feature: $ARGUMENTS

1. Read `.bastion/BASTION.md` and the platform files in `.bastion/ACTIVE_PLATFORMS`.
2. Before coding, write a short security design (10 lines max): data touched and its classification, who can do what, trust boundaries, inputs, abuse cases.
3. Implement with: server-side authz, schema validation, safe queries, output encoding, rate limits where public, audit logging, no new secrets in code.
4. If you add a dependency, verify it exists on the official registry and justify it (AGENT-03).
5. Write tests including at least one negative security test (for example user B cannot access user A's resource).
6. Finish with the rule IDs you applied.
