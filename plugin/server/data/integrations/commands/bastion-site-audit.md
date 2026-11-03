---
description: Bastion live website check. Passive, non-destructive security review of a deployed website you own (headers, TLS, cookies, exposed files, CMS, DNS email security).
---

> **Rules source:** use the files in `.bastion/` if the project has them. Otherwise use the Bastion MCP tools: `bastion_detect_stack`, then `bastion_get_rules` for `core` and each detected platform, plus `bastion_get_template` and `bastion_checklist`.

Run a **passive** security check of the live website: $ARGUMENTS

Rules of engagement:
- Only test sites the user owns or is authorized to test. Ask for confirmation of authorization before the first request.
- Passive and low-volume only: normal GET and HEAD requests, no login attempts, no fuzzing, no exploit payloads, no load testing.
- Stay on the given domain and its own subdomains.

## Checks

1. **TLS and HTTPS**: HTTP redirects to HTTPS, HSTS (max-age, includeSubDomains, preload), certificate validity and expiry date, TLS 1.0/1.1 disabled (use `curl -sI`, `openssl s_client` if available).
2. **Security headers** on the home page, login page, and one API route: CSP (no `unsafe-inline` scripts, no wildcards), `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`, frame protection, COOP. Note leaking headers (`Server`, `X-Powered-By`, framework versions).
3. **Cookies**: `Secure`, `HttpOnly`, `SameSite`, `__Host-` prefix on session cookies.
4. **Exposed files** (HEAD requests only, expect 403 or 404): `/.git/HEAD`, `/.env`, `/.DS_Store`, `/wp-config.php.bak`, `/backup.zip`, `/phpinfo.php`, `/server-status`, `/.well-known/security.txt` (should exist), source maps for main bundles.
5. **CMS and framework fingerprint**: WordPress version, `readme.html`, `xmlrpc.php` availability, `/wp-json/wp/v2/users` exposure, `?author=1` redirects; Next.js build ID and source maps; admin panels publicly reachable.
6. **CORS**: send an `Origin: https://example.org` header to the API and check whether it is reflected with credentials.
7. **Third-party scripts**: list external script origins on the home, login, and checkout pages and whether they use SRI.
8. **Mixed content and open redirects**: check `?next=`, `?redirect=`, `?url=` parameters with an external domain value (observe only, do not chain).
9. **Email domain security**: SPF, DKIM selector if known, DMARC policy (`dig TXT _dmarc.<domain>`), MTA-STS.
10. **Robots and sitemap**: anything sensitive listed in `robots.txt`.

## Output

- A table of every check: PASS, WARN, FAIL with evidence.
- Findings in the Bastion finding format mapped to rule IDs (WEB, FE, NEXT, WP, OPS, FIN).
- Exact fixes using the templates in `.bastion/templates/configs/` (headers, `.htaccess`, nginx, Next.js proxy).
- Save to `security/bastion-site-audit-<domain>-<YYYY-MM-DD>.md`.
- Offer to run `/bastion-secure` on the source code next.
