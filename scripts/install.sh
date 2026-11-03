#!/usr/bin/env bash
# =====================================================================
#  BASTION v2.3.0 | Security Rules for AI Coding Agents
#  Installer for macOS, Linux, WSL, and Git Bash on Windows
#
#  Usage:
#    ./scripts/install.sh [TARGET_DIR] [options]
#
#  Options:
#    --platforms a,b,c   Force platform list (default: auto-detect)
#    --tools all|list    claude,cursor,copilot,windsurf,cline,codex,gemini,vscode
#    --with-ci           Also add GitHub security workflow and Dependabot config
#    --with-mcp          Also add project MCP config (.mcp.json, .vscode/mcp.json, .cursor/mcp.json)
#    --list              Show available platforms and exit
#    --dry-run           Show what would happen, write nothing
#    -h, --help          Show help
# =====================================================================
set -euo pipefail

VERSION="2.3.0"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$SRC/rules/manifest.txt"
TARGET="."
PLATFORMS=""
TOOLS="all"
WITH_CI=0
WITH_MCP=0
DRY=0

c_blue=$'\033[1;34m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; c_red=$'\033[1;31m'; c_off=$'\033[0m'
info() { printf '%s[bastion]%s %s\n' "$c_blue" "$c_off" "$*"; }
ok()   { printf '%s[  ok  ]%s %s\n' "$c_green" "$c_off" "$*"; }
warn() { printf '%s[ warn ]%s %s\n' "$c_yellow" "$c_off" "$*"; }
die()  { printf '%s[error ]%s %s\n' "$c_red" "$c_off" "$*" >&2; exit 1; }

manifest_rows() { grep -vE '^[[:space:]]*(#|$)' "$MANIFEST"; }

usage() { sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0; }

while [ $# -gt 0 ]; do
  case "$1" in
    --platforms) PLATFORMS="${2:-}"; shift 2 ;;
    --tools)     TOOLS="${2:-all}"; shift 2 ;;
    --with-ci)   WITH_CI=1; shift ;;
    --with-mcp)  WITH_MCP=1; shift ;;
    --dry-run)   DRY=1; shift ;;
    --list)      manifest_rows | awk -F'|' '{printf "  %-24s %s\n", $1, $5}'; exit 0 ;;
    -h|--help)   usage ;;
    -*)          die "Unknown option: $1" ;;
    *)           TARGET="$1"; shift ;;
  esac
done

[ -d "$TARGET" ] || die "Target directory not found: $TARGET"
TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" = "$SRC" ] && die "Run the installer against your project folder, not the Bastion repo itself."
[ -f "$MANIFEST" ] || die "Manifest missing: $MANIFEST"

cat <<BANNER

  ${c_blue}BASTION v${VERSION}${c_off}  Security Rules for AI Coding Agents
  Target: ${TARGET}

BANNER

# ---------------------------------------------------------------------
# Detection
# ---------------------------------------------------------------------
PRUNE=( -name node_modules -o -name vendor -o -name .git -o -name build -o -name dist
        -o -name .next -o -name .bastion -o -name Pods -o -name .dart_tool -o -name venv -o -name .venv )

has_name() {
  local hit
  hit="$(find "$TARGET" -maxdepth 5 \( "${PRUNE[@]}" \) -prune -o -name "$1" -print -quit 2>/dev/null || true)"
  [ -n "$hit" ]
}

has_grep() {
  local file="$1" text="$2" f
  while IFS= read -r f; do
    [ -n "$f" ] && grep -qF -- "$text" "$f" 2>/dev/null && return 0
  done < <(find "$TARGET" -maxdepth 3 \( "${PRUNE[@]}" \) -prune -o -name "$file" -type f -print 2>/dev/null)
  return 1
}

