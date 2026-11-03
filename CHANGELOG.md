# Changelog

All notable changes to Bastion are documented here. This project follows [Semantic Versioning](https://semver.org/).

## [2.3.0] - 2026-11-03

### Added

- **MCP server** `bastion-security-mcp` (`mcp/`): 9 read-only tools (`bastion_detect_stack`, `bastion_get_rules`, `bastion_get_rule`, `bastion_search_rules`, `bastion_red_lines`, `bastion_checklist`, `bastion_review_snippet`, `bastion_get_template`, `bastion_list_platforms`), 10 prompts, 3 resources. No network, shell, or writes. End-to-end tests.
- **Claude Code plugin** (`plugin/`) and marketplace (`.claude-plugin/marketplace.json`): 10 workflow skills, auto-loaded `security-rules` skill, guard hook, and a single-file bundled MCP server.
- MCP Registry metadata (`mcp/server.json`) and `mcp/SECURITY-MODEL.md`.
- `.github/workflows/publish.yml`: npm with provenance (trusted publishing), MCP Registry via GitHub OIDC, GitHub release.
- Installer `--with-mcp` / `-WithMCP` writes `.mcp.json`, `.cursor/mcp.json`, `.vscode/mcp.json`.
- `docs/mcp.md`; plugin icon `assets/icon.png`.
- 11 AI pipeline rules `LLM-24` to `LLM-34` in `ai-llm-agents.md`: server-side provider calls, call limits, versioned prompts, RBAC and OAuth identity for retrieval and tools, code-level guardrails, tenant-scoped caching, router and fallback policy, tracing, CI evals, and anomaly alerts. Total is now 692.
- Workflow commands now fall back to the MCP tools when `.bastion/` is not installed.

## [2.2.0] - 2026-11-03

### Added

- `financial-banking.md` (63 rules, prefix `FIN`): risk tiers, strong customer authentication, device binding, SIM swap protection, transaction signing, money precision, double-entry ledger, idempotency, race-condition prevention, limits and cooling-off periods, Confirmation of Payee, reconciliation, real-time fraud scoring, scam and remote-access-tool detection, Android overlay and Accessibility abuse, RASP, open banking (FAPI 2.0, mTLS, DPoP, consents), HSM and tokenization, maker-checker, segregation of duties, immutable audit logs, lending, credit models, trading, crypto custody, resilience (DORA), third-party register, regulator incident reporting.
- `templates/configs/ledger-double-entry.sql`: append-only, balanced, idempotent PostgreSQL ledger with reconciliation view.
- `/bastion-fintech-audit` slash command with regulatory mapping.
- `/bastion-secure`: full pipeline (analyze, security check, plan, approval gate, fix, adapt rules, verify).
- `/bastion-site-audit`: passive live website security check.
- `.bastion/PROJECT-RULES.md`: per-project `PRJ` rules created once, preserved on updates, loaded by every tool.
- Installer self-refresh from `.bastion/scripts/`, and keeps previously active platforms on re-runs.
- New cover with languages, frameworks, databases, and platforms; `scripts/build-cover.py` generator.
- Financial regulations added to `STD-02`.

## [2.1.0] - 2026-11-03

### Added

- `nosql-databases.md` (38 rules): MongoDB, Redis, Valkey, Memcached, Elasticsearch, OpenSearch, DynamoDB, Cassandra, ScyllaDB, Couchbase, CouchDB, Neo4j, Cosmos DB.
- `vector-databases.md` (12 rules): Pinecone, Weaviate, Qdrant, Milvus, Chroma, pgvector, LanceDB.
- `data-platforms.md` (20 rules): Neon, PlanetScale, Turso, CockroachDB, Aurora, Cloud SQL, Azure SQL, BigQuery, Snowflake, Redshift, Databricks, ClickHouse, InfluxDB, TimescaleDB, ETL.
- `local-storage.md` (20 rules): SQLite, Room, Core Data, SwiftData, Realm, Hive, Isar, ObjectBox, Drift, MMKV, WatermelonDB, IndexedDB, localStorage, OPFS.
- SQL rules for Oracle, MySQL/MariaDB, SQL Server specifics, ORMs (Prisma, Drizzle, Knex, TypeORM, Sequelize, Eloquent, Django, SQLAlchemy, EF Core), and DB admin tools (`SQL-23` to `SQL-40`).
- BaaS rules for Appwrite, PocketBase, Convex, Nhost/Hasura (`BAAS-21` to `BAAS-25`).
- Templates: `mongod-hardening.conf`, `redis-hardening.conf`.
- Guard hook blocks database connection strings with embedded passwords (localhost excluded).
- Stack detection for all new databases.
- `HANDOVER.md` and `CLAUDE.md` for continuing work in Claude Code.

## [2.0.0] - 2026-11-03

### Added

- Rule IDs for every rule (505 total) with RFC 2119 keywords.
- The 12 Red Lines.
- Six operating modes: AUDIT, HARDEN, BUILD, REVIEW, INCIDENT, RELEASE.
- Agent self-defense rules (`AGENT-01` to `AGENT-10`).
- 16 platform rule files: Android, iOS, macOS (Electron, Tauri), Windows, cross-platform mobile, web frontend, Next.js, WordPress, PHP/Laravel, Node.js, Python, SQL, Supabase/Firebase, cloud/DevOps/VPS/RDP, AI/LLM/agents/MCP, payments.
- Installers for Bash and PowerShell with stack auto-detection.
- Native integrations for Claude Code, VS Code, GitHub Copilot, Cursor, Windsurf, Cline, Codex (AGENTS.md), and Gemini CLI.
- Seven slash commands.
- Claude Code guard hook and permission deny list.
- Templates: threat model, findings report, SECURITY.md, security.txt, env.example, Next.js CSP, nginx, .htaccess, wp-config, Android network security config, macOS entitlements, Supabase RLS, GitHub security workflow, Dependabot.
- Security scorecard and Security Definition of Done.
- Updated standards: OWASP Top 10 2025, ASVS 5.0, OWASP LLM and Agentic Top 10, NIST CSF 2.0, NIST SP 800-63-4, post-quantum cryptography, PCI DSS 4.x, EU CRA, EU AI Act.

## [1.0.0] - 2026

### Added

- Original master prompt for application security engineering.
