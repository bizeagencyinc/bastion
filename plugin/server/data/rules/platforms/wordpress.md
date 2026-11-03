<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/wordpress.md` | WordPress core, themes, plugins, Elementor, WooCommerce | v2.3.0 | Prefix: `WP`

</div>

---
<!-- ========================================================== -->

# WordPress Security Rules

> Applies with `BASTION.md`, `php-laravel.md` (PHP basics), and `sql-databases.md`.

## Configuration (`wp-config.php`)

- **WP-01** [MUST] Set `DISALLOW_FILE_EDIT` true, `FORCE_SSL_ADMIN` true, unique salts, `WP_DEBUG_DISPLAY` false in production (template: `templates/configs/wp-config-hardening.php`).
- **WP-02** [MUST] Move `wp-config.php` one level above the web root where hosting allows, with permissions 400 or 440.
- **WP-03** [MUST] Use a dedicated database user with only the privileges WordPress needs.
- **WP-04** [SHOULD] Set `DISALLOW_FILE_MODS` true on managed production sites that deploy through Git.

## Server and Files

- **WP-05** [MUST] Block PHP execution in `wp-content/uploads` (template: `templates/configs/htaccess-hardening`).
- **WP-06** [MUST] Use file permissions 644 for files and 755 for directories; never 777.
- **WP-07** [MUST] Block access to `readme.html`, `license.txt`, `wp-config.php`, `.git`, `.env`, and backup files.
- **WP-08** [MUST] Disable XML-RPC unless a required service (for example Jetpack app) needs it; if needed, rate limit it.
- **WP-09** [MUST] Block author enumeration (`?author=N`) and restrict the REST `users` endpoint to authenticated users.

## Accounts

- **WP-10** [MUST] Enforce 2FA (preferably passkeys) for all administrator and editor accounts.
- **WP-11** [MUST] Limit login attempts and protect `wp-login.php` with a WAF or Turnstile.
- **WP-12** [MUST] Never use `admin` as a username; give users the lowest role that works.
- **WP-13** [MUST] Review and revoke Application Passwords regularly.

## Plugins and Themes

- **WP-14** [MUST NOT] Install nulled or pirated themes or plugins. They are a common malware source.
- **WP-15** [MUST] Only install plugins with recent updates, active support, and a clean vulnerability history (check Wordfence Intelligence, WPScan, or Patchstack databases).
- **WP-16** [MUST] Remove (not just deactivate) unused plugins and themes.
- **WP-17** [MUST] Enable automatic security updates for core and trusted plugins; test major updates on staging first.

## Custom Theme and Plugin Code

- **WP-18** [MUST] Check capability with `current_user_can()` and verify a nonce with `check_admin_referer()` / `wp_verify_nonce()` on every form, AJAX action, and admin action.
- **WP-19** [MUST] Sanitize input (`sanitize_text_field`, `sanitize_email`, `absint`, `wp_kses`) and escape output late (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`).
- **WP-20** [MUST] Use `$wpdb->prepare()` for every query with variables.
- **WP-21** [MUST] Give every `register_rest_route` a real `permission_callback`; never `__return_true` for routes that read private data or write anything.
- **WP-22** [MUST] Register `wp_ajax_nopriv_` handlers only for genuinely public actions, with rate limiting.
- **WP-23** [MUST] Validate uploaded files with `wp_check_filetype_and_ext()` and restrict MIME types.
- **WP-24** [MUST] Prefix functions, options, and hooks to avoid collisions; block direct file access with `defined( 'ABSPATH' ) || exit;`.

## Elementor and Page Builders

- **WP-25** [MUST] Restrict Custom Code, HTML widgets, and Custom CSS/JS to administrators.
- **WP-26** [MUST] Review third-party Elementor addons with the same rigor as plugins (WP-15).

## WooCommerce

- **WP-27** [MUST] Use hosted or tokenized payment gateways so card data never touches the server (see `payments.md`).
- **WP-28** [MUST] Verify order totals and coupon logic server-side; protect against card-testing with rate limits and CAPTCHA at checkout.

## Operations

- **WP-29** [MUST] Run a WAF (Cloudflare, Wordfence, Patchstack, or host-level) and malware scanning.
- **WP-30** [MUST] Keep automated, off-site, encrypted backups of files and database; test restores.
- **WP-31** [SHOULD] Replace WP-Cron with a real server cron for reliability.
- **WP-32** [MUST] Monitor file integrity of core files (`wp core verify-checksums`).

## Release Checklist

- [ ] WPScan (or equivalent) shows no known vulnerable components.
- [ ] `wp core verify-checksums` passes.
- [ ] Admins have 2FA.
- [ ] Uploads directory cannot execute PHP.
- [ ] Backups tested this month.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | WordPress Rules | MIT License | Created by <a href="https://bizeagency.com">Muhammad Faisal</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="php-laravel.md">PHP and Laravel</a></sub>
</div>
<!-- ========================================================== -->
