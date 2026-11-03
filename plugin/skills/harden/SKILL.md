---
description: Bastion HARDEN mode. Fix approved findings with small, tested, rule-cited changes.
disable-model-invocation: true
---

> **Rules source:** use the files in `.bastion/` if the project has them. Otherwise use the Bastion MCP tools: `bastion_detect_stack`, then `bastion_get_rules` for `core` and each detected platform, plus `bastion_get_template` and `bastion_checklist`.

You are in Bastion **HARDEN** mode.

1. Read `.bastion/BASTION.md` and the platform files in `.bastion/ACTIVE_PLATFORMS`.
2. Take the findings to fix from: $ARGUMENTS (finding IDs, a report path, or "all critical and high" from the latest file in `security/`).
3. For each finding, in severity order:
   - Explain the fix in one or two sentences.
   - Make the smallest safe change. Do not change unrelated behavior.
   - Add or update a test that fails before and passes after (TEST-05).
   - Commit message format: `fix(<area>): <summary> [<RULE-ID>]`.
4. Stop and ask before anything destructive, any credential rotation, any production change, or any change to public API behavior (AGENT-07).
5. Finish with a table: finding, rule ID, files changed, test name, status.
