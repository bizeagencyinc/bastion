<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/sql-databases.md` | MySQL, MariaDB, PostgreSQL, SQL Server, Oracle, SQLite, ORMs (Prisma, Drizzle, TypeORM, Sequelize, Eloquent, Django, SQLAlchemy, EF Core) | v2.3.0 | Prefix: `SQL`

</div>

---
<!-- ========================================================== -->

# SQL Database Security Rules

> Applies with `BASTION.md` (Section 10) and any backend platform file.

## Queries

- **SQL-01** [MUST] Use parameterized queries or prepared statements for every value.
- **SQL-02** [MUST] Allowlist identifiers (table, column, `ORDER BY`, `ASC`/`DESC`) because they cannot be parameterized.
- **SQL-03** [MUST] Escape `%` and `_` in user input used inside `LIKE` patterns.
- **SQL-04** [MUST] Review every ORM raw query (`$queryRawUnsafe`, `sequelize.query`, `DB::raw`, `.raw()`, `text()`) as a potential injection point.
- **SQL-05** [MUST NOT] Build dynamic SQL inside stored procedures with string concatenation (`EXEC(@sql)`, `EXECUTE format()` without `%I` / `%L`).

## Accounts and Privileges

- **SQL-06** [MUST] Use separate accounts: runtime app (DML only on its schema), migrations (DDL), read-only reporting, and admin (break-glass).
- **SQL-07** [MUST NOT] Connect the application as `root`, `postgres`, `sa`, or any superuser.
- **SQL-08** [MUST] Revoke `PUBLIC` privileges on schemas and functions in PostgreSQL; set `search_path` explicitly on `SECURITY DEFINER` functions.
- **SQL-09** [MUST] Disable `LOCAL INFILE`, `xp_cmdshell`, `COPY ... PROGRAM`, and file functions unless explicitly required.

## Network and Encryption

- **SQL-10** [MUST] Bind databases to private interfaces only; never expose ports 3306, 5432, or 1433 to the internet.
- **SQL-11** [MUST] Require TLS for client connections (`sslmode=verify-full`, `REQUIRE SSL`).
- **SQL-12** [MUST] Enable encryption at rest (TDE, encrypted volumes, or managed service encryption).
- **SQL-13** [MUST] Encrypt Restricted columns at the application level (for example national IDs, bank details) with keys in KMS.

## Row-Level Security and Multi-Tenancy

- **SQL-14** [SHOULD] Use PostgreSQL RLS (`ENABLE ROW LEVEL SECURITY` plus `FORCE`) for multi-tenant tables.
- **SQL-15** [MUST] Index and filter on `tenant_id` in every multi-tenant query.

## Migrations and Operations

- **SQL-16** [MUST] Review migrations in pull requests; never run ad hoc DDL in production without approval.
- **SQL-17** [MUST] Enable audit logging (`pgaudit`, MySQL audit plugin, SQL Server Audit) for privileged and schema changes.
- **SQL-18** [MUST] Encrypt backups, store them off-site and immutable, and test restores monthly.
- **SQL-19** [MUST] Mask or synthesize data for development and testing.
- **SQL-20** [MUST] Set statement timeouts and connection limits to contain abuse and runaway queries.

## SQLite (Mobile and Desktop)

- **SQL-21** [MUST] Encrypt SQLite files holding Restricted data with SQLCipher and keystore-held keys.
- **SQL-22** [MUST] Store database files in app-private directories only.

## Oracle Database

- **SQL-23** [MUST] Use bind variables (`:name`) for every value; avoid `EXECUTE IMMEDIATE` with concatenated input, and use `DBMS_ASSERT` for unavoidable dynamic identifiers.
- **SQL-24** [MUST] Lock or remove default and sample accounts (`SCOTT`, `HR`, sample schemas) and revoke `PUBLIC` execute on `UTL_HTTP`, `UTL_TCP`, `UTL_FILE`, `UTL_SMTP`, and `DBMS_JAVA` unless required.
- **SQL-25** [MUST] Enable Unified Auditing for privileged actions and use Transparent Data Encryption for Restricted data.
- **SQL-26** [MUST] Protect the listener (port 1521) with network ACLs and require native network encryption or TLS.

## MySQL and MariaDB Specifics

- **SQL-27** [MUST] Run `mysql_secure_installation` equivalents: remove anonymous users, the test database, and remote root login.
- **SQL-28** [MUST] Set `local_infile=0`, `secure_file_priv` to a restricted directory or `NULL`, and `require_secure_transport=ON`.
- **SQL-29** [MUST] Use `caching_sha2_password` (MySQL) or `ed25519` (MariaDB) authentication plugins.

## SQL Server Specifics

- **SQL-30** [MUST] Disable `sa` or give it a strong unused password; prefer Windows or Entra ID authentication; keep `xp_cmdshell` and `CLR` disabled unless required.
- **SQL-31** [MUST] Use `sp_executesql` with parameters for dynamic SQL; never `EXEC(@sql)` with user input.
- **SQL-32** [SHOULD] Use Always Encrypted for Restricted columns.

## ORMs and Query Builders

- **SQL-33** [MUST] Prisma: avoid `$queryRawUnsafe` / `$executeRawUnsafe`; use tagged `$queryRaw` templates.
- **SQL-34** [MUST] Drizzle, Knex, Kysely: use `sql` template placeholders, never `sql.raw()` or `knex.raw()` with interpolated user input.
- **SQL-35** [MUST] TypeORM and Sequelize: use parameter objects in `query()` and `where` clauses; never interpolate into `createQueryBuilder().where("...${x}")`.
- **SQL-36** [MUST] Eloquent: avoid `whereRaw`, `orderByRaw`, `DB::raw` with user input; Django: avoid `raw()` and `extra()`; SQLAlchemy: use `text()` with bound parameters.
- **SQL-37** [MUST] Entity Framework: use `FromSql` / `FromSqlInterpolated` with parameters, never `FromSqlRaw` with concatenated strings.
- **SQL-38** [MUST] Prevent mass assignment through ORMs by mapping validated DTOs to models instead of spreading request bodies.
- **SQL-39** [MUST] Review generated migrations before applying; ORMs can silently drop columns or indexes.

## Database Admin Tools

- **SQL-40** [MUST] Never expose phpMyAdmin, Adminer, pgAdmin, or similar tools publicly; restrict by VPN or IP and enable MFA, or remove them from production.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | SQL Database Rules | MIT License | Created by <a href="https://bizeagency.com">BIZ E-Agency Inc</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="supabase-firebase.md">Supabase and Firebase</a></sub>
</div>
<!-- ========================================================== -->
