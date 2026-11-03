#!/usr/bin/env bash
# =====================================================================
# BASTION GUARD HOOK v2.3.0
# Claude Code PreToolUse hook. Blocks:
#   1. Writes/edits that contain high-confidence secrets.
#   2. Dangerous shell commands (pipe-to-shell, disk wipe, force push to main).
# Exit code 2 blocks the tool call and shows the reason to the agent.
# Usage in .claude/settings.json: see integrations/claude/settings.json
# =====================================================================
set -u

INPUT="$(cat)"

block() {
  echo "BASTION GUARD: blocked. $1" >&2
  echo "If this is a false positive, the user can approve the change manually." >&2
  exit 2
}

TOOL="$(printf '%s' "$INPUT" | grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]+"' | head -n1 | sed -E 's/.*"([^"]+)"$/\1/')"

case "$TOOL" in
  Write|Edit|MultiEdit|NotebookEdit)
    # Allow placeholder files
    if printf '%s' "$INPUT" | grep -qE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*\.env\.example"'; then
      exit 0
    fi
    while IFS='|' read -r name regex; do
      [ -z "$name" ] && continue
      if printf '%s' "$INPUT" | grep -qE -- "$regex"; then
        block "Possible secret detected ($name). Rule RED-01 / SEC-01: store secrets in environment variables or a vault, never in files."
      fi
    done <<'PATTERNS'
AWS access key|AKIA[0-9A-Z]{16}
Private key block|-----BEGIN (RSA |EC |DSA |OPENSSH |PGP |ENCRYPTED )?PRIVATE KEY-----
Stripe live secret key|sk_live_[0-9A-Za-z]{20,}
Stripe restricted live key|rk_live_[0-9A-Za-z]{20,}
GitHub token|gh[pousr]_[0-9A-Za-z]{36,}
GitHub fine-grained token|github_pat_[0-9A-Za-z_]{40,}
Slack token|xox[abprs]-[0-9A-Za-z-]{10,}
Anthropic API key|sk-ant-(api|admin)[0-9]{2}-[0-9A-Za-z_-]{20,}
OpenAI project key|sk-proj-[0-9A-Za-z_-]{20,}
Google OAuth client secret|GOCSPX-[0-9A-Za-z_-]{20,}
Twilio key|SK[0-9a-fA-F]{32}
Database URL with password|(postgres(ql)?|mysql|mariadb|mongodb(\+srv)?|rediss?|amqps?|mssql|sqlserver)://[A-Za-z0-9._%-]+:[^@/[:space:]"$<{]{6,}@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}
SendGrid key|SG\.[0-9A-Za-z_-]{22}\.[0-9A-Za-z_-]{43}
PATTERNS
    ;;
  Bash)
    CMD="$(printf '%s' "$INPUT" | grep -oE '"command"[[:space:]]*:[[:space:]]*"([^"\\]|\\.)*"' | head -n1)"
    if printf '%s' "$CMD" | grep -qE '(curl|wget|iwr|Invoke-WebRequest)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z|da)?sh\b'; then
      block "Pipe-to-shell execution. Rule RED-09 / AGENT-04: download, inspect, and verify first."
    fi
    if printf '%s' "$CMD" | grep -qE 'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f?[[:space:]]+(/|~|\$HOME)([[:space:]]|"|$)'; then
      block "Recursive delete of root or home directory. Rule AGENT-07."
    fi
    if printf '%s' "$CMD" | grep -qE 'git[[:space:]]+push[^"]*(--force|-f)([[:space:]]|")[^"]*(main|master|production)'; then
      block "Force push to a protected branch. Rule SUPPLY-05 / AGENT-07."
    fi
    if printf '%s' "$CMD" | grep -qiE '(DROP[[:space:]]+(DATABASE|SCHEMA)|TRUNCATE[[:space:]]+TABLE)'; then
      block "Destructive database command. Rule RED-11 / AGENT-07: ask the user first."
    fi
    if printf '%s' "$CMD" | grep -qE 'chmod[[:space:]]+(-R[[:space:]]+)?777'; then
      block "World-writable permissions. Rule WP-06 / OPS-18."
    fi
    if printf '%s' "$CMD" | grep -qE '(cat|less|more|head|tail|type|bat)[[:space:]]+[^|;&]*\.env([[:space:]]|"|$)'; then
      block "Reading .env contents into the session. Rule AGENT-02."
    fi
    ;;
esac

exit 0
