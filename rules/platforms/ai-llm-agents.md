<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/ai-llm-agents.md` | LLM apps, chatbots, RAG, vector DBs, AI agents, MCP servers | v2.3.0 | Prefix: `LLM`

</div>

---
<!-- ========================================================== -->

# AI, LLM, and Agent Security Rules

> Applies with `BASTION.md` (Section 17). Standards: OWASP Top 10 for LLM Applications, OWASP Top 10 for Agentic Applications, MITRE ATLAS, NIST AI RMF.

## Prompt Injection

- **LLM-01** [MUST] Assume every document, web page, email, ticket, PDF, image, and tool result may contain hostile instructions (indirect prompt injection).
- **LLM-02** [MUST] Clearly delimit untrusted content in prompts and instruct the model to treat it as data.
- **LLM-03** [MUST] Never rely on the system prompt alone for security; enforce permissions in code outside the model.
- **LLM-04** [MUST NOT] Put secrets, API keys, or other users' data in system prompts; assume prompts can be extracted.

## Output Handling

- **LLM-05** [MUST] Treat model output as untrusted: escape before rendering HTML or Markdown, block auto-loading of external images and links in rendered output (data exfiltration channel), validate JSON against a schema.
- **LLM-06** [MUST NOT] Pass model output directly into SQL, shell, `eval`, file paths, or URLs without validation.

## Agents and Tools

- **LLM-07** [MUST] Give each tool the narrowest scope: read-only by default, per-user credentials, no shared admin tokens.
- **LLM-08** [MUST] Require human confirmation for irreversible or high-impact actions (send, pay, delete, deploy, change permissions).
- **LLM-09** [MUST] Run model-generated code in an isolated sandbox (container, gVisor, Firecracker, or hosted sandbox) with no network or a strict egress allowlist.
- **LLM-10** [MUST] Bound agent loops: maximum steps, maximum tokens, maximum spend, timeouts.
- **LLM-11** [MUST] Log every tool call with inputs, outputs, user, and decision, with PII redaction.

## MCP Servers and Plugins

- **LLM-12** [MUST] Install MCP servers only from trusted publishers; pin versions; review tool descriptions for hidden instructions (tool poisoning).
- **LLM-13** [MUST] Run local MCP servers with least privilege; never give them broad file system or shell access by default.
- **LLM-14** [MUST] Use OAuth with scoped tokens for remote MCP servers; never pass tokens through to downstream APIs unvalidated.
- **LLM-15** [MUST] Re-review MCP servers when their tool list or descriptions change.

## RAG and Data

- **LLM-16** [MUST] Enforce authorization at retrieval time: filter vector search by the user's tenant and permissions.
- **LLM-17** [MUST] Sanitize and provenance-tag ingested documents; quarantine content from untrusted sources.
- **LLM-18** [MUST] Do not send Restricted data to model providers without a data processing agreement and zero-retention settings where needed.

## Abuse and Cost

- **LLM-19** [MUST] Rate limit per user and per IP; cap tokens per request and spend per day.
- **LLM-20** [MUST] Moderate inputs and outputs for policy violations relevant to the product.
- **LLM-21** [MUST] Red-team before launch: jailbreaks, system prompt extraction, data exfiltration, tool misuse.

## Customer Support Chatbots

- **LLM-22** [MUST] Never let a chatbot confirm identity, change account data, issue refunds, or reveal order details without authenticated session checks in code.
- **LLM-23** [MUST] Show users they are talking to an AI and provide a path to a human (EU AI Act transparency).

## Production AI Pipeline (API, Prompt, RAG, Tools, Auth, Guardrails, Cache, Observability)

- **LLM-24** [MUST] Call model providers only from the server; keep provider API keys in a secrets manager, never in the client bundle or mobile binary.
- **LLM-25** [MUST] Set timeouts, bounded retries with backoff, and a maximum output token limit on every model API call.
- **LLM-26** [MUST] Version system prompts in source control and review changes like code; never build them by concatenating user input.
- **LLM-27** [MUST] Resolve the end user's identity and role from the server session (RBAC, OAuth/OIDC) and pass it to every retrieval and tool call; never accept identity or role from the prompt or model output.
- **LLM-28** [MUST] Run guardrails as separate checks in code before and after the model (input validation, PII and secret redaction, output schema validation, policy filters), not only as prompt text.
- **LLM-29** [MUST] Scope response and semantic caches by tenant, user permissions, model, and prompt version; never serve a cached answer across users who have different access.
- **LLM-30** [MUST NOT] Cache responses that contain personal data, secrets, or results of authorized tool calls unless the cache key includes the requesting user.
- **LLM-31** [MUST] Apply the same guardrails, data rules, and region constraints to every model a router or fallback can select; fail closed if no allowed model is available.
- **LLM-32** [MUST] Trace each request end to end (prompt version, retrieved chunk IDs, tool calls, model, tokens, cost, latency) with secrets and PII redacted.
- **LLM-33** [MUST] Maintain an eval suite (accuracy, refusal, prompt injection, data leak cases) and run it in CI on every prompt, model, or retrieval change; block release on regression.
- **LLM-34** [SHOULD] Alert on anomalies in cost, token use, tool-call rate, guardrail blocks, and eval scores in production.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | AI, LLM, and Agent Rules | MIT License | Created by <a href="https://bizeagency.com">Muhammad Faisal</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="payments.md">Payments</a></sub>
</div>
<!-- ========================================================== -->
