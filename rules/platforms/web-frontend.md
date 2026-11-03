<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/web-frontend.md` | Websites, HTML/CSS/JS, React, Vue, Svelte, Angular, Vite | v2.3.0 | Prefix: `FE`

</div>

---
<!-- ========================================================== -->

# Website and Frontend Security Rules

> Applies with `BASTION.md`. Use with `nextjs.md` for Next.js and `wordpress.md` for WordPress.

## Static and Single-File Sites

- **FE-01** [MUST] Serve over HTTPS with HSTS; redirect HTTP to HTTPS at the server or CDN.
- **FE-02** [MUST] Add security headers at the host (Netlify `_headers`, Vercel `vercel.json`, Cloudflare rules, `.htaccess`, or nginx). Templates in `templates/configs/`.
- **FE-03** [MUST] Process contact and lead forms server-side with validation, rate limiting, and CAPTCHA or Turnstile; never send email from the browser with exposed SMTP or API keys.
- **FE-04** [MUST] Use `rel="noopener noreferrer"` on `target="_blank"` links to external sites.
- **FE-05** [MUST] Load chat widgets (tawk.to, Intercom), analytics, and pixels only from known origins listed in CSP, and review what data they collect.
- **FE-06** [MUST] Publish `/.well-known/security.txt`, a privacy policy, and a cookie notice where required.

## Single-Page Apps (React, Vue, Svelte, Angular)

- **FE-07** [MUST] Use the framework's auto-escaping; avoid `dangerouslySetInnerHTML`, `v-html`, `{@html}`, `[innerHTML]`, and `bypassSecurityTrust*`. If unavoidable, sanitize with DOMPurify.
- **FE-08** [MUST] Validate URLs before putting them in `href` or `src` (block `javascript:` and `data:`).
- **FE-09** [MUST] Keep auth tokens in `HttpOnly` cookies via a backend-for-frontend; no tokens in `localStorage`.
- **FE-10** [MUST] Treat every `VITE_`, `REACT_APP_`, `PUBLIC_`, and `NUXT_PUBLIC_` variable as public.
- **FE-11** [MUST] Disable production source maps or upload them privately to the error tracker only.
- **FE-12** [MUST] Validate `postMessage` origins and message schemas.
- **FE-13** [MUST] Avoid open redirects: only allow relative paths or allowlisted hosts in `?next=` / `?redirect=` parameters.

## Dependencies and Third-Party Scripts

- **FE-14** [MUST] Self-host or use SRI for CDN scripts; pin versions.
- **FE-15** [MUST] Run `npm audit` / OSV-Scanner in CI; remove unused packages.
- **FE-16** [MUST] Maintain an inventory of every script on payment and login pages and detect unauthorized changes.

## Release Checklist

- [ ] securityheaders.com grade A or better.
- [ ] CSP has no `unsafe-inline` for scripts and no wildcard sources.
- [ ] No secrets in built JS (`grep` the `dist/` output).
- [ ] Forms are protected against spam and abuse.
- [ ] Mozilla Observatory scan reviewed.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Web Frontend Rules | MIT License | Created by <a href="https://bizeagency.com">BIZ E-Agency Inc</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="nextjs.md">Next.js</a></sub>
</div>
<!-- ========================================================== -->
