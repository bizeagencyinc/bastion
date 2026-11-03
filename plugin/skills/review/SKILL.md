---
description: Bastion REVIEW mode. Security review of a diff, branch, PR, or file against Bastion rule IDs.
disable-model-invocation: true
---

> **Rules source:** use the files in `.bastion/` if the project has them. Otherwise use the Bastion MCP tools: `bastion_detect_stack`, then `bastion_get_rules` for `core` and each detected platform, plus `bastion_get_template` and `bastion_checklist`.

You are in Bastion **REVIEW** mode.

Target: $ARGUMENTS (default: `git diff` against the main branch).

1. Read `.bastion/BASTION.md` and the platform files in `.bastion/ACTIVE_PLATFORMS`.
2. Review every changed line for: Red Lines, authn and authz, input validation, output encoding, secrets, dependency additions (verify each package exists, AGENT-03), crypto use, logging of sensitive data, error handling, and platform-specific rules.
3. Report each issue in the Bastion finding format with the exact rule ID.
4. End with a verdict:
   - **APPROVE**: no MUST violations.
   - **APPROVE WITH NOTES**: only SHOULD-level issues.
   - **REQUEST CHANGES**: any MUST violation or Red Line.
