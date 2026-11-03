<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

<img src="assets/logo.svg" width="56" alt="Bastion logo" />

**BASTION** | Security Rules for AI Coding Agents

`HANDOVER.md` | Handover to Claude Code: Publish | v2.3.0

</div>

---
<!-- ========================================================== -->

# Handover to Claude Code: Publish Bastion v2.3.0

## Status

| Area | Status |
|---|---|
| Rules: 692 IDs (158 core + 534 in 21 platform files incl. databases and banking) | Done |
| Installers (Bash, PowerShell) with stack detection, project rules, `--with-ci`, `--with-mcp` | Bash tested; **PowerShell not yet run** (CI runs it on Windows) |
| Guard hook | Done, tested |
| MCP server `mcp/` (9 read-only tools, 10 prompts, 3 resources) | Done, 8 end-to-end tests pass; health check `√ Connected` in Claude Code 2.1.317 |
| npm package `bastion-security-mcp` | Packs and runs from tarball; **not published** |
| Claude Code plugin `plugin/` + marketplace `.claude-plugin/marketplace.json` | `claude plugin validate` passed for both; installed and listed 11 skills, 1 hook, 1 MCP server |
| MCP Registry `mcp/server.json` | Written; **not published** |
| Publish workflow `.github/workflows/publish.yml` | Written; **not run** |
| GitHub repository | **Not created** |

## Rules for this handover

- Ask the user before: creating the repo, pushing, publishing to npm, publishing to the MCP Registry, creating a release, or changing repo settings (AGENT-07).
- Never print or store tokens. Use `gh auth`, `npm login`, and OIDC.
- Do not use em dashes in any file.

## Tasks (in order)

### A. Prepare

1. `git init -b main` in this folder.
2. Get the GitHub username: `gh api user -q .login`. Replace every `bizeagencyinc` in the repo (README, docs, `mcp/`, `plugin/` sources via `mcp/scripts/build-plugin.js`, `.github/ISSUE_TEMPLATE/config.yml`). Then rebuild the plugin: `cd mcp && npm ci && npm run build:plugin`.
3. Check the npm name is free: `npm view bastion-security-mcp`. A 404 means free. If taken, ask the user for a new name (for example `@<npm-user>/bastion-mcp`) and update `mcp/package.json`, `mcp/server.json`, docs, the installers, and `build-plugin.js`.
4. Run all checks from `CLAUDE.md`, plus `cd mcp && npm test`, plus `claude plugin validate ./plugin` and `claude plugin validate .`.
5. If `pwsh` is available, run the PowerShell installer on a temp fixture and compare with the Bash output.
6. Pin GitHub Actions to commit SHAs in all workflows (OPS-02): `gh api repos/<owner>/<repo>/commits/<tag> -q .sha`, keep the tag as a comment.

### B. GitHub

7. **Ask first**, then:

   ```bash
   gh repo create bastion --public --source . --push \
     --description "Security rules for AI coding agents: 681 rules, 21 platforms, MCP server, Claude Code plugin. Web, mobile, databases, cloud, AI, banking."
   gh repo edit --add-topic security,mcp,mcp-server,claude-code,claude-code-plugin,cursor,copilot,owasp,devsecops,appsec,fintech,llm-security
   ```

8. Turn on secret scanning with push protection, Dependabot alerts and security updates, private vulnerability reporting, and branch protection on `main` (PR review plus the `Validate Bastion` checks).
9. Create a GitHub environment named `release` with the user as required reviewer (the publish jobs use it).
10. Wait for CI: `gh run watch`. Fix failures, especially the Windows installer job.

### C. npm

11. The user runs `npm login` (interactive; do not handle their password).
12. **Ask first**, then do the first publish by hand from `mcp/`: `npm publish --access public` (provenance needs CI, so it is added from the next release on).
13. Ask the user to set up **Trusted Publishing** on npmjs.com for `bastion-security-mcp`: GitHub Actions, repository `<owner>/bastion`, workflow `publish.yml`, environment `release`. After that, CI publishes with provenance and no token.

### D. MCP Registry

14. Validate: install `mcp-publisher` (`brew install mcp-publisher`, or the release binary), then in `mcp/`: `mcp-publisher validate`.
15. **Ask first**, then `mcp-publisher login github` and `mcp-publisher publish`. Verify: `curl "https://registry.modelcontextprotocol.io/v0.1/servers?search=io.github.<owner>/bastion"`.

### E. Release

16. **Ask first**, then tag and push: `git tag v2.3.0 && git push origin v2.3.0`. The publish workflow verifies versions, tests, checks plugin sync, publishes npm with provenance, publishes to the MCP Registry, and creates the GitHub release with notes from `CHANGELOG.md`. (If npm 2.3.0 was already published by hand in step 12, the npm job will fail on the duplicate version; that is expected for the first release. Approve only the remaining jobs or bump to 2.3.1.)
17. Verify the install paths on this machine:

    ```bash
    claude plugin marketplace add <owner>/bastion && claude plugin install bastion@bastion-security
    claude mcp add --scope user bastion -- npx -y bastion-security-mcp
    claude mcp list        # expect: bastion ... √ Connected
    ```

### F. Finish

18. Tell the user to upload `assets/cover.png` in **Settings > General > Social preview**.
19. Optional, ask first: submit the plugin to Anthropic's plugin directory and list the server on other MCP directories.
20. Dogfood: ask which of the user's projects to protect, run the installer there with `--with-mcp`, and run `/bastion:secure`.

## Paste this into Claude Code

```text
You are taking over the Bastion repository in this folder. Read CLAUDE.md and HANDOVER.md first.
Complete the tasks in HANDOVER.md in order (A to F) and keep a short status table.
Ask me before creating the GitHub repo, pushing, publishing to npm or the MCP Registry,
tagging a release, or changing repo settings. Never print tokens. Do not use em dashes.
```

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Handover | MIT License | <a href="README.md">Home</a> | <a href="CLAUDE.md">Maintainer Guide</a> | <a href="docs/mcp.md">MCP and Plugin</a></sub>
</div>
<!-- ========================================================== -->
