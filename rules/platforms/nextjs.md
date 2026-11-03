<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/nextjs.md` | Next.js (App Router and Pages Router), React Server Components | v2.3.0 | Prefix: `NEXT`

</div>

---
<!-- ========================================================== -->

# Next.js Security Rules

> Applies with `BASTION.md` and `web-frontend.md`. Verify the current Next.js and React security advisories before every release.

## Patching

- **NEXT-01** [MUST] Run a supported, fully patched Next.js and React version. Critical issues have affected middleware authorization (CVE-2025-29927) and React Server Components; patch within 72 hours of a Critical advisory.

## Server and Client Boundary

- **NEXT-02** [MUST] Treat every Server Action and Route Handler as a public HTTP endpoint: authenticate, authorize, and validate input (Zod or Valibot) inside each one.
- **NEXT-03** [MUST NOT] Use middleware as the only authorization layer. Re-check the session and permissions in the data access layer.
- **NEXT-04** [MUST] Put all data access in a server-only Data Access Layer; import `server-only` in those modules.
- **NEXT-05** [MUST] Return DTOs with only the needed fields from server components to client components; never pass whole database rows.
- **NEXT-06** [SHOULD] Use React taint APIs (`experimental_taintObjectReference`, `experimental_taintUniqueValue`) for secrets and sensitive objects where available.
- **NEXT-07** [MUST] Only variables prefixed `NEXT_PUBLIC_` reach the browser; never prefix secrets with it.
- **NEXT-08** [MUST] Validate all environment variables at startup with a schema (for example `@t3-oss/env-nextjs`).

## Headers and CSP

- **NEXT-09** [MUST] Set security headers in `next.config` `headers()` or middleware; generate a per-request nonce for a strict CSP (template: `templates/configs/nextjs-security-headers.ts`).
- **NEXT-10** [MUST] Set `poweredByHeader: false` and `productionBrowserSourceMaps: false`.

## Auth and Sessions

- **NEXT-11** [MUST] Use a maintained auth library (Auth.js, Better Auth, Clerk, Supabase Auth, Lucia patterns) with `HttpOnly` session cookies.
- **NEXT-12** [MUST] Protect Server Actions from CSRF by relying on Next.js origin checks and configuring `serverActions.allowedOrigins` narrowly when behind proxies.

## Data and Caching

- **NEXT-13** [MUST] Never cache personalized or authenticated responses in shared caches; set `dynamic` / `no-store` correctly and verify cache keys.
- **NEXT-14** [MUST] Protect on-demand revalidation and cron endpoints with a secret and constant-time comparison.
- **NEXT-15** [MUST] Restrict `next/image` `remotePatterns` to known hosts to prevent SSRF and abuse.

## Redirects and Rendering

- **NEXT-16** [MUST] Validate `redirect()` targets against an allowlist (no open redirects).
- **NEXT-17** [MUST] Avoid `dangerouslySetInnerHTML`; sanitize Markdown and MDX output from users.

## Deployment (Vercel, Hostinger, VPS, Docker)

- **NEXT-18** [MUST] Store secrets in the platform's encrypted environment variables per environment; rebuild after changing build-time variables.
- **NEXT-19** [MUST] Protect preview deployments (Vercel Deployment Protection or password) so they do not expose unreleased features or data.
- **NEXT-20** [MUST] Enable a WAF and rate limiting for auth, Server Actions, and API routes (Vercel Firewall, Cloudflare, or Upstash rate limit).
- **NEXT-21** [MUST] For self-hosting, run `next start` as a non-root user behind a reverse proxy with TLS.

## Release Checklist

- [ ] `npm audit` and Next.js advisories reviewed.
- [ ] Every Server Action has auth, authz, and schema validation.
- [ ] No secrets in `.next/static` (`grep` the build).
- [ ] CSP with nonce verified in production.
- [ ] Preview deployments protected.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Next.js Rules | MIT License | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="wordpress.md">WordPress</a></sub>
</div>
<!-- ========================================================== -->
