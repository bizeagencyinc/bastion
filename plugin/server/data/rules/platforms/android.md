<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/android.md` | Android (Kotlin, Java, Jetpack Compose) | v2.3.0 | Prefix: `AND`

</div>

---
<!-- ========================================================== -->

# Android Security Rules

> Applies with `BASTION.md`. Standard: OWASP MASVS / MASTG, Android security best practices, Google Play policies.

## Build and Configuration

- **AND-01** [MUST] Target the latest API level required by Google Play and keep `minSdk` as high as the business allows.
- **AND-02** [MUST] Enable R8 minification and obfuscation for release builds; keep mapping files private.
- **AND-03** [MUST] Set `android:debuggable` to false in release (never hardcode true) and remove debug-only libraries and logs from release variants.
- **AND-04** [MUST] Declare `android:exported` explicitly on every activity, service, receiver, and provider; default to `false`.
- **AND-05** [MUST] Protect exported components with signature-level permissions where they must be shared.
- **AND-06** [MUST] Set `android:allowBackup="false"` or define `dataExtractionRules` and `fullBackupContent` that exclude tokens, keys, and databases.
- **AND-07** [MUST] Store signing keys in Play App Signing or a secure keystore outside the repo; never commit `.jks` or `keystore.properties`.

## Network

- **AND-08** [MUST] Use a Network Security Config with `cleartextTrafficPermitted="false"` (template: `templates/configs/android-network-security-config.xml`).
- **AND-09** [SHOULD] Pin certificates or public keys for high-value APIs, with a backup pin and an expiry plan.
- **AND-10** [MUST NOT] Trust user-installed CAs in release builds or override `TrustManager` / `HostnameVerifier` to accept all.

## Storage and Keys

- **AND-11** [MUST] Generate and keep keys in the Android Keystore (StrongBox when available); mark keys non-exportable.
- **AND-12** [MUST] Encrypt sensitive local data with Keystore-backed keys (for example Tink with DataStore). Do not rely on the deprecated `security-crypto` EncryptedSharedPreferences for new code.
- **AND-13** [MUST] Use SQLCipher or equivalent for local databases holding Restricted data.
- **AND-14** [MUST NOT] Write tokens, PII, or keys to external storage, logs (`Log.d`), clipboard, or crash reports.

## Authentication

- **AND-15** [SHOULD] Use Credential Manager for passkeys, passwords, and Sign in with Google.
- **AND-16** [MUST] Use `BiometricPrompt` with a `CryptoObject` so biometric success unlocks a key, not a flag.
- **AND-17** [MUST] Open OAuth flows in Custom Tabs, never in a WebView.

## Intents, Deep Links, and IPC

- **AND-18** [MUST] Use verified App Links (`autoVerify="true"`) for auth and payment callbacks instead of custom schemes.
- **AND-19** [MUST] Validate every extra and URI from incoming intents and deep links.
- **AND-20** [MUST] Create `PendingIntent` with `FLAG_IMMUTABLE` unless mutability is required, and use explicit intents.
- **AND-21** [MUST] Restrict `FileProvider` paths to the minimum; never expose the root.
- **AND-22** [MUST] Guard content providers against SQL injection and path traversal.

## WebView

- **AND-23** [MUST] Disable JavaScript unless required; disable `setAllowFileAccess`, `setAllowContentAccess`, and universal file access.
- **AND-24** [MUST NOT] Use `addJavascriptInterface` with untrusted content, or load arbitrary URLs from intents.

## Runtime Protection

- **AND-25** [MUST] Use Play Integrity API with server-side verdict validation for sensitive operations.
- **AND-26** [SHOULD] Treat root, emulator, hooking, and tamper signals as risk inputs to the server, not as the only defense.
- **AND-27** [MUST] Use `FLAG_SECURE` on screens with credentials, OTPs, or financial data.
- **AND-28** [SHOULD] Set `filterTouchesWhenObscured` on sensitive buttons to prevent tapjacking.
- **AND-29** [MUST] Request only necessary runtime permissions and explain each one; complete the Play Data Safety form accurately.

## Release Checklist

- [ ] Release build is minified, not debuggable, no debug logs.
- [ ] All components have explicit `exported`.
- [ ] Network Security Config blocks cleartext.
- [ ] No secrets in `strings.xml`, `BuildConfig`, `gradle.properties`, or assets.
- [ ] Play Integrity verified on the server.
- [ ] MobSF or equivalent static scan clean of High findings.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Android Rules | MIT License | Created by <a href="https://bizeagency.com">Muhammad Faisal</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="ios.md">iOS</a></sub>
</div>
<!-- ========================================================== -->
