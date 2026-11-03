<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/supabase-firebase.md` | Supabase, Firebase, Appwrite, PocketBase, Convex, Nhost, Hasura | v2.3.0 | Prefix: `BAAS`

</div>

---
<!-- ========================================================== -->

# Supabase and Firebase Security Rules

> Applies with `BASTION.md` and `sql-databases.md`. In BaaS apps the database is reachable from the client, so database rules ARE the authorization layer.

## Supabase

- **BAAS-01** [MUST] Enable Row Level Security on every table in exposed schemas, including new ones, before any data is inserted.
- **BAAS-02** [MUST] Write explicit policies per operation (`select`, `insert`, `update`, `delete`) using `auth.uid()`; `update` policies need both `using` and `with check`.
- **BAAS-03** [MUST NOT] Ship the `service_role` or secret key to any client, mobile app, or `NEXT_PUBLIC_` variable. Clients get only the anon or publishable key.
- **BAAS-04** [MUST] Never base authorization on `user_metadata` (users can edit it); use `app_metadata` or a roles table.
- **BAAS-05** [MUST] Set `search_path = ''` on `SECURITY DEFINER` functions and revoke `EXECUTE` from `anon` / `public` where not needed.
- **BAAS-06** [MUST] Write Storage policies for every bucket; keep buckets private unless content is truly public.
- **BAAS-07** [MUST] Verify JWTs and roles in Edge Functions; store their secrets with `supabase secrets set`.
- **BAAS-08** [MUST] Run the Supabase Security Advisor and Performance Advisor after every migration and fix all errors.
- **BAAS-09** [MUST] Enable leaked-password protection, email confirmation, CAPTCHA on auth, and MFA for admin users.
- **BAAS-10** [MUST] Keep views `security_invoker = true` so they respect RLS.
- **BAAS-11** [MUST] Add pgTAP or integration tests proving one user cannot read or write another user's rows.

## Firebase

- **BAAS-12** [MUST] Never ship Firestore, Realtime Database, or Storage rules in test mode (`allow read, write: if true` or time-limited open rules).
- **BAAS-13** [MUST] Check `request.auth != null` and ownership (`request.auth.uid == resource.data.ownerId`) in rules; validate field types and allowed keys on writes.
- **BAAS-14** [MUST] Enforce App Check on Firestore, Storage, Functions, and AI endpoints.
- **BAAS-15** [MUST] Test rules with the Emulator Suite and `@firebase/rules-unit-testing` in CI.
- **BAAS-16** [MUST] Restrict Firebase / Google API keys by app and API, and set budget alerts.
- **BAAS-17** [MUST] Use custom claims set by the Admin SDK for roles, never client-written fields.
- **BAAS-18** [MUST] Keep the Admin SDK service account key out of clients and repos; prefer workload identity.

## All BaaS

- **BAAS-19** [MUST] Put business logic that involves money, roles, or cross-user data in server functions, not client code.
- **BAAS-20** [MUST] Rate limit public endpoints and set spending caps or alerts.

## Appwrite, PocketBase, Convex, Nhost, MongoDB Atlas Data API

- **BAAS-21** [MUST] Appwrite: set collection and document permissions explicitly (no `role:all` write); keep API keys with server scopes off clients.
- **BAAS-22** [MUST] PocketBase: define API rules for every collection (empty rule means admin only, `""` means public); protect `/_/` admin UI behind VPN or IP allowlist.
- **BAAS-23** [MUST] Convex: check `ctx.auth.getUserIdentity()` and ownership in every public query and mutation; use `internal` functions for privileged logic.
- **BAAS-24** [MUST] Nhost / Hasura: define row-level permissions per role and disable the console and introspection in production.
- **BAAS-25** [MUST] Never expose MongoDB Atlas or other database Data API keys in client apps.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Supabase and Firebase Rules | MIT License | Created by <a href="https://bizeagency.com">BIZ E-Agency Inc</a> | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="cloud-devops.md">Cloud and DevOps</a></sub>
</div>
<!-- ========================================================== -->
