<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/ios.md` | iOS and iPadOS (Swift, SwiftUI, UIKit) | v2.3.0 | Prefix: `IOS`

</div>

---
<!-- ========================================================== -->

# iOS Security Rules

> Applies with `BASTION.md`. Standard: OWASP MASVS / MASTG, Apple Platform Security Guide, App Store Review Guidelines.

## Network

- **IOS-01** [MUST] Keep App Transport Security enabled; no `NSAllowsArbitraryLoads`. Any exception must be per-domain and justified.
- **IOS-02** [SHOULD] Pin public keys for high-value APIs (NSPinnedDomains or URLSession delegate) with a backup pin.
- **IOS-03** [MUST NOT] Accept all certificates in `URLSessionDelegate` challenge handlers.

## Storage and Keys

- **IOS-04** [MUST] Store tokens and secrets in the Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` (or `AfterFirstUnlockThisDeviceOnly` for background needs).
- **IOS-05** [SHOULD] Use Secure Enclave keys (CryptoKit `SecureEnclave.P256`) for signing and key agreement.
- **IOS-06** [MUST] Apply Data Protection `NSFileProtectionComplete` to files holding sensitive data.
- **IOS-07** [MUST NOT] Store secrets in `UserDefaults`, `Info.plist`, `.xcconfig` committed to Git, Core Data without encryption, or logs.
- **IOS-08** [MUST] Exclude sensitive files from iCloud and iTunes backups.

## Authentication

- **IOS-09** [SHOULD] Support passkeys via `AuthenticationServices` and Associated Domains (`webcredentials:`).
- **IOS-10** [MUST] Use `ASWebAuthenticationSession` for OAuth, never an embedded `WKWebView`.
- **IOS-11** [MUST] Gate Keychain items with `SecAccessControl` (`.biometryCurrentSet` or `.userPresence`) so biometrics unlock a key, not a boolean from `LAContext.evaluatePolicy`.
- **IOS-12** [MUST] Support Sign in with Apple when offering other third-party social logins (App Store rule).

## Links and IPC

- **IOS-13** [MUST] Use Universal Links for auth and payment callbacks instead of custom URL schemes.
- **IOS-14** [MUST] Validate every parameter from URLs, Universal Links, App Intents, widgets, and extensions.
- **IOS-15** [MUST] Share data with extensions only through App Groups with minimal scope.

## WebView

- **IOS-16** [MUST] Use `WKWebView` only; restrict navigation with an allowlist in `decidePolicyFor`.
- **IOS-17** [MUST NOT] Expose sensitive native functions through `WKScriptMessageHandler` to untrusted content.

## Privacy and Platform Requirements

- **IOS-18** [MUST] Ship an accurate `PrivacyInfo.xcprivacy` privacy manifest, declare Required Reason APIs, and use signed third-party SDKs.
- **IOS-19** [MUST] Request only needed permissions with clear purpose strings; respect App Tracking Transparency.
- **IOS-20** [MUST] Complete App Store privacy nutrition labels accurately.

## Runtime Protection

- **IOS-21** [MUST] Use App Attest (DeviceCheck) with server-side validation for sensitive operations.
- **IOS-22** [SHOULD] Treat jailbreak and hooking signals as risk inputs to the server.
- **IOS-23** [MUST] Obscure sensitive screens in the app switcher snapshot and detect screen capture on financial screens.
- **IOS-24** [MUST] Mark OTP fields with `textContentType = .oneTimeCode` and disable autocorrect and pasteboard leaks on secret fields.
- **IOS-25** [MUST] Strip debug logging (`print`, `NSLog`) of sensitive data from release; use `os_log` privacy levels (`.private`).

## Release Checklist

- [ ] ATS has no global exceptions.
- [ ] Keychain accessibility is `ThisDeviceOnly`.
- [ ] Privacy manifest is complete and accurate.
- [ ] App Attest verified on the server.
- [ ] No secrets in the IPA (`strings` scan clean).
- [ ] Bitcode / symbols uploaded only to trusted crash services.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | iOS Rules | MIT License | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="macos.md">macOS</a></sub>
</div>
<!-- ========================================================== -->
