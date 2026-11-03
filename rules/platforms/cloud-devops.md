<!-- ===================== BASTION HEADER ===================== -->
<div align="center">

**BASTION** | Security Rules for AI Coding Agents

`rules/platforms/cloud-devops.md` | Docker, Kubernetes, Terraform, GitHub Actions, Vercel, VPS, RDP, cPanel/hPanel | v2.3.0 | Prefix: `OPS`

</div>

---
<!-- ========================================================== -->

# Cloud, DevOps, VPS, and RDP Security Rules

> Applies with `BASTION.md` (Sections 13, 15, 16).

## GitHub Actions and CI/CD

- **OPS-01** [MUST] Set `permissions: contents: read` at workflow level and grant more only per job.
- **OPS-02** [MUST] Pin third-party actions to full commit SHAs.
- **OPS-03** [MUST NOT] Check out and run pull request code in `pull_request_target` workflows or interpolate `${{ github.event.* }}` text directly into `run:` scripts (script injection).
- **OPS-04** [MUST] Use OIDC to cloud providers instead of stored long-lived keys.
- **OPS-05** [MUST] Protect production deployments with environments and required reviewers.
- **OPS-06** [MUST] Enable secret scanning push protection, Dependabot, and CodeQL (or Semgrep). Template: `templates/github/workflows/bastion-security.yml`.

## Containers

- **OPS-07** [MUST] Use minimal or distroless base images pinned by digest; run as non-root with `USER`.
- **OPS-08** [MUST] Use multi-stage builds so build tools and secrets never reach the final image; pass build secrets with `--secret`, not `ARG`.
- **OPS-09** [MUST] Scan images with Trivy or Grype in CI; block on Critical.
- **OPS-10** [MUST] Use `.dockerignore` to exclude `.env`, `.git`, keys, and local data.

## Kubernetes

- **OPS-11** [MUST] Enforce Pod Security Standards (`restricted`), NetworkPolicies (default deny), RBAC least privilege, and no `privileged` or `hostPath` mounts.
- **OPS-12** [MUST] Use external secret stores (External Secrets, Sealed Secrets, CSI driver), not plain Kubernetes Secrets in Git.

## Terraform and IaC

- **OPS-13** [MUST] Scan IaC with Checkov, tfsec / Trivy config, or KICS.
- **OPS-14** [MUST] Store state remotely, encrypted, with locking and restricted access; state files contain secrets.

## Linux VPS Hardening

- **OPS-15** [MUST] Disable SSH password and root login; use Ed25519 keys; consider a non-default port plus fail2ban or CrowdSec.
- **OPS-16** [MUST] Enable a host firewall (ufw / nftables) allowing only required ports.
- **OPS-17** [MUST] Enable unattended security upgrades and reboot on kernel updates on schedule.
- **OPS-18** [MUST] Run each app as its own unprivileged user; use systemd sandboxing options (`ProtectSystem`, `NoNewPrivileges`).
- **OPS-19** [MUST] Put admin panels (cPanel, Plesk, phpMyAdmin, Portainer) behind VPN, IP allowlist, or zero-trust access.

## Windows RDP Servers

- **OPS-20** [MUST] Never expose RDP 3389 directly to the internet; use VPN, RD Gateway, or zero-trust access.
- **OPS-21** [MUST] Enforce Network Level Authentication, account lockout, strong passwords, and MFA for RDP.
- **OPS-22** [MUST] Isolate customer RDP/VPS instances from each other and from management networks.
- **OPS-23** [MUST] Keep Windows Update, Defender, and firewall enabled; monitor failed logon events (4625).

## Managed Hosting (Vercel, Netlify, Hostinger, Cloudflare)

- **OPS-24** [MUST] Enable MFA on hosting, domain registrar, DNS, and email accounts; these are the keys to the business.
- **OPS-25** [MUST] Enable registrar lock and DNSSEC where supported; monitor DNS changes.
- **OPS-26** [MUST] Configure SPF, DKIM, and DMARC (`p=quarantine` or `reject`) for every sending domain.
- **OPS-27** [MUST] Keep separate environment variables for production, preview, and development.

---
<!-- ===================== BASTION FOOTER ===================== -->
<div align="center">
<sub><b>BASTION v2.3.0</b> | Cloud and DevOps Rules | MIT License | <a href="../../README.md">Home</a> | <a href="../../BASTION.md">Core Rules</a> | Next: <a href="ai-llm-agents.md">AI, LLM, and Agents</a></sub>
</div>
<!-- ========================================================== -->
