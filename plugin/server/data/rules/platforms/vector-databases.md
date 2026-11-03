<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/vector-databases.md` | Pinecone, Weaviate, Qdrant, Milvus, Chroma, pgvector, LanceDB, Redis Vector, Elasticsearch kNN | v2.3.0 | Prefix: `VEC`

</div>

---
<!-- ========================================================== -->

# Vector Database Security Rules

> Applies with `BASTION.md` and `ai-llm-agents.md`. Embeddings are derived from your data and can leak it: treat vectors with the same classification as their source documents.

## Access and Isolation

- **VEC-01** [MUST] Enforce authorization at query time: filter every similarity search by tenant ID and the caller's document permissions in code, not by trusting the model.
- **VEC-02** [MUST] Isolate tenants with separate namespaces, collections, or indexes (Pinecone namespaces, Qdrant collections or payload filters, Weaviate multi-tenancy) and add a mandatory tenant filter in a shared query function.
- **VEC-03** [MUST] Use scoped, per-environment API keys; keep them server-side only.
- **VEC-04** [MUST] Enable authentication on self-hosted engines (Qdrant API key, Weaviate auth, Milvus `authorizationEnabled`, Chroma auth) and bind them to private networks.

## Data Handling

- **VEC-05** [MUST] Store source document IDs and access-control metadata with every vector so deletions and permission changes can be enforced.
- **VEC-06** [MUST] Delete vectors when the source document or user is deleted (right to erasure); embeddings count as personal data when the source does.
- **VEC-07** [MUST] Do not embed secrets, credentials, or Restricted data unless the index is protected to the same level as the source system.
- **VEC-08** [MUST] Sanitize and provenance-tag ingested content; quarantine content from untrusted sources to reduce RAG poisoning and indirect prompt injection.
- **VEC-09** [SHOULD] Version embedding models and indexes so poisoned or corrupted data can be rolled back.

## Abuse and Cost

- **VEC-10** [MUST] Rate limit query and upsert endpoints and cap `top_k` and payload sizes.
- **VEC-11** [MUST] Validate metadata filters from clients against an allowlist; never pass raw filter objects from users to the database.

## pgvector

- **VEC-12** [MUST] Apply PostgreSQL Row Level Security to embedding tables exactly like the source tables (see `sql-databases.md` and `supabase-firebase.md`).

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Vector Database Rules | MIT License | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="data-platforms.md">Data Platforms</a></sub>
</div>
<!-- ========================================================== -->