detect_platform() {
  local signals="$1" sig rest file text
  IFS=';' read -r -a parts <<< "$signals"
  for sig in "${parts[@]}"; do
    case "$sig" in
      name:*) has_name "${sig#name:}" && return 0 ;;
      dir:*)  [ -d "$TARGET/${sig#dir:}" ] && return 0 ;;
      grep:*) rest="${sig#grep:}"; file="${rest%%:*}"; text="${rest#*:}"
              has_grep "$file" "$text" && return 0 ;;
    esac
  done
  return 1
}

ACTIVE=()
if [ -n "$PLATFORMS" ]; then
  IFS=',' read -r -a req <<< "$PLATFORMS"
  for p in "${req[@]}"; do
    manifest_rows | cut -d'|' -f1 | grep -qx "$p" || die "Unknown platform '$p'. Use --list."
    ACTIVE+=("$p")
  done
  info "Platforms (manual): ${ACTIVE[*]}"
else
  while IFS='|' read -r id file globs signals desc; do
    if detect_platform "$signals"; then ACTIVE+=("$id"); fi
  done < <(manifest_rows)
  PREV_FILE="$TARGET/.bastion/ACTIVE_PLATFORMS"
  if [ -f "$PREV_FILE" ]; then
    while IFS= read -r line; do
      prev="$(basename "$line" .md)"
      [ -n "$prev" ] || continue
      manifest_rows | cut -d'|' -f1 | grep -qx "$prev" || continue
      found=0; for x in "${ACTIVE[@]:-}"; do [ "$x" = "$prev" ] && found=1; done
      [ "$found" -eq 0 ] && ACTIVE+=("$prev")
    done < "$PREV_FILE"
  fi
  if [ ${#ACTIVE[@]} -eq 0 ]; then
    warn "No platform detected. Installing core rules only. Use --platforms to choose."
  else
    info "Platforms detected: ${ACTIVE[*]}"
  fi
fi

want_tool() { [ "$TOOLS" = "all" ] || [[ ",$TOOLS," == *",$1,"* ]]; }
is_active() { local x; for x in "${ACTIVE[@]:-}"; do [ "$x" = "$1" ] && return 0; done; return 1; }

if [ "$DRY" -eq 1 ]; then
  info "Dry run. Would install core + [${ACTIVE[*]:-none}] for tools: $TOOLS (CI: $WITH_CI)"
  exit 0
fi

# ---------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------
START="<!-- BASTION:START -->"
END="<!-- BASTION:END -->"

# write_block <file> <content>: insert or replace the Bastion block, keep the rest of the file
write_block() {
  local f="$1" content="$2" tmp
  mkdir -p "$(dirname "$f")"
  tmp="$(mktemp)"
  if [ -f "$f" ]; then
    awk -v s="$START" -v e="$END" '
      $0==s {skip=1; next}
      $0==e {skip=0; next}
      !skip {print}
    ' "$f" > "$tmp"
    # trim trailing blank lines
    awk '{l[NR]=$0} END{n=NR; while(n>0 && l[n] ~ /^[[:space:]]*$/) n--; for(i=1;i<=n;i++) print l[i]}' "$tmp" > "$tmp.2" && mv "$tmp.2" "$tmp"
    [ -s "$tmp" ] && printf '\n' >> "$tmp"
  fi
  { printf '%s\n' "$START"; printf '%s\n' "$content"; printf '%s\n' "$END"; } >> "$tmp"
  mv "$tmp" "$f"
}

copy_if_absent() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ]; then
    warn "Kept existing $(realpath --relative-to="$TARGET" "$dst" 2>/dev/null || echo "$dst"). Merge from $src if needed."
  else
    cp "$src" "$dst"; ok "Added ${dst#$TARGET/}"
  fi
}

row_for() { manifest_rows | awk -F'|' -v id="$1" '$1==id'; }

# ---------------------------------------------------------------------
# 1. Copy rules into .bastion/
# ---------------------------------------------------------------------
B="$TARGET/.bastion"
mkdir -p "$B"
if [ "$SRC" != "$B" ]; then
  # Fresh copy of Bastion-owned folders. PROJECT-RULES.md is never touched.
  rm -rf "$B/rules" "$B/templates" "$B/hooks" "$B/integrations" "$B/scripts"
  cp "$SRC/BASTION.md" "$B/BASTION.md"
  for d in rules templates hooks integrations scripts; do cp -R "$SRC/$d" "$B/$d"; done
