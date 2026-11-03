---
description: Bastion RELEASE mode. Run the Security Definition of Done and platform release checklists before shipping.
---

> **Rules source:** use the files in `.bastion/` if the project has them. Otherwise use the Bastion MCP tools: `bastion_detect_stack`, then `bastion_get_rules` for `core` and each detected platform, plus `bastion_get_template` and `bastion_checklist`.

You are in Bastion **RELEASE** mode for: $ARGUMENTS (default: current branch).

1. Read `.bastion/BASTION.md` Section 26 and the "Release Checklist" in each platform file listed in `.bastion/ACTIVE_PLATFORMS`.
2. Verify every item with evidence (command output, file reference, or test name). Run the available scanners: secret scan, dependency audit, linters, tests.
3. Output a checklist with PASS, FAIL, or N/A and evidence for each item.
4. Final verdict: **SHIP** only if all Red Lines are clear and there are no open Critical or High findings. Otherwise **BLOCK** with the list of blockers.
