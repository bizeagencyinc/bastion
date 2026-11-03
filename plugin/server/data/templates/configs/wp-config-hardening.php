<?php
/**
 * BASTION TEMPLATE | wp-config.php hardening block
 * Rules: WP-01 to WP-04
 * Paste above the line: "That's all, stop editing! Happy publishing."
 * Generate fresh salts at: https://api.wordpress.org/secret-key/1.1/salt/
 */

// Disable the theme and plugin file editor in wp-admin.
define( 'DISALLOW_FILE_EDIT', true );

// Disable plugin and theme installs and updates from wp-admin (enable on Git-deployed production only).
// define( 'DISALLOW_FILE_MODS', true );

// Force HTTPS for admin and logins.
define( 'FORCE_SSL_ADMIN', true );

// Never show errors to visitors in production.
define( 'WP_DEBUG', false );
define( 'WP_DEBUG_DISPLAY', false );
define( 'WP_DEBUG_LOG', false );
@ini_set( 'display_errors', '0' );

// Automatic core updates (minor and security).
define( 'WP_AUTO_UPDATE_CORE', 'minor' );

// Limit post revisions and empty trash regularly.
define( 'WP_POST_REVISIONS', 10 );
define( 'EMPTY_TRASH_DAYS', 14 );

// Use real server cron instead of WP-Cron (WP-31). Add a system cron for wp-cron.php.
define( 'DISABLE_WP_CRON', true );

// Read secrets from the environment where the host supports it, instead of hardcoding.
// define( 'DB_PASSWORD', getenv( 'WP_DB_PASSWORD' ) );
