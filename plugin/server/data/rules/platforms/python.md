<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/python.md` | Python, Django, FastAPI, Flask, automation scripts | v2.3.0 | Prefix: `PY`

</div>

---
<!-- ========================================================== -->

# Python Security Rules

> Applies with `BASTION.md`.

## General

- **PY-01** [MUST] Use a supported Python version and pin dependencies with hashes (`uv lock`, `pip-tools --generate-hashes`, or Poetry lock).
- **PY-02** [MUST] Run `pip-audit` or OSV-Scanner and `bandit` in CI.
- **PY-03** [MUST NOT] Use `pickle`, `marshal`, `shelve`, or `yaml.load` (use `yaml.safe_load`) on untrusted data.
- **PY-04** [MUST NOT] Use `eval`, `exec`, or `subprocess` with `shell=True` on user input; pass argument lists.
- **PY-05** [MUST] Use `secrets` for tokens, never `random`.
- **PY-06** [MUST] Use `hmac.compare_digest` for secret comparison.
- **PY-07** [MUST] Use `defusedxml` for XML parsing.
- **PY-08** [MUST] Set timeouts on every `requests` / `httpx` call and validate URLs against SSRF.

## Django

- **PY-09** [MUST] `DEBUG=False`, strong `SECRET_KEY` from the environment, explicit `ALLOWED_HOSTS`.
- **PY-10** [MUST] Enable `SECURE_SSL_REDIRECT`, `SECURE_HSTS_SECONDS`, `SESSION_COOKIE_SECURE`, `CSRF_COOKIE_SECURE`; run `manage.py check --deploy` in CI.
- **PY-11** [MUST] Avoid `raw()`, `extra()`, and `RawSQL` with interpolated input; avoid `mark_safe` on user content.
- **PY-12** [MUST] Move the admin to a non-default path and protect it with 2FA and IP restrictions.

## FastAPI and Flask

- **PY-13** [MUST] Validate all inputs with Pydantic models; use `response_model` to prevent excess data exposure.
- **PY-14** [MUST] Implement auth as dependencies applied to every protected router, not per handler by memory.
- **PY-15** [MUST] Disable `/docs` and `/redoc` in production or protect them.
- **PY-16** [MUST] Flask: never run the debug server in production; set a strong `SECRET_KEY` and secure cookie flags.

## Scripts and Automation

- **PY-17** [MUST] Read credentials from environment variables or a keyring, never hardcoded.
- **PY-18** [MUST] Respect target site terms and rate limits; never store scraped personal data beyond need.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Python Rules | MIT License | Created by <a href="https://bizeagency.com">Muhammad Faisal</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="sql-databases.md">SQL Databases</a></sub>
</div>
<!-- ========================================================== -->
