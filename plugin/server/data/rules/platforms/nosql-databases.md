<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/nosql-databases.md` | MongoDB, Redis, Valkey, Memcached, Elasticsearch, OpenSearch, DynamoDB, Cassandra, ScyllaDB, Couchbase, CouchDB, Neo4j, Cosmos DB | v2.3.0 | Prefix: `NOSQL`

</div>

---
<!-- ========================================================== -->

# NoSQL Database Security Rules

> Applies with `BASTION.md` (Section 10). Many of these engines historically shipped with no authentication and listened on all interfaces. Assume insecure defaults until proven otherwise.

## All NoSQL Engines

- **NOSQL-01** [MUST] Enable authentication and authorization on every instance, including development servers reachable from a network.
- **NOSQL-02** [MUST] Bind to private interfaces only; never expose 27017 (MongoDB), 6379 (Redis), 11211 (Memcached), 9200/9300 (Elasticsearch, OpenSearch), 9042 (Cassandra), 5984 (CouchDB), 7687/7474 (Neo4j), or 8091 (Couchbase) to the internet.
- **NOSQL-03** [MUST] Require TLS for client and inter-node traffic.
- **NOSQL-04** [MUST] Create one least-privilege user per application and environment; never connect apps as an admin or root user.
- **NOSQL-05** [MUST] Reject operator objects and type-confused input from clients (for example `{"$ne": null}`, `{"$where": ...}`, arrays where strings are expected) using strict schema validation.
- **NOSQL-06** [MUST] Encrypt data at rest and back up with encryption, immutability, and tested restores.
- **NOSQL-07** [MUST] Keep connection strings with credentials in a secrets manager, never in code, mobile apps, or client bundles.

## MongoDB (self-hosted and Atlas)

- **NOSQL-08** [MUST] Set `security.authorization: enabled` and `net.bindIp` to private addresses (template: `templates/configs/mongod-hardening.conf`).
- **NOSQL-09** [MUST] Atlas: restrict the IP Access List (never `0.0.0.0/0` in production), prefer Private Endpoints or VPC peering, and enforce MFA on Atlas accounts.
- **NOSQL-10** [MUST NOT] Use `$where`, `$function`, `$accumulator`, or `mapReduce` with user input; disable server-side JavaScript (`security.javascriptEnabled: false`) where not needed.
- **NOSQL-11** [MUST] Use Mongoose `strictQuery` / `sanitizeFilter` or `express-mongo-sanitize`-style filtering, and build queries from validated fields only.
- **NOSQL-12** [MUST] Use JSON Schema validation on collections holding critical data.
- **NOSQL-13** [SHOULD] Use Client-Side Field Level Encryption or Queryable Encryption for Restricted fields.
- **NOSQL-14** [MUST] Enable auditing (Atlas or Enterprise) for authentication and privileged actions.

## Redis, Valkey, and Memcached

- **NOSQL-15** [MUST] Enable ACL users with per-app command and key-pattern limits; disable or rename the `default` user (template: `templates/configs/redis-hardening.conf`).
- **NOSQL-16** [MUST] Keep `protected-mode yes`, bind to private interfaces, and require TLS (`tls-port`) for remote clients.
- **NOSQL-17** [MUST] Block dangerous commands for app users: `FLUSHALL`, `FLUSHDB`, `CONFIG`, `DEBUG`, `MODULE`, `SCRIPT`, `KEYS`, `SAVE`, `SHUTDOWN`, `REPLICAOF`.
- **NOSQL-18** [MUST NOT] Store sessions, tokens, or cached personal data in Redis without TTLs and without network isolation.
- **NOSQL-19** [MUST NOT] Pass user input into `EVAL` / Lua scripts as code; pass it only as `KEYS` / `ARGV`.
- **NOSQL-20** [MUST] Memcached: disable UDP (`-U 0`), bind to localhost or a private network, and enable SASL where supported.
- **NOSQL-21** [MUST] Namespace cache keys per tenant and user so cache poisoning or key collisions cannot leak data across accounts.

## Elasticsearch and OpenSearch

- **NOSQL-22** [MUST] Keep the security plugin / X-Pack security enabled with TLS on HTTP and transport layers.
- **NOSQL-23** [MUST] Use API keys or roles scoped to specific indices; enforce document-level and field-level security for multi-tenant data.
- **NOSQL-24** [MUST NOT] Pass raw user input into `query_string`, scripts (Painless), or index names; prefer `simple_query_string` or structured queries.
- **NOSQL-25** [MUST] Never expose Kibana or OpenSearch Dashboards publicly without SSO and MFA.
- **NOSQL-26** [MUST] Protect snapshots (S3, GCS, Azure) with private buckets and encryption.

## Amazon DynamoDB

- **NOSQL-27** [MUST] Use IAM policies with `dynamodb:LeadingKeys` conditions to restrict users to their own partition keys in multi-tenant tables.
- **NOSQL-28** [MUST] Enable point-in-time recovery, deletion protection, and encryption with a customer-managed KMS key for Restricted data.
- **NOSQL-29** [MUST] Use condition expressions and expression attribute values; never concatenate user input into PartiQL statements.

## Cassandra and ScyllaDB

- **NOSQL-30** [MUST] Replace `AllowAllAuthenticator` and `AllowAllAuthorizer` with `PasswordAuthenticator` and `CassandraAuthorizer`; change or drop the default `cassandra` superuser.
- **NOSQL-31** [MUST] Use prepared statements with bound values for every CQL query.
- **NOSQL-32** [MUST] Enable client-to-node and node-to-node encryption and JMX authentication.

## Couchbase and CouchDB

- **NOSQL-33** [MUST] CouchDB: never run in "admin party" mode; set admin credentials, require `require_valid_user`, and restrict `_users` and `_replicate`.
- **NOSQL-34** [MUST] Couchbase: use RBAC per bucket and parameterized N1QL / SQL++ queries.

## Neo4j and Graph Databases

- **NOSQL-35** [MUST] Use parameterized Cypher (`$param`) for every value; never build Cypher with string concatenation (Cypher injection).
- **NOSQL-36** [MUST] Restrict or disable APOC procedures that load files, URLs, or run dynamic Cypher (`apoc.load.*`, `apoc.cypher.run*`) for application users.

## Azure Cosmos DB

- **NOSQL-37** [MUST] Use Microsoft Entra ID RBAC instead of primary keys for applications; rotate or disable key-based auth.
- **NOSQL-38** [MUST] Restrict network access with private endpoints or firewall rules, and use parameterized SQL API queries.

## Release Checklist

- [ ] No database port reachable from the internet (`nmap` or cloud security group review).
- [ ] Authentication enabled; no default or admin users used by apps.
- [ ] TLS enforced for clients.
- [ ] Injection tests with operator payloads (`$ne`, `$gt`, `$where`) fail safely.
- [ ] Backups encrypted and a restore tested.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | NoSQL Database Rules | MIT License | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="vector-databases.md">Vector Databases</a></sub>
</div>
<!-- ========================================================== -->
