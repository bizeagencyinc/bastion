<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/nodejs.md` | Node.js, Bun, Deno, Express, Fastify, NestJS, Hono | v2.3.0 | Prefix: `NODE`

</div>

---
<!-- ========================================================== -->

# Node.js Backend Security Rules

> Applies with `BASTION.md`.

## Runtime

- **NODE-01** [MUST] Run an Active or Maintenance LTS version of Node.js; run as a non-root user.
- **NODE-02** [SHOULD] Use the Node.js permission model (`--permission`) or Deno permissions to restrict file system and child process access where practical.
- **NODE-03** [MUST] Set `NODE_ENV=production` and never expose stack traces to clients.

## HTTP

- **NODE-04** [MUST] Use `helmet` (Express) or `@fastify/helmet` for security headers.
- **NODE-05** [MUST] Set body size limits (`express.json({ limit })`) and request timeouts.
- **NODE-06** [MUST] Use a rate limiter backed by a shared store (Redis) in multi-instance deployments.
- **NODE-07** [MUST] Configure `trust proxy` correctly so IP-based limits cannot be spoofed with `X-Forwarded-For`.
- **NODE-08** [MUST] Configure CORS with an explicit origin list.

## Code

- **NODE-09** [MUST] Validate every request with Zod, Valibot, TypeBox, or class-validator (NestJS `ValidationPipe` with `whitelist` and `forbidNonWhitelisted`).
- **NODE-10** [MUST NOT] Use `eval`, `new Function`, `vm` for untrusted code, or `child_process.exec` with user input; use `execFile` / `spawn` with argument arrays.
- **NODE-11** [MUST] Prevent prototype pollution: reject `__proto__`, `constructor`, and `prototype` keys; avoid unsafe deep-merge libraries; use `Object.create(null)` for dictionaries.
- **NODE-12** [MUST] Prevent NoSQL injection in MongoDB by rejecting operator objects (`$ne`, `$gt`) in user input.
- **NODE-13** [MUST] Use `crypto.timingSafeEqual` for secret and signature comparison.
- **NODE-14** [MUST] Verify JWTs with an explicit algorithm allowlist, issuer, audience, and expiry (`jose` library preferred).
- **NODE-15** [MUST] Use safe regular expressions or `re2` for user-supplied patterns to prevent ReDoS.

## Packages

- **NODE-16** [MUST] Commit `package-lock.json` / `pnpm-lock.yaml` and install with `npm ci` / `pnpm install --frozen-lockfile`.
- **NODE-17** [SHOULD] Disable install scripts by default (`ignore-scripts`, pnpm `onlyBuiltDependencies`) and allow only reviewed packages.
- **NODE-18** [MUST] Run `npm audit signatures` and an SCA scanner in CI.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Node.js Rules | MIT License | Created by <a href="https://bizeagency.com">BIZ E-Agency Inc</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="python.md">Python</a></sub>
</div>
<!-- ========================================================== -->