else
  info "Refreshing from the project copy in .bastion/"
fi
chmod +x "$B/hooks/"*.sh "$B/scripts/"*.sh 2>/dev/null || true
if [ ! -f "$B/PROJECT-RULES.md" ]; then
  cp "$SRC/templates/PROJECT-RULES.md" "$B/PROJECT-RULES.md"
  ok "Created .bastion/PROJECT-RULES.md (project-specific rules, kept on every update)"
fi
printf '%s\n' "$VERSION" > "$B/VERSION"
: > "$B/ACTIVE_PLATFORMS"
for p in "${ACTIVE[@]:-}"; do
  [ -n "$p" ] || continue
  f="$(row_for "$p" | cut -d'|' -f2)"
  printf '.bastion/rules/platforms/%s\n' "$f" >> "$B/ACTIVE_PLATFORMS"
done
ok "Rules installed to .bastion/ (v$VERSION)"

IMPORTS="@.bastion/BASTION.md"$'\n'"@.bastion/PROJECT-RULES.md"
PATHS="- .bastion/BASTION.md"$'\n'"- .bastion/PROJECT-RULES.md"
for p in "${ACTIVE[@]:-}"; do
  [ -n "$p" ] || continue
  f="$(row_for "$p" | cut -d'|' -f2)"
  IMPORTS="$IMPORTS"$'\n'"@.bastion/rules/platforms/$f"
  PATHS="$PATHS"$'\n'"- .bastion/rules/platforms/$f"
done

COMMANDS_TEXT="Security commands: /bastion-audit, /bastion-harden, /bastion-review, /bastion-threat-model, /bastion-build, /bastion-release, /bastion-incident, /bastion-fintech-audit, /bastion-secure, /bastion-site-audit"

# ---------------------------------------------------------------------
# 2. Claude Code
# ---------------------------------------------------------------------
if want_tool claude; then
  write_block "$TARGET/CLAUDE.md" "## Security Rules (Bastion v$VERSION)

Follow the Bastion security rules in every task. Never violate the 12 Red Lines.
Start security work in AUDIT mode unless told otherwise. Cite rule IDs in findings and commits.

$IMPORTS

$COMMANDS_TEXT"
  ok "CLAUDE.md updated"
  mkdir -p "$TARGET/.claude/commands"
  cp "$SRC/integrations/commands/"*.md "$TARGET/.claude/commands/"
  ok "Claude Code slash commands added (.claude/commands/)"
  copy_if_absent "$SRC/integrations/claude/settings.json" "$TARGET/.claude/settings.json"
fi

# ---------------------------------------------------------------------
# 3. Codex, Jules, Amp, and other AGENTS.md readers
# ---------------------------------------------------------------------
if want_tool codex; then
  write_block "$TARGET/AGENTS.md" "## Security Rules (Bastion v$VERSION)

Before any task, read these files and follow them. Never violate the 12 Red Lines in BASTION.md.
$PATHS

Security task templates (audit, harden, review, threat-model, build, release, incident) are in .claude/commands/ and .github/prompts/."
  ok "AGENTS.md updated"
fi

# ---------------------------------------------------------------------
# 4. Gemini CLI
# ---------------------------------------------------------------------
if want_tool gemini; then
  write_block "$TARGET/GEMINI.md" "## Security Rules (Bastion v$VERSION)

Follow these security rules in every task. Never violate the 12 Red Lines.

$IMPORTS"
  ok "GEMINI.md updated"
fi

