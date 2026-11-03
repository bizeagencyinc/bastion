---
description: Bastion security rules. Use whenever writing, changing, or reviewing code that touches authentication, authorization, user input, databases, secrets, file uploads, payments, banking, AI features, mobile storage, or deployment config.
---

# Bastion Security Rules

1. Never violate the 12 Red Lines. Get them with the `bastion_red_lines` tool.
2. If the project has `.bastion/`, follow `.bastion/BASTION.md`, `.bastion/PROJECT-RULES.md`, and the files in `.bastion/ACTIVE_PLATFORMS`.
3. Otherwise call `bastion_detect_stack` with the project root, then `bastion_get_rules` for `core` and each detected platform.
4. Before finishing a change to security-relevant code, run `bastion_review_snippet` on the changed code and fix real hits.
5. Cite rule IDs (for example `AUTH-04`, `NEXT-02`, `FIN-14`) in findings and commit messages.
6. For full workflows use `/bastion:secure`, `/bastion:audit`, `/bastion:review`, `/bastion:release`, `/bastion:fintech-audit`, `/bastion:site-audit`.
