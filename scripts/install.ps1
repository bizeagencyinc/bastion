<#
=====================================================================
 BASTION v2.3.0 | Security Rules for AI Coding Agents
 Installer for Windows PowerShell 5.1+ and PowerShell 7+

 Usage:
   .\scripts\install.ps1 [-Target <dir>] [-Platforms a,b] [-Tools all|claude,cursor,...] [-WithCI] [-WithMCP] [-List] [-DryRun]

 Example:
   .\scripts\install.ps1 -Target C:\Projects\my-app -WithCI
=====================================================================
#>
[CmdletBinding()]
param(
  [string]$Target = ".",
  [string]$Platforms = "",
  [string]$Tools = "all",
  [switch]$WithCI,
  [switch]$WithMCP,
  [switch]$List,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$Version  = "2.3.0"
$Src      = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Manifest = Join-Path $Src "rules\manifest.txt"
$Utf8     = New-Object System.Text.UTF8Encoding $false

function Info($m) { Write-Host "[bastion] $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "[  ok  ] $m" -ForegroundColor Green }
function Warn($m) { Write-Host "[ warn ] $m" -ForegroundColor Yellow }
function Die($m)  { Write-Host "[error ] $m" -ForegroundColor Red; exit 1 }

function Write-Text($Path, $Text) {
  $dir = Split-Path $Path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($Path, ($Text -replace "`r`n", "`n"), $Utf8)
}
function Read-Text($Path) { [System.IO.File]::ReadAllText($Path, $Utf8) }

$Rows = @()
foreach ($line in (Get-Content $Manifest)) {
  if ($line -match '^\s*(#|$)') { continue }
  $p = $line.Split('|')
  $Rows += [pscustomobject]@{ Id=$p[0]; File=$p[1]; Globs=$p[2]; Signals=$p[3]; Desc=$p[4] }
}

if ($List) { $Rows | ForEach-Object { "  {0,-24} {1}" -f $_.Id, $_.Desc }; exit 0 }

if (-not (Test-Path $Target -PathType Container)) { Die "Target directory not found: $Target" }
$Target = (Resolve-Path $Target).Path
if ($Target -eq $Src) { Die "Run the installer against your project folder, not the Bastion repo itself." }

Write-Host ""
Write-Host "  BASTION v$Version  Security Rules for AI Coding Agents" -ForegroundColor Cyan
Write-Host "  Target: $Target"
Write-Host ""

# ---------------------------------------------------------------------
# Detection
# ---------------------------------------------------------------------
$PruneRx = '[\\/](node_modules|vendor|\.git|build|dist|\.next|\.bastion|Pods|\.dart_tool|venv|\.venv)([\\/]|$)'

function Get-ProjectItems([int]$Depth) {
  Get-ChildItem -Path $Target -Recurse -Depth $Depth -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch $PruneRx }
}
$Items5 = @(Get-ProjectItems 4)
$Items3 = @(Get-ProjectItems 2 | Where-Object { -not $_.PSIsContainer })

function Test-Signal($sig) {
  if ($sig.StartsWith("name:")) {
    $pat = $sig.Substring(5)
    return [bool]($Items5 | Where-Object { $_.Name -like $pat } | Select-Object -First 1)
  }
  if ($sig.StartsWith("dir:")) {
    return Test-Path (Join-Path $Target $sig.Substring(4)) -PathType Container
  }
  if ($sig.StartsWith("grep:")) {
    $rest = $sig.Substring(5); $i = $rest.IndexOf(':')
    $file = $rest.Substring(0, $i); $text = $rest.Substring($i + 1)
    foreach ($f in ($Items3 | Where-Object { $_.Name -eq $file })) {
      if ((Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue) -like "*$text*") { return $true }
    }
  }
  return $false
}

$Active = @()
if ($Platforms) {
  foreach ($p in $Platforms.Split(',')) {
    $p = $p.Trim()
    if (-not ($Rows | Where-Object { $_.Id -eq $p })) { Die "Unknown platform '$p'. Use -List." }
    $Active += $p
  }
  Info "Platforms (manual): $($Active -join ' ')"
} else {
  foreach ($r in $Rows) {
    foreach ($s in $r.Signals.Split(';')) { if (Test-Signal $s) { $Active += $r.Id; break } }
  }
  $PrevFile = Join-Path $Target ".bastion\ACTIVE_PLATFORMS"
  if (Test-Path $PrevFile) {
    foreach ($line in (Get-Content $PrevFile)) {
      if (-not $line) { continue }
      $prev = [System.IO.Path]::GetFileNameWithoutExtension($line)
      if (($Rows | Where-Object { $_.Id -eq $prev }) -and ($Active -notcontains $prev)) { $Active += $prev }
    }
  }
  if ($Active.Count -eq 0) { Warn "No platform detected. Installing core rules only. Use -Platforms to choose." }
  else { Info "Platforms detected: $($Active -join ' ')" }
}

function Want($t) { return ($Tools -eq "all") -or ((",$Tools,") -like "*,$t,*") }
function Row($id) { return $Rows | Where-Object { $_.Id -eq $id } | Select-Object -First 1 }

if ($DryRun) { Info "Dry run. Would install core + [$($Active -join ', ')] for tools: $Tools (CI: $WithCI)"; exit 0 }

# ---------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------
$Start = "<!-- BASTION:START -->"
$End   = "<!-- BASTION:END -->"

function Write-Block($Path, $Content) {
  $body = ""
  if (Test-Path $Path) {
    $keep = New-Object System.Collections.Generic.List[string]
    $skip = $false
    foreach ($l in ((Read-Text $Path) -split "`r?`n")) {
      if ($l -eq $Start) { $skip = $true; continue }
      if ($l -eq $End)   { $skip = $false; continue }
      if (-not $skip) { $keep.Add($l) }
    }
    $body = ($keep -join "`n").TrimEnd()
    if ($body) { $body += "`n`n" }
  }
  Write-Text $Path ($body + "$Start`n$Content`n$End`n")
}

function Copy-IfAbsent($From, $To) {
  if (Test-Path $To) { Warn "Kept existing $To. Merge from $From if needed." }
  else {
    New-Item -ItemType Directory -Force -Path (Split-Path $To -Parent) | Out-Null
    Copy-Item $From $To; Ok "Added $To"
  }
}

# ---------------------------------------------------------------------
# 1. Copy rules into .bastion\
# ---------------------------------------------------------------------
$B = Join-Path $Target ".bastion"
New-Item -ItemType Directory -Force -Path $B | Out-Null
$B = (Resolve-Path $B).Path
if ($Src -ne $B) {
  # Fresh copy of Bastion-owned folders. PROJECT-RULES.md is never touched.
  foreach ($d in "rules","templates","hooks","integrations","scripts") {
    $p = Join-Path $B $d
    if (Test-Path $p) { Remove-Item $p -Recurse -Force }
    Copy-Item (Join-Path $Src $d) $p -Recurse
  }
  Copy-Item (Join-Path $Src "BASTION.md") (Join-Path $B "BASTION.md") -Force
} else {
  Info "Refreshing from the project copy in .bastion\"
}
$ProjectRules = Join-Path $B "PROJECT-RULES.md"
if (-not (Test-Path $ProjectRules)) {
  Copy-Item (Join-Path $Src "templates\PROJECT-RULES.md") $ProjectRules
  Ok "Created .bastion\PROJECT-RULES.md (project-specific rules, kept on every update)"
}
Write-Text (Join-Path $B "VERSION") "$Version`n"

$Imports = @("@.bastion/BASTION.md", "@.bastion/PROJECT-RULES.md")
$Paths   = @("- .bastion/BASTION.md", "- .bastion/PROJECT-RULES.md")
$ActiveLines = @()
foreach ($id in $Active) {
  $f = (Row $id).File
  $Imports += "@.bastion/rules/platforms/$f"
  $Paths   += "- .bastion/rules/platforms/$f"
  $ActiveLines += ".bastion/rules/platforms/$f"
}
Write-Text (Join-Path $B "ACTIVE_PLATFORMS") (($ActiveLines -join "`n") + "`n")
Ok "Rules installed to .bastion\ (v$Version)"

$ImportsText  = $Imports -join "`n"
$PathsText    = $Paths -join "`n"
$CommandsText = "Security commands: /bastion-audit, /bastion-harden, /bastion-review, /bastion-threat-model, /bastion-build, /bastion-release, /bastion-incident, /bastion-fintech-audit, /bastion-secure, /bastion-site-audit"
$Core = Read-Text (Join-Path $Src "BASTION.md")
$Lite = Read-Text (Join-Path $Src "rules\BASTION-LITE.md")
$Proj = Read-Text $ProjectRules
$Cmds = Get-ChildItem (Join-Path $Src "integrations\commands") -Filter *.md

# ---------------------------------------------------------------------
# 2. Claude Code
# ---------------------------------------------------------------------
if (Want "claude") {
  Write-Block (Join-Path $Target "CLAUDE.md") @"
## Security Rules (Bastion v$Version)

Follow the Bastion security rules in every task. Never violate the 12 Red Lines.
Start security work in AUDIT mode unless told otherwise. Cite rule IDs in findings and commits.

$ImportsText

$CommandsText
"@
  Ok "CLAUDE.md updated"
  $cd = Join-Path $Target ".claude\commands"; New-Item -ItemType Directory -Force -Path $cd | Out-Null
  $Cmds | ForEach-Object { Copy-Item $_.FullName (Join-Path $cd $_.Name) -Force }
  Ok "Claude Code slash commands added (.claude\commands\)"
  Copy-IfAbsent (Join-Path $Src "integrations\claude\settings.json") (Join-Path $Target ".claude\settings.json")
}

# ---------------------------------------------------------------------
# 3. AGENTS.md (Codex and others)
# ---------------------------------------------------------------------
if (Want "codex") {
  Write-Block (Join-Path $Target "AGENTS.md") @"
## Security Rules (Bastion v$Version)

Before any task, read these files and follow them. Never violate the 12 Red Lines in BASTION.md.
$PathsText

Security task templates (audit, harden, review, threat-model, build, release, incident) are in .claude/commands/ and .github/prompts/.
"@
  Ok "AGENTS.md updated"
}

# ---------------------------------------------------------------------
# 4. Gemini CLI
# ---------------------------------------------------------------------
if (Want "gemini") {
  Write-Block (Join-Path $Target "GEMINI.md") @"
## Security Rules (Bastion v$Version)

Follow these security rules in every task. Never violate the 12 Red Lines.

$ImportsText
"@
  Ok "GEMINI.md updated"
}

# ---------------------------------------------------------------------
# 5. Cursor
# ---------------------------------------------------------------------
if (Want "cursor") {
  $cr = Join-Path $Target ".cursor\rules"; New-Item -ItemType Directory -Force -Path $cr | Out-Null
  Get-ChildItem $cr -Filter "bastion-*.mdc" -ErrorAction SilentlyContinue | Remove-Item -Force
  Write-Text (Join-Path $cr "bastion-core.mdc") ("---`ndescription: Bastion core security rules (always on)`nglobs:`nalwaysApply: true`n---`n`n" + $Core)
  Write-Text (Join-Path $cr "bastion-project.mdc") ("---`ndescription: Bastion project-specific security rules (always on)`nglobs:`nalwaysApply: true`n---`n`n" + $Proj)
  foreach ($id in $Active) {
    $r = Row $id
    $txt = Read-Text (Join-Path $Src "rules\platforms\$($r.File)")
    Write-Text (Join-Path $cr "bastion-$id.mdc") ("---`ndescription: Bastion $($r.Desc)`nglobs: $($r.Globs)`nalwaysApply: false`n---`n`n" + $txt)
  }
  $cc = Join-Path $Target ".cursor\commands"; New-Item -ItemType Directory -Force -Path $cc | Out-Null
  $Cmds | ForEach-Object { Copy-Item $_.FullName (Join-Path $cc $_.Name) -Force }
  Ok "Cursor rules and commands added (.cursor\)"
}

# ---------------------------------------------------------------------
# 6. GitHub Copilot
# ---------------------------------------------------------------------
if (Want "copilot") {
  $gi = Join-Path $Target ".github\instructions"; New-Item -ItemType Directory -Force -Path $gi | Out-Null
  Get-ChildItem $gi -Filter "bastion-*.instructions.md" -ErrorAction SilentlyContinue | Remove-Item -Force
  Write-Text (Join-Path $gi "bastion-core.instructions.md") ("---`napplyTo: `"**`"`ndescription: `"Bastion core security rules`"`n---`n`n" + $Core)
  Write-Text (Join-Path $gi "bastion-project.instructions.md") ("---`napplyTo: `"**`"`ndescription: `"Bastion project-specific security rules`"`n---`n`n" + $Proj)
  foreach ($id in $Active) {
    $r = Row $id
    $txt = Read-Text (Join-Path $Src "rules\platforms\$($r.File)")
    Write-Text (Join-Path $gi "bastion-$id.instructions.md") ("---`napplyTo: `"$($r.Globs)`"`ndescription: `"Bastion $($r.Desc)`"`n---`n`n" + $txt)
  }
  Write-Block (Join-Path $Target ".github\copilot-instructions.md") @"
## Security Rules (Bastion v$Version)

Follow the Bastion rules in .github/instructions/bastion-*.instructions.md and .bastion/BASTION.md.
Never violate the 12 Red Lines. Cite rule IDs in reviews and commit messages.
"@
  $gp = Join-Path $Target ".github\prompts"; New-Item -ItemType Directory -Force -Path $gp | Out-Null
  $Cmds | ForEach-Object { Copy-Item $_.FullName (Join-Path $gp ($_.BaseName + ".prompt.md")) -Force }
  Ok "GitHub Copilot instructions and prompt files added (.github\)"
}

# ---------------------------------------------------------------------
# 7. Windsurf
# ---------------------------------------------------------------------
if (Want "windsurf") {
  $wr = Join-Path $Target ".windsurf\rules"; New-Item -ItemType Directory -Force -Path $wr | Out-Null
  Get-ChildItem $wr -Filter "bastion-*.md" -ErrorAction SilentlyContinue | Remove-Item -Force
  Write-Text (Join-Path $wr "bastion-core.md") ("---`ntrigger: always_on`n---`n`n" + $Lite)
  Write-Text (Join-Path $wr "bastion-project.md") ("---`ntrigger: always_on`n---`n`n" + $Proj)
  foreach ($id in $Active) {
    $r = Row $id
    $txt = Read-Text (Join-Path $Src "rules\platforms\$($r.File)")
    Write-Text (Join-Path $wr "bastion-$id.md") ("---`ntrigger: glob`nglobs: $($r.Globs)`n---`n`n" + $txt)
  }
  Ok "Windsurf rules added (.windsurf\rules\)"
}

# ---------------------------------------------------------------------
# 8. Cline and Roo Code
# ---------------------------------------------------------------------
if (Want "cline") {
  $cl = Join-Path $Target ".clinerules"
  if (Test-Path $cl -PathType Leaf) { Warn ".clinerules is a single file. Skipping Cline. Convert it to a folder to enable Bastion." }
  else {
    New-Item -ItemType Directory -Force -Path $cl | Out-Null
    Get-ChildItem $cl -Filter "bastion-*.md" -ErrorAction SilentlyContinue | Remove-Item -Force
    Copy-Item (Join-Path $Src "BASTION.md") (Join-Path $cl "bastion-core.md") -Force
    Copy-Item $ProjectRules (Join-Path $cl "bastion-project.md") -Force
    foreach ($id in $Active) { $f = (Row $id).File; Copy-Item (Join-Path $Src "rules\platforms\$f") (Join-Path $cl "bastion-$f") -Force }
    Ok "Cline rules added (.clinerules\)"
  }
}

# ---------------------------------------------------------------------
# 9. VS Code
# ---------------------------------------------------------------------
if (Want "vscode") {
  foreach ($n in "extensions.json","settings.json","tasks.json") {
    Copy-IfAbsent (Join-Path $Src "integrations\vscode\$n") (Join-Path $Target ".vscode\$n")
  }
}

# ---------------------------------------------------------------------
# 10. CI templates
# ---------------------------------------------------------------------
if ($WithCI) {
  Copy-IfAbsent (Join-Path $Src "templates\github\workflows\bastion-security.yml") (Join-Path $Target ".github\workflows\bastion-security.yml")
  Copy-IfAbsent (Join-Path $Src "templates\github\dependabot.yml") (Join-Path $Target ".github\dependabot.yml")
}

# ---------------------------------------------------------------------
# 10b. MCP server config (project scope)
# ---------------------------------------------------------------------
if ($WithMCP) {
  $entry = '{' + "`n" + '  "mcpServers": {' + "`n" + '    "bastion": { "command": "npx", "args": ["-y", "bastion-security-mcp"] }' + "`n" + '  }' + "`n" + '}' + "`n"
  foreach ($f in ".mcp.json", ".cursor\mcp.json") {
    $p = Join-Path $Target $f
    if (Test-Path $p) { Warn "Kept existing $f" } else { Write-Text $p $entry; Ok "Added $f" }
  }
  $vs = Join-Path $Target ".vscode\mcp.json"
  if (Test-Path $vs) { Warn "Kept existing .vscode\mcp.json" }
  else { Write-Text $vs ('{' + "`n" + '  "servers": {' + "`n" + '    "bastion": { "type": "stdio", "command": "npx", "args": ["-y", "bastion-security-mcp"] }' + "`n" + '  }' + "`n" + '}' + "`n"); Ok "Added .vscode\mcp.json" }
}

# ---------------------------------------------------------------------
# 11. .gitignore safety net
# ---------------------------------------------------------------------
$gif = Join-Path $Target ".gitignore"
$existing = ""
if (Test-Path $gif) { $existing = Read-Text $gif }
if ($existing -notmatch "BASTION secret patterns") {
  $add = "`n# BASTION secret patterns (do not commit secrets)`n.env`n.env.*`n!.env.example`n*.pem`n*.key`n*.p12`n*.pfx`n*.jks`n*.keystore`nkeystore.properties`nserviceAccount*.json`n"
  Write-Text $gif ($existing + $add)
  Ok ".gitignore secret patterns added"
}

Write-Host ""
Write-Host "  Bastion v$Version installed." -ForegroundColor Green
if ($Active.Count -gt 0) { Write-Host "  Platforms: $($Active -join ' ')" } else { Write-Host "  Platforms: core only" }
Write-Host "  Next: open the project in Claude Code, Cursor, VS Code, or your agent and run  /bastion-secure"
Write-Host ""
