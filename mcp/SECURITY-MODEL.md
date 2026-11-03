# Bastion MCP Server: Security Model

This document explains why the Bastion MCP server is safe to trust in every repository.

## What the server can do

| Capability | Status |
|---|---|
| Read its own bundled rule files | Yes |
| Read file **names** in a folder you pass to `bastion_detect_stack` (depth 4, skips `node_modules`, `vendor`, `.git`, build folders) | Yes |
| Read small manifest files in that folder (`package.json`, `composer.json`, `requirements.txt`, `pyproject.toml`, `pubspec.yaml`, `docker-compose.yml`, max 2 MB each, depth 2) | Yes |
| Scan code text that the agent passes to `bastion_review_snippet` (in memory only) | Yes |
| Write, modify, or delete any file | **No** |
| Run shell commands or child processes | **No** |
| Make network requests | **No** |
| Read environment variables other than `BASTION_DATA_DIR` | **No** |
| Read `.env` files, keys, or credentials | **No** (only the manifest file names listed above are opened) |
| Collect telemetry | **No** |

Every tool declares MCP annotations `readOnlyHint: true`, `destructiveHint: false`, `openWorldHint: false`. The test suite fails if any tool loses these annotations.

## Supply chain

- Two runtime dependencies, pinned to exact versions: `@modelcontextprotocol/sdk` and `zod`. `package-lock.json` is committed.
- Published from GitHub Actions with **npm provenance** (`npm publish --provenance`), so anyone can verify the package was built from this repository and commit: `npm audit signatures`.
- The package contains only `src/`, `data/` (the Markdown rules and templates), `README.md`, `LICENSE`, and this file. Inspect it with `npm pack --dry-run`.
- No install scripts (`preinstall`, `install`, `postinstall`).
- Listed in the official MCP Registry under `io.github.bizeagencyinc/bastion`, which is tied to the GitHub account that owns the repository.

## Verify it yourself

```bash
npm view bastion-security-mcp dist.attestations   # provenance attestation
npm pack bastion-security-mcp --dry-run             # exact file list
npx -y bastion-security-mcp --self-test             # counts, data path
grep -rnE "child_process|fetch\(|http\.|https\.|net\.|writeFile|rmSync|unlink" node_modules/bastion-security-mcp/src
```

The last command should return nothing.

## Reporting a vulnerability

See the repository `SECURITY.md`.