# ---------------------------------------------------------------------
# 5. Cursor
# ---------------------------------------------------------------------
if want_tool cursor; then
  CR="$TARGET/.cursor/rules"; mkdir -p "$CR"
  rm -f "$CR"/bastion-*.mdc
  { printf -- '---\ndescription: Bastion core security rules (always on)\nglobs:\nalwaysApply: true\n---\n\n'; cat "$SRC/BASTION.md"; } > "$CR/bastion-core.mdc"
  { printf -- '---\ndescription: Bastion project-specific security rules (always on)\nglobs:\nalwaysApply: true\n---\n\n'; cat "$B/PROJECT-RULES.md"; } > "$CR/bastion-project.mdc"
  for p in "${ACTIVE[@]:-}"; do
    [ -n "$p" ] || continue
    IFS='|' read -r id file globs signals desc <<< "$(row_for "$p")"
    { printf -- '---\ndescription: Bastion %s\nglobs: %s\nalwaysApply: false\n---\n\n' "$desc" "$globs"; cat "$SRC/rules/platforms/$file"; } > "$CR/bastion-$id.mdc"
  done
  mkdir -p "$TARGET/.cursor/commands"
  cp "$SRC/integrations/commands/"*.md "$TARGET/.cursor/commands/"
  ok "Cursor rules and commands added (.cursor/)"
fi

# ---------------------------------------------------------------------
# 6. GitHub Copilot (VS Code, JetBrains, github.com)
# ---------------------------------------------------------------------
if want_tool copilot; then
  GI="$TARGET/.github/instructions"; mkdir -p "$GI"
  rm -f "$GI"/bastion-*.instructions.md
  { printf -- '---\napplyTo: "**"\ndescription: "Bastion core security rules"\n---\n\n'; cat "$SRC/BASTION.md"; } > "$GI/bastion-core.instructions.md"
  { printf -- '---\napplyTo: "**"\ndescription: "Bastion project-specific security rules"\n---\n\n'; cat "$B/PROJECT-RULES.md"; } > "$GI/bastion-project.instructions.md"
  for p in "${ACTIVE[@]:-}"; do
    [ -n "$p" ] || continue
    IFS='|' read -r id file globs signals desc <<< "$(row_for "$p")"
    { printf -- '---\napplyTo: "%s"\ndescription: "Bastion %s"\n---\n\n' "$globs" "$desc"; cat "$SRC/rules/platforms/$file"; } > "$GI/bastion-$id.instructions.md"
  done
  write_block "$TARGET/.github/copilot-instructions.md" "## Security Rules (Bastion v$VERSION)

Follow the Bastion rules in .github/instructions/bastion-*.instructions.md and .bastion/BASTION.md.
Never violate the 12 Red Lines. Cite rule IDs in reviews and commit messages."
  mkdir -p "$TARGET/.github/prompts"
  for c in "$SRC/integrations/commands/"*.md; do
    cp "$c" "$TARGET/.github/prompts/$(basename "${c%.md}").prompt.md"
  done
  ok "GitHub Copilot instructions and prompt files added (.github/)"
fi

# ---------------------------------------------------------------------
# 7. Windsurf
# ---------------------------------------------------------------------
if want_tool windsurf; then
  WR="$TARGET/.windsurf/rules"; mkdir -p "$WR"
  rm -f "$WR"/bastion-*.md
  { printf -- '---\ntrigger: always_on\n---\n\n'; cat "$SRC/rules/BASTION-LITE.md"; } > "$WR/bastion-core.md"
  { printf -- '---\ntrigger: always_on\n---\n\n'; cat "$B/PROJECT-RULES.md"; } > "$WR/bastion-project.md"
  for p in "${ACTIVE[@]:-}"; do
    [ -n "$p" ] || continue
    IFS='|' read -r id file globs signals desc <<< "$(row_for "$p")"
    { printf -- '---\ntrigger: glob\nglobs: %s\n---\n\n' "$globs"; cat "$SRC/rules/platforms/$file"; } > "$WR/bastion-$id.md"
  done
  ok "Windsurf rules added (.windsurf/rules/)"
fi

