<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/data-platforms.md` | Serverless SQL (Neon, PlanetScale, Turso, CockroachDB, Aurora, Cloud SQL, Azure SQL), warehouses (BigQuery, Snowflake, Redshift, ClickHouse, Databricks), time-series (InfluxDB, TimescaleDB) | v2.3.0 | Prefix: `DWH`

</div>

---
<!-- ========================================================== -->

# Managed, Serverless, and Analytics Database Rules

> Applies with `BASTION.md` and `sql-databases.md`.

## Managed and Serverless SQL

- **DWH-01** [MUST] Use private networking (VPC peering, Private Link, private IP) or IP allowlists; avoid public endpoints open to `0.0.0.0/0`.
- **DWH-02** [MUST] Prefer IAM or OIDC database authentication (RDS IAM auth, Cloud SQL IAM, Entra ID for Azure SQL) over static passwords where supported.
- **DWH-03** [MUST] Enable MFA and SSO on the provider console (Neon, PlanetScale, Turso, Cockroach Cloud, AWS, GCP, Azure).
- **DWH-04** [MUST] Use separate branches or databases for preview environments, seeded with masked data; never point preview deployments at production.
- **DWH-05** [MUST] Turso / libSQL: issue short-lived, database-scoped auth tokens; use read-only tokens where writes are not needed; never ship full-access tokens to clients.
- **DWH-06** [MUST] Enable automated backups, point-in-time recovery, and deletion protection on production instances.
- **DWH-07** [MUST] Enforce TLS with certificate verification in connection strings.

## Data Warehouses (BigQuery, Snowflake, Redshift, Databricks, ClickHouse)

- **DWH-08** [MUST] Grant access through roles mapped to groups; no shared logins; service accounts per pipeline with least privilege.
- **DWH-09** [MUST] Snowflake: enforce MFA or key-pair auth for all users, network policies, and disable password-only service users.
- **DWH-10** [MUST] Apply column masking and row access policies (Snowflake masking policies, BigQuery policy tags and row-level security, Redshift RLS) to PII and financial data.
- **DWH-11** [MUST] Use parameterized queries in dashboards, notebooks, and BI tools; never concatenate user filters into SQL.
- **DWH-12** [MUST] Prevent public sharing of datasets, buckets, and dashboards; review `allUsers` and `allAuthenticatedUsers` grants in BigQuery.
- **DWH-13** [MUST] ClickHouse: set a password for the `default` user (or remove it), restrict `<networks>`, and disable HTTP interface access from the internet.
- **DWH-14** [MUST] Log and alert on bulk exports and unusual query volumes.
- **DWH-15** [SHOULD] Set query cost and byte-scan limits to prevent runaway costs and denial of wallet.

## Time-Series (InfluxDB, TimescaleDB, Prometheus storage)

- **DWH-16** [MUST] Use scoped tokens per bucket or database with read or write only as needed.
- **DWH-17** [MUST] Never expose InfluxDB (8086) or Prometheus (9090) publicly without authentication.
- **DWH-18** [MUST] Set retention policies so telemetry with personal data is not kept longer than needed.

## ETL and Pipelines

- **DWH-19** [MUST] Store pipeline credentials (Airbyte, Fivetran, dbt, Airflow) in a secrets manager and rotate them.
- **DWH-20** [MUST] Mask or tokenize PII before it lands in analytics systems where full values are not required.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Data Platform Rules | MIT License | Created by <a href="https://bizeagency.com">BIZ E-Agency Inc</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="local-storage.md">Local and Mobile Storage</a></sub>
</div>
<!-- ========================================================== -->
