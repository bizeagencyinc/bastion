# Contributing to Bastion

Thank you for helping make AI-written software safer.

## Ways to contribute

- Propose a new rule or platform (use the **New rule** issue template).
- Correct a rule that is outdated or wrong (include a source link).
- Improve installers or tool integrations.
- Add templates and configs.

## Pull request checklist

- [ ] Rules follow [docs/customizing.md](docs/customizing.md): one requirement per rule, keyword first, testable.
- [ ] New rule IDs are unique and sequential; no IDs reused.
- [ ] Header and footer blocks are present on new rule and doc files.
- [ ] Sources are linked in the PR description for any standard or version claim.
- [ ] `bash -n scripts/install.sh` and `shellcheck` pass.
- [ ] The installer test in CI passes.
- [ ] `CHANGELOG.md` is updated.

## Style

- Plain, direct English. No marketing language inside rules.
- Use hyphens or colons, not long dashes.
- Name exact APIs, flags, and settings.

## Commit messages

Use Conventional Commits and cite rule IDs:

```text
feat(rules): add NEXT-22 for Server Action rate limiting
fix(installer): detect Expo projects without app.json
```
