<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/financial-banking.md` | Banking apps, digital wallets, fintech, lending, trading, crypto, open banking, financial websites | v2.3.0 | Prefix: `FIN`

</div>

---
<!-- ========================================================== -->

# Banking and Financial Application Security Rules

> Applies with `BASTION.md`, `payments.md`, and every platform file for the stack (Android, iOS, web, backend, database).
> In financial apps, every Medium finding that touches money movement, identity, or ledgers is treated as **High**.
>
> Map controls to the regulations that apply to your license and markets, for example: PCI DSS 4.x, PSD2 SCA (and PSD3 / PSR once in force), EU DORA, GDPR, FFIEC guidance, GLBA, NYDFS 23 NYCRR 500, SOC 2, ISO 27001, State Bank of Pakistan (SBP) technology and digital banking regulations, CBUAE, MAS TRM (Singapore), HKMA, and OSFI (Canada). Verify current requirements with your compliance team; this file is not legal advice.

## 1. Risk Tiers

| Tier | Examples | Minimum controls |
|---|---|---|
| **T1 Critical** | Transfers, payouts, card issuing, ledger, beneficiary changes, limit changes, KYC data | All FIN rules, maker-checker, transaction signing, real-time fraud scoring |
| **T2 High** | Balances, statements, profile changes, device management, support tools | Server authz, step-up auth, full audit trail |
| **T3 Standard** | Marketing pages, rates, branch locator, calculators | Core Bastion rules, anti-phishing controls |

- **FIN-01** [MUST] Classify every feature and endpoint into a risk tier in the threat model before building it.

## 2. Identity, Authentication, and Sessions

- **FIN-02** [MUST] Use strong customer authentication (two independent factors) for login, every payment, beneficiary changes, and profile changes, with dynamic linking of amount and payee where PSD2 or similar rules apply.
- **FIN-03** [MUST] Prefer passkeys or device-bound cryptographic keys (Secure Enclave, StrongBox) as the possession factor; SMS OTP is a fallback only, never the sole factor for T1 actions.
- **FIN-04** [MUST] Bind the app to the device at enrolment (key pair in hardware keystore, public key registered server-side) and require re-verification through a strong channel to bind a new device.
- **FIN-05** [MUST] Detect SIM swap and number port events (carrier APIs where available) and block OTP-based actions for a cooling period after a change.
- **FIN-06** [MUST] Use short idle timeouts (for example 5 minutes on mobile, 10 to 15 on web) and an absolute session limit; re-authenticate before T1 actions.
- **FIN-07** [MUST] Allow only one active high-privilege session per user, or show all sessions and allow remote sign-out.
- **FIN-08** [MUST] Notify the user in real time (push and email) for logins from new devices, password or MFA changes, new beneficiaries, and every outgoing transaction.
- **FIN-09** [MUST] Run identity verification (KYC) through a vetted provider with document and liveness checks; store raw ID images encrypted with restricted access and defined retention.

## 3. Transaction Integrity

- **FIN-10** [MUST] Represent money as integers in minor units or as fixed-precision decimals (`DECIMAL`, `BigDecimal`, `Decimal`); never use floating point for amounts, rates, or balances.
- **FIN-11** [MUST] Define rounding rules (for example banker's rounding) and currency precision per ISO 4217 in one shared module.
- **FIN-12** [MUST] Record money movement in an immutable double-entry ledger; balances are derived from entries, never edited directly (template: `templates/configs/ledger-double-entry.sql`).
- **FIN-13** [MUST] Make every money-moving request idempotent with a client-generated idempotency key stored with a unique constraint.
- **FIN-14** [MUST] Prevent double spending and race conditions with database transactions at an appropriate isolation level, row locks (`SELECT ... FOR UPDATE`) or optimistic version checks, and balance check plus debit in one atomic operation.
- **FIN-15** [MUST] Sign transactions on the device: the user approves a summary (amount, currency, payee, account) that is cryptographically signed by the device key and verified server-side (what you see is what you sign).
- **FIN-16** [MUST] Re-validate every field of a transaction on the server: amount limits, currency, account ownership, beneficiary status, available balance, and sanctions result.
- **FIN-17** [MUST] Apply per-transaction, daily, and monthly limits by user, account, device, and channel; limit increases require step-up auth and a cooling-off delay.
- **FIN-18** [MUST] Apply a cooling-off period and lower limits for newly added beneficiaries and newly bound devices.
- **FIN-19** [MUST] Show payee name verification (Confirmation of Payee / Verification of Payee) where the payment scheme supports it, and warn on mismatches.
- **FIN-20** [MUST] Reconcile the internal ledger with bank, card network, and payment provider statements at least daily, and alert on any unexplained difference.
- **FIN-21** [MUST] Use state machines for transaction status (`pending`, `authorized`, `settled`, `reversed`, `failed`) with only allowed transitions enforced in code and the database.

## 4. Fraud and Abuse Prevention

- **FIN-22** [MUST] Score every T1 action in real time using device, behavior, location, velocity, amount, and payee risk; hold or step up high-risk actions.
- **FIN-23** [MUST] Detect account takeover signals: new device plus password reset plus new payee plus large transfer in a short window.
- **FIN-24** [MUST] Warn users about authorised push payment scams with context-specific messages (investment, romance, impersonation, "safe account") before high-risk transfers.
- **FIN-25** [MUST] Detect remote access and screen-sharing tools (AnyDesk, TeamViewer, and similar) and active phone calls during T1 actions on mobile, and block or step up.
- **FIN-26** [MUST] On Android, detect overlay attacks and abuse of Accessibility Services by untrusted apps (common in banking trojans), and protect T1 screens.
- **FIN-27** [MUST] Rate limit and monitor enumeration of account numbers, IBANs, phone numbers, and card BINs.
- **FIN-28** [MUST] Run sanctions and PEP screening on customers and payees, and transaction monitoring for AML patterns, with case management for alerts.

## 5. Mobile Banking App Hardening

- **FIN-29** [MUST] Apply app shielding / RASP: anti-tampering, anti-debugging, anti-hooking (Frida, Xposed), emulator and root/jailbreak detection, reported to the server as risk signals.
- **FIN-30** [MUST] Use Play Integrity and App Attest on every session start and T1 action, verified server-side.
- **FIN-31** [MUST] Pin certificates or public keys for banking APIs with a backup pin and a forced-update path.
- **FIN-32** [MUST] Block screenshots and screen recording on screens with balances, card numbers, OTPs, and statements (`FLAG_SECURE`, iOS capture detection), and blur the app switcher snapshot.
- **FIN-33** [MUST] Support forced updates and remote kill switch for vulnerable app versions.
- **FIN-34** [MUST] Never store full card numbers, CVV, PINs, or plaintext account credentials on the device; show masked values and fetch full values only on explicit, authenticated request.
- **FIN-35** [MUST] Use a secure in-app keyboard or disable keyboard caching, autocorrect, and clipboard on PIN and credential fields.

## 6. Web Banking and Financial Websites

- **FIN-36** [MUST] Enforce HSTS preload, strict CSP, and script integrity monitoring on all logged-in and payment pages.
- **FIN-37** [MUST] Set DMARC to `p=reject`, publish BIMI where possible, and monitor look-alike domains and app store clones for takedown.
- **FIN-38** [MUST NOT] Put clickable links in SMS or emails that lead to login pages; teach users to open the app or type the address.
- **FIN-39** [MUST] Protect against clickjacking, CSRF, and session riding on every state-changing request, including logout.
- **FIN-40** [MUST] Make public calculators and rate pages tamper-proof: rates come from the server and are signed or cached server-side, never trusted from the client at application time.

## 7. Open Banking and Financial APIs

- **FIN-41** [MUST] Follow FAPI 2.0 Security Profile (or the profile mandated in your market): PAR, PKCE, sender-constrained tokens with mTLS or DPoP, and signed requests where required.
- **FIN-42** [MUST] Use fine-grained, time-limited, revocable consents; show users which third parties have access and let them revoke.
- **FIN-43** [MUST] Use mutual TLS and allowlisting for bank, card network, and partner connections; rotate certificates before expiry.
- **FIN-44** [MUST] Verify every webhook from banks, card processors, and aggregators (Plaid, TrueLayer, Tink, and similar) with signatures and replay protection.

## 8. Keys, Cryptography, and Card Data

- **FIN-45** [MUST] Keep master and signing keys in an HSM or cloud HSM (FIPS 140-3 validated where required), with dual control and split knowledge for key ceremonies.
- **FIN-46** [MUST] Tokenize card and account numbers; keep the token vault in a separate, minimal-access environment.
- **FIN-47** [MUST] Encrypt PII and financial data at field level with keys separated by data class and tenant.
- **FIN-48** [SHOULD] Start post-quantum migration planning for long-lived financial records and signatures (Section 14 of `BASTION.md`).

## 9. Internal Operations and Back Office

- **FIN-49** [MUST] Enforce maker-checker (four eyes) for manual adjustments, refunds above threshold, limit overrides, account unfreezes, and configuration changes to fees, rates, and fraud rules.
- **FIN-50** [MUST] Segregate duties: developers cannot access production data; support agents see masked data; no single person can create and approve a payment.
- **FIN-51** [MUST] Put back-office and admin tools behind SSO, phishing-resistant MFA, device posture checks, and IP or zero-trust access; never on the public internet without these.
- **FIN-52** [MUST] Record every access to customer financial data by staff with reason codes, and review access logs regularly.
- **FIN-53** [MUST] Keep audit logs immutable (WORM storage or hash chaining) and retained for the period required by your regulators.

## 10. Lending, Credit, Trading, and Crypto

- **FIN-54** [MUST] Lending: compute interest, fees, and schedules on the server with tested, versioned formulas; keep an audit trail of every decision and the data used.
- **FIN-55** [MUST] Credit and fraud models: document model governance, explainability, bias testing, and change approval; protect model inputs from manipulation.
- **FIN-56** [MUST] Trading: validate order price, quantity, and instrument server-side, prevent duplicate orders, timestamp with synchronized clocks, and keep complete order audit trails.
- **FIN-57** [MUST] Crypto custody: keep most funds in cold storage, use MPC or multisig for hot wallets, allowlist withdrawal addresses with delays, and never store seed phrases in code, databases, or logs.
- **FIN-58** [MUST] Crypto: verify deposit confirmations to a safe depth per chain and protect against address-replacement (clipboard) attacks with address checks in the UI.

## 11. Resilience and Compliance Operations

- **FIN-59** [MUST] Define RTO and RPO for T1 services, run disaster recovery drills at least yearly, and document results (DORA and similar regulations).
- **FIN-60** [MUST] Maintain a register of ICT third parties (cloud, KYC, core banking, payment processors) with risk assessments, exit plans, and contract security clauses.
- **FIN-61** [MUST] Report major incidents to regulators within required deadlines; keep incident classification criteria documented in advance.
- **FIN-62** [MUST] Commission independent penetration tests at least yearly and after major changes; consider threat-led red teaming (for example TIBER-style) for systemic services.
- **FIN-63** [MUST] Keep data residency and cross-border transfer rules per market, and store regulated data only in approved regions.

## Banking Release Checklist

- [ ] Every money-moving endpoint is idempotent, atomic, limit-checked, and fraud-scored.
- [ ] No floating point in money code (`grep` for `float`, `double`, `Number` math on amounts).
- [ ] Ledger is double-entry and balances reconcile to zero difference in staging.
- [ ] Transaction signing verified server-side for T1 actions.
- [ ] Device binding, SIM swap checks, and cooling-off periods are active.
- [ ] RASP, Play Integrity, and App Attest verdicts are enforced on the server.
- [ ] Maker-checker covers all manual financial adjustments.
- [ ] Audit logs are immutable and complete for the release scope.
- [ ] Independent pentest findings for this release scope are closed.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Banking and Financial Rules | MIT License | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Related: <a href="payments.md">Payments</a></sub>
</div>
<!-- ========================================================== -->
