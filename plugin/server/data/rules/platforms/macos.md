<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/macos.md` | macOS (Swift, AppKit, SwiftUI, Electron, Tauri) | v2.3.0 | Prefix: `MAC`

</div>

---
<!-- ========================================================== -->

# macOS Security Rules

> Applies with `BASTION.md`. Standard: Apple Platform Security Guide, Hardened Runtime and notarization requirements.

## Signing and Distribution

- **MAC-01** [MUST] Sign with a Developer ID certificate and notarize every build distributed outside the Mac App Store.
- **MAC-02** [MUST] Enable Hardened Runtime.
- **MAC-03** [MUST] Request the minimum entitlements. Avoid `com.apple.security.cs.disable-library-validation`, `allow-unsigned-executable-memory`, and `allow-dyld-environment-variables` unless strictly required and documented.
- **MAC-04** [SHOULD] Enable App Sandbox with only the needed file, network, and device entitlements (template: `templates/configs/macos-entitlements.plist`).
- **MAC-05** [MUST] Sign auto-updates (for example Sparkle with EdDSA signatures) and serve the appcast over HTTPS.
- **MAC-06** [MUST] Keep signing certificates and notarization credentials in CI secrets or the Keychain, never in the repo.

## Privilege Separation

- **MAC-07** [MUST] Split privileged work into XPC services or helpers; keep the main app unprivileged.
- **MAC-08** [MUST] Validate the connecting client's code signature (audit token, team ID, and code requirement) in every XPC and privileged helper listener.
- **MAC-09** [MUST] Use `SMAppService` for login items and daemons; no setuid binaries or world-writable helper paths.
- **MAC-10** [MUST NOT] Run shell commands built from user input; use `Process` with argument arrays.

## Storage and Keys

- **MAC-11** [MUST] Store secrets in the Keychain (data protection keychain preferred) with access control.
- **MAC-12** [MUST] Set restrictive permissions (0600 / 0700) on files and directories in `Application Support`.
- **MAC-13** [MUST NOT] Load dylibs or plugins from user-writable locations (dylib hijacking).

## Privacy (TCC)

- **MAC-14** [MUST] Request Full Disk Access, Accessibility, Screen Recording, camera, and microphone only when essential, with clear explanations.
- **MAC-15** [MUST] Handle permission denial gracefully without retry loops or dark patterns.

## Electron and Tauri Apps

- **MAC-16** [MUST] Electron: `contextIsolation: true`, `nodeIntegration: false`, `sandbox: true`, `webSecurity: true`, strict CSP, and expose IPC only through a minimal, validated `contextBridge` API.
- **MAC-17** [MUST] Electron: enable security fuses (disable `RunAsNode`, enable cookie encryption, enable ASAR integrity, only load app from ASAR).
- **MAC-18** [MUST] Electron: block `will-navigate` and `setWindowOpenHandler` to unknown origins; never use `shell.openExternal` with unvalidated URLs.
- **MAC-19** [MUST] Tauri: use the capabilities and permissions system with the narrowest scopes; never enable broad `shell` or `fs` scopes.
- **MAC-20** [MUST] Keep the Electron or Tauri runtime on a supported, patched version.

## Release Checklist

- [ ] `codesign --verify --deep --strict` passes.
- [ ] `spctl -a -vv` reports notarized Developer ID.
- [ ] Entitlements reviewed and minimal.
- [ ] XPC listeners validate client signatures.
- [ ] Update feed signed and HTTPS only.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | macOS Rules | MIT License | Created by <a href="https://bizeagency.com">Muhammad Faisal</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="windows.md">Windows</a></sub>
</div>
<!-- ========================================================== -->
