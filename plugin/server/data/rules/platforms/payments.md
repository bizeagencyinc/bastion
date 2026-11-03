<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/payments.md` | Stripe, PayPal, Wise, Payoneer, local gateways, wallets, subscriptions | v2.3.0 | Prefix: `PAY`

</div>

---
<!-- ========================================================== -->

# Payments Security Rules

> Applies with `BASTION.md`. Standard: PCI DSS 4.x. Goal: card data never touches your servers (SAQ A scope).

## Card Data

- **PAY-01** [MUST] Use hosted checkout, hosted fields, or provider SDK elements (Stripe Checkout / Elements, PayPal hosted buttons) so raw card numbers never reach your servers or logs.
- **PAY-02** [MUST NOT] Store, log, or transmit PAN, CVV, or full track data. Store only provider tokens and last four digits.
- **PAY-03** [MUST] Control and monitor every script on checkout pages (PCI DSS 6.4.3 and 11.6.1).

## Amounts and Orders

- **PAY-04** [MUST] Calculate prices, taxes, discounts, and totals on the server from the database; ignore client-sent amounts.
- **PAY-05** [MUST] Create payment intents or orders on the server and confirm fulfillment only after a verified webhook or server-side retrieval of the payment status.
- **PAY-06** [MUST] Use idempotency keys on payment, refund, and payout API calls.
- **PAY-07** [MUST] Prevent coupon abuse, negative quantities, currency mismatches, and race conditions (database transactions and unique constraints).

## Webhooks

- **PAY-08** [MUST] Verify webhook signatures with the official SDK (`stripe.webhooks.constructEvent`, PayPal verify-webhook-signature) using the raw request body.
- **PAY-09** [MUST] Reject stale events, deduplicate by event ID, and process idempotently.
- **PAY-10** [MUST] Re-fetch the object from the provider API for high-value events instead of trusting the payload alone.

## Keys and Accounts

- **PAY-11** [MUST] Use restricted API keys with only the needed permissions; keep secret keys server-side only.
- **PAY-12** [MUST] Enable MFA and role separation on payment provider dashboards; review team access quarterly.
- **PAY-13** [MUST] Separate test and live keys and environments; never use live keys in development.

## Fraud and Abuse

- **PAY-14** [MUST] Enable provider fraud tools (Stripe Radar, PayPal Fraud Protection) and 3-D Secure where applicable.
- **PAY-15** [MUST] Rate limit checkout and card-entry endpoints and add CAPTCHA to stop card-testing attacks.
- **PAY-16** [MUST] Require step-up auth and notify users for payout destination changes.
- **PAY-17** [MUST] Log every payment state change with actor and timestamp for reconciliation and disputes.

## Wallets and Balances

- **PAY-18** [MUST] Use a double-entry ledger with immutable entries for in-app balances; never update a balance field directly.
- **PAY-19** [MUST] Reconcile ledger totals against provider settlements daily and alert on mismatch.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Payments Rules | MIT License | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Back to: <a href="android.md">Android</a></sub>
</div>
<!-- ========================================================== -->
