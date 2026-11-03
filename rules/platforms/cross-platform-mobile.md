<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/cross-platform-mobile.md` | Flutter, React Native, Expo, Capacitor, Ionic | v2.3.0 | Prefix: `XPM`

</div>

---
<!-- ========================================================== -->

# Cross-Platform Mobile Security Rules

> Applies with `BASTION.md`, `android.md`, and `ios.md`. The native rules still apply to the generated Android and iOS projects.

## Secrets and Configuration

- **XPM-01** [MUST NOT] Put private keys or secrets in `--dart-define`, `.env` files bundled into the app, `app.json`, `expo-constants`, or the JS bundle. All of these are extractable from the binary.
- **XPM-02** [MUST] Route privileged API calls through your backend; the app holds only public, restricted keys (for example a Supabase anon key protected by RLS, or a Maps key restricted by package name and SHA-1 / bundle ID).
- **XPM-03** [MUST] Use EAS Secrets, CI secrets, or Codemagic encrypted variables for build-time credentials.

## Storage

- **XPM-04** [MUST] Use `flutter_secure_storage`, `expo-secure-store`, or `react-native-keychain` for tokens; never `SharedPreferences`, `AsyncStorage`, or `localStorage`.
- **XPM-05** [MUST] Encrypt local databases holding Restricted data (`sqflite_sqlcipher`, `op-sqlite` with SQLCipher, encrypted Hive or Isar boxes with Keystore-held keys).

## Build Hardening

- **XPM-06** [MUST] Flutter: build release with `--obfuscate --split-debug-info=<dir>` and keep symbol files private.
- **XPM-07** [MUST] React Native: ship Hermes bytecode in release, strip `console.log`, and disable the dev menu and remote debugging.
- **XPM-08** [MUST] Disable Flipper, Reactotron, network inspectors, and debug banners in release builds.

## Network

- **XPM-09** [SHOULD] Pin certificates via `http_certificate_pinning`, `dio` `badCertificateCallback` with pin verification, or `react-native-ssl-public-key-pinning`.
- **XPM-10** [MUST NOT] Return `true` unconditionally in `badCertificateCallback` or disable TLS checks "temporarily".

## OTA Updates

- **XPM-11** [MUST] Sign over-the-air updates (EAS Update code signing, Shorebird, or CodePush signing) and verify on device.
- **XPM-12** [MUST] Never use OTA updates to bypass store review for changes in native permissions or core functionality.

## WebViews and Bridges

- **XPM-13** [MUST] Restrict `webview_flutter` / `react-native-webview` navigation to an allowlist; disable JavaScript bridges for untrusted origins.
- **XPM-14** [MUST] Capacitor and Cordova: lock down `allowNavigation`, use a strict CSP, and audit every plugin's native permissions.

## Packages

- **XPM-15** [MUST] Audit pub.dev and npm packages for publisher verification, popularity, maintenance, and native permission requests before adding.
- **XPM-16** [MUST] Run `flutter pub outdated` / `npm audit` (or OSV-Scanner) in CI.

## Delivery and Super Apps (Orders, Riders, Wallets)

- **XPM-17** [MUST] Calculate prices, delivery fees, discounts, and wallet balances on the server only.
- **XPM-18** [MUST] Validate rider and customer GPS location server-side for plausibility (speed, jumps, mock-location flags).
- **XPM-19** [MUST] Use short-lived, single-use OTPs for delivery handover and verify them on the server.
- **XPM-20** [MUST] Mask customer phone numbers and addresses from riders after order completion.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Cross-Platform Mobile Rules | MIT License | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="web-frontend.md">Web Frontend</a></sub>
</div>
<!-- ========================================================== -->
