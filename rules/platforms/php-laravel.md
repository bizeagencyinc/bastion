<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/php-laravel.md` | PHP 8.x, Laravel, Symfony, plain PHP | v2.3.0 | Prefix: `PHP`

</div>

---
<!-- ========================================================== -->

# PHP and Laravel Security Rules

> Applies with `BASTION.md` and `sql-databases.md`.

## Runtime

- **PHP-01** [MUST] Run a supported PHP version; set `display_errors=Off`, `expose_php=Off`, `allow_url_include=Off` in production.
- **PHP-02** [SHOULD] Restrict `disable_functions` (`exec`, `shell_exec`, `system`, `passthru`, `proc_open`, `popen`) where the app does not need them.
- **PHP-03** [MUST] Point the web root to `public/` only; never expose `vendor/`, `.env`, `storage/`, or `.git`.

## Code

- **PHP-04** [MUST] Use PDO or the ORM with bound parameters; never interpolate variables into SQL.
- **PHP-05** [MUST NOT] Call `unserialize()` on untrusted data; use JSON.
- **PHP-06** [MUST NOT] Pass user input to `include`, `require`, `eval`, `assert`, `preg_replace` with `/e`, or `extract()`.
- **PHP-07** [MUST] Use `escapeshellarg()` or, better, Symfony Process with argument arrays.
- **PHP-08** [MUST] Use `password_hash()` with `PASSWORD_ARGON2ID` and `password_verify()`.
- **PHP-09** [MUST] Use `random_bytes()` / `random_int()` for tokens, never `rand()`, `mt_rand()`, or `uniqid()`.
- **PHP-10** [MUST] Use strict comparison (`===`, `hash_equals()`) for tokens and signatures to avoid type juggling.

## Laravel

- **PHP-11** [MUST] `APP_DEBUG=false` and a unique `APP_KEY` in production; never commit `.env`.
- **PHP-12** [MUST] Use `$fillable` (not empty `$guarded`) to prevent mass assignment.
- **PHP-13** [MUST] Authorize with Policies and Gates (`$this->authorize()`, `can` middleware) on every controller action.
- **PHP-14** [MUST] Validate with Form Requests; use `{{ }}` in Blade and avoid `{!! !!}` with user content.
- **PHP-15** [MUST] Keep CSRF middleware enabled; exclude only signature-verified webhook routes.
- **PHP-16** [MUST] Apply `throttle` middleware to login, password reset, OTP, and API routes.
- **PHP-17** [MUST] Use signed URLs for temporary links and `Storage::temporaryUrl()` for private files.
- **PHP-18** [MUST] Disable Telescope, Debugbar, and Ignition in production or restrict them to admins.
- **PHP-19** [MUST] Run `composer audit` in CI.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | PHP and Laravel Rules | MIT License | Created by <a href="https://bizeagency.com">Muhammad Faisal</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="nodejs.md">Node.js</a></sub>
</div>
<!-- ========================================================== -->
