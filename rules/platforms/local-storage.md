<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/local-storage.md` | On-device and browser databases: SQLite, Room, Core Data, SwiftData, Realm, Hive, Isar, ObjectBox, Drift, MMKV, WatermelonDB, IndexedDB, localStorage, OPFS | v2.3.0 | Prefix: `LOCAL`

</div>

---
<!-- ========================================================== -->

# Local, Mobile, and Browser Storage Rules

> Applies with `BASTION.md` and the matching app platform file. Data on a user's device can be read by malware, backups, forensic tools, and anyone with the unlocked device.

## All Local Stores

- **LOCAL-01** [MUST] Store only what the app needs offline; keep Restricted data on the server.
- **LOCAL-02** [MUST] Keep tokens and keys in the platform keystore (Android Keystore, Apple Keychain, Windows DPAPI), never in a local database or preferences file.
- **LOCAL-03** [MUST] Encrypt local databases holding Confidential or Restricted data, with the key held in the keystore.
- **LOCAL-04** [MUST] Use parameterized queries in local SQL too (content providers, deep links, and sync payloads can carry injection).
- **LOCAL-05** [MUST] Wipe local data on logout and account deletion, and on server-signaled remote wipe.
- **LOCAL-06** [MUST] Validate data received from sync servers before writing it; sync is an input channel.
- **LOCAL-07** [MUST] Exclude sensitive databases from cloud backups unless encrypted with a device-bound key.

## Android (Room, SQLite, DataStore, MMKV)

- **LOCAL-08** [MUST] Use SQLCipher (via `SupportOpenHelperFactory`) for Room databases holding sensitive data.
- **LOCAL-09** [MUST] Encrypt MMKV instances with a Keystore-derived key; DataStore with Tink-encrypted values.

## Apple (Core Data, SwiftData, SQLite, Realm)

- **LOCAL-10** [MUST] Set file protection `.complete` on Core Data / SwiftData stores with sensitive data.
- **LOCAL-11** [MUST] Use SQLCipher or Realm encryption with a Keychain-stored 64-byte key for sensitive stores.

## Flutter (Hive, Isar, ObjectBox, Drift, sqflite)

- **LOCAL-12** [MUST] Open Hive boxes with `HiveAesCipher` using a key from `flutter_secure_storage`; use encrypted builds or SQLCipher for Drift and sqflite.
- **LOCAL-13** [MUST NOT] Store tokens in `SharedPreferences`, Hive without encryption, or plain JSON files.

## React Native (AsyncStorage, MMKV, WatermelonDB, op-sqlite)

- **LOCAL-14** [MUST NOT] Store tokens or PII in AsyncStorage; use `react-native-keychain` or `expo-secure-store`.
- **LOCAL-15** [MUST] Use encrypted MMKV or SQLCipher-enabled op-sqlite for sensitive offline data.

## Browser (IndexedDB, localStorage, sessionStorage, Cache API, OPFS)

- **LOCAL-16** [MUST NOT] Store auth tokens, PII, or payment data in `localStorage`, `sessionStorage`, or IndexedDB when an `HttpOnly` cookie is possible; any XSS can read them.
- **LOCAL-17** [MUST] Clear IndexedDB, Cache Storage, and service worker caches on logout (`Clear-Site-Data` header).
- **LOCAL-18** [MUST] Never cache authenticated API responses in service workers without per-user keys and logout cleanup.

## Desktop (Electron, Tauri, .NET, Python apps)

- **LOCAL-19** [MUST] Use `safeStorage` (Electron), the OS keychain (Tauri plugins, `keyring` in Python), or DPAPI for secrets; never plaintext config files.
- **LOCAL-20** [MUST] Set restrictive permissions on local database files and folders.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Local Storage Rules | MIT License | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="supabase-firebase.md">Supabase and Firebase</a></sub>
</div>
<!-- ========================================================== -->
