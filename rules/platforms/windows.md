<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/windows.md` | Windows Desktop (.NET, WinUI, WPF, C++, Electron, Python apps) | v2.3.0 | Prefix: `WIN`

</div>

---
<!-- ========================================================== -->

# Windows Desktop Security Rules

> Applies with `BASTION.md`. Standard: Microsoft SDL, Windows app security guidance.

## Signing and Distribution

- **WIN-01** [MUST] Authenticode-sign every executable, DLL, installer, and update with a timestamped signature (EV or cloud signing service preferred).
- **WIN-02** [SHOULD] Package with MSIX for clean install, uninstall, and update isolation.
- **WIN-03** [MUST] Verify the signature and hash of every downloaded update before running it; serve updates over HTTPS only.
- **WIN-04** [MUST] Keep signing keys in an HSM or cloud signing service, never on developer laptops or in the repo.

## Binary Hardening

- **WIN-05** [MUST] Build with ASLR, DEP, Control Flow Guard, and `/guard:cf`; enable CET shadow stack where supported.
- **WIN-06** [MUST] Load DLLs only from absolute, trusted paths (`SetDefaultDllDirectories`, `LOAD_LIBRARY_SEARCH_SYSTEM32`) to prevent DLL hijacking.
- **WIN-07** [MUST] Install to `Program Files` (admin-writable only), not user-writable folders, when the app runs elevated.
- **WIN-08** [MUST] Run as a standard user; request elevation only for the specific operation that needs it.

## Storage and Secrets

- **WIN-09** [MUST] Protect local secrets with DPAPI (`ProtectedData`) or Windows Credential Manager.
- **WIN-10** [MUST] Apply restrictive ACLs to app data in `%LOCALAPPDATA%`.
- **WIN-11** [MUST NOT] Store license keys, API keys, or tokens in plaintext registry values or config files.

## Process and IPC

- **WIN-12** [MUST] Secure named pipes and local servers with ACLs and client verification; bind local HTTP servers to `127.0.0.1` with a random token.
- **WIN-13** [MUST NOT] Build command lines from user input; use argument arrays and quote correctly.
- **WIN-14** [MUST] Validate all file paths against traversal, UNC paths, and symbolic link attacks.

## Licensing and Anti-Tamper (Commercial Apps)

- **WIN-15** [MUST] Validate licenses on the server with signed responses; never trust a local boolean.
- **WIN-16** [SHOULD] Use code obfuscation for .NET (and Nuitka or PyArmor for Python builds) to raise reverse-engineering cost; treat it as friction, not security.
- **WIN-17** [MUST] Bind licenses to hardware fingerprints with privacy-respecting hashing and allow controlled transfers.

## Bundled Tools

- **WIN-18** [MUST] Pin and verify hashes of bundled third-party binaries (for example yt-dlp, ffmpeg) and update them through the signed update channel.

## Release Checklist

- [ ] `signtool verify /pa /v` passes on every binary.
- [ ] No unsigned DLLs in the install folder.
- [ ] SmartScreen reputation established with consistent signing identity.
- [ ] Defender and VirusTotal scans clean before publishing.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Windows Rules | MIT License | Created by <a href="https://bizeagency.com">BIZ E-Agency Inc</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="cross-platform-mobile.md">Cross-Platform Mobile</a></sub>
</div>
<!-- ========================================================== -->