# ---------------------------------------------------------------------
# 8. Cline and Roo Code
# ---------------------------------------------------------------------
if want_tool cline; then
  CL="$TARGET/.clinerules"
  if [ -f "$CL" ]; then
    warn ".clinerules is a single file. Skipping Cline. Convert it to a folder to enable Bastion."
  else
    mkdir -p "$CL"; rm -f "$CL"/bastion-*.md
    cp "$SRC/BASTION.md" "$CL/bastion-core.md"
    cp "$B/PROJECT-RULES.md" "$CL/bastion-project.md"
    for p in "${ACTIVE[@]:-}"; do
      [ -n "$p" ] || continue
      f="$(row_for "$p" | cut -d'|' -f2)"
      cp "$SRC/rules/platforms/$f" "$CL/bastion-${f}"
    done
    ok "Cline rules added (.clinerules/)"
  fi
fi

# ---------------------------------------------------------------------
# 9. VS Code workspace
# ---------------------------------------------------------------------
if want_tool vscode; then
  copy_if_absent "$SRC/integrations/vscode/extensions.json" "$TARGET/.vscode/extensions.json"
  copy_if_absent "$SRC/integrations/vscode/settings.json"   "$TARGET/.vscode/settings.json"
  copy_if_absent "$SRC/integrations/vscode/tasks.json"      "$TARGET/.vscode/tasks.json"
fi

# ---------------------------------------------------------------------
# 10. CI templates
# ---------------------------------------------------------------------
if [ "$WITH_CI" -eq 1 ]; then
  copy_if_absent "$SRC/templates/github/workflows/bastion-security.yml" "$TARGET/.github/workflows/bastion-security.yml"
  copy_if_absent "$SRC/templates/github/dependabot.yml" "$TARGET/.github/dependabot.yml"
fi

# ---------------------------------------------------------------------
# 10b. MCP server config (project scope)
# ---------------------------------------------------------------------
if [ "$WITH_MCP" -eq 1 ]; then
  MCP_ENTRY='"bastion": { "command": "npx", "args": ["-y", "bastion-security-mcp"] }'
  if [ ! -f "$TARGET/.mcp.json" ]; then
    printf '{\n  "mcpServers": {\n    %s\n  }\n}\n' "$MCP_ENTRY" > "$TARGET/.mcp.json"; ok "Added .mcp.json (Claude Code)"
  else warn "Kept existing .mcp.json. Add: $MCP_ENTRY"; fi
  if [ ! -f "$TARGET/.cursor/mcp.json" ]; then
    mkdir -p "$TARGET/.cursor"
    printf '{\n  "mcpServers": {\n    %s\n  }\n}\n' "$MCP_ENTRY" > "$TARGET/.cursor/mcp.json"; ok "Added .cursor/mcp.json"
  else warn "Kept existing .cursor/mcp.json"; fi
  if [ ! -f "$TARGET/.vscode/mcp.json" ]; then
    mkdir -p "$TARGET/.vscode"
    printf '{\n  "servers": {\n    "bastion": { "type": "stdio", "command": "npx", "args": ["-y", "bastion-security-mcp"] }\n  }\n}\n' > "$TARGET/.vscode/mcp.json"; ok "Added .vscode/mcp.json"
  else warn "Kept existing .vscode/mcp.json"; fi
fi

# ---------------------------------------------------------------------
# 11. .gitignore safety net
# ---------------------------------------------------------------------
GI_FILE="$TARGET/.gitignore"
touch "$GI_FILE"
if ! grep -q "BASTION secret patterns" "$GI_FILE"; then
  cat >> "$GI_FILE" <<'EOF'

# BASTION secret patterns (do not commit secrets)
.env
.env.*
!.env.example
*.pem
*.key
*.p12
*.pfx
*.jks
*.keystore
keystore.properties
serviceAccount*.json
EOF
  ok ".gitignore secret patterns added"
fi

cat <<DONE

  ${c_green}Bastion v${VERSION} installed.${c_off}
  Platforms: ${ACTIVE[*]:-core only}
  Next: open the project in Claude Code, Cursor, VS Code, or your agent and run  /bastion-secure

DONE
