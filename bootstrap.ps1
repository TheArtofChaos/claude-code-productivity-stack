<#
  bootstrap.ps1 — Plug-and-play restore of the Claude Code productivity stack.
  Idempotent: safe to re-run. Uses $env:USERPROFILE; contains no personal data.

  USAGE (new machine / new account):
    1. Install Claude Code, Node >=20, Git, Python 3.10+ first.
    2. git clone <YOUR_SETUP_REPO> ; cd into it.
    3. (optional) edit the CONFIG block below — vault location.
    4. pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1
    5. Do the MANUAL post-steps it prints at the end.
#>

# ───────────────────────── CONFIG ─────────────────────────
$VaultDir   = "$env:USERPROFILE\Vault"          # where the Obsidian vault lives
$VaultRepo  = "<YOUR_OBSIDIAN_VAULT_REPO_URL>"   # e.g. git@github.com:you/obsidian-vault.git  (leave as-is to skip clone)
$ClaudeHome = "$env:USERPROFILE\.claude"
$RepoRoot   = $PSScriptRoot
$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "  $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "  OK $m" -ForegroundColor Green }
function Warn($m){ Write-Host "  ! $m" -ForegroundColor Yellow }
function Have($n){ [bool](Get-Command $n -ErrorAction SilentlyContinue) }

function ClaudeExe {
  $c = (Get-Command claude -ErrorAction SilentlyContinue).Source
  if (-not $c) { $c = "$env:USERPROFILE\.local\bin\claude.exe" }
  if (-not (Test-Path $c)) { throw "Claude Code CLI not found. Install it first." }
  return $c
}

Write-Host "`n=== Claude Code stack bootstrap ===`n" -ForegroundColor White

# ───────────── 1. Prerequisites ─────────────
Info "Checking prerequisites..."
if (-not (Have node)) { throw "Node.js >=20 required." }
if (-not (Have git))  { throw "Git required." }
if (-not (Have python)) { throw "Python 3.10+ required." }
$claude = ClaudeExe
Ok "Node $(node --version), $(git --version), claude present"

# uv (for graphify + obsidian MCP tooling)
if (-not (Have uv)) {
  Info "Installing uv..."; powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex" | Out-Null
}
$uv = (Get-Command uv -ErrorAction SilentlyContinue).Source; if (-not $uv) { $uv = "$env:USERPROFILE\.local\bin\uv.exe" }
Ok "uv ready"

# gh (for GitHub backups)
if (-not (Have gh) -and -not (Test-Path "C:\Program Files\GitHub CLI\gh.exe")) {
  Info "Installing GitHub CLI..."; winget install --id GitHub.cli -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
}
Ok "gh ready (run 'gh auth login' in post-steps)"

# ───────────── 2. Python + CLI tooling ─────────────
Info "Installing Python tooling (notebooklm, yt-dlp, transcript api)..."
python -m pip install --quiet --upgrade "notebooklm-py[browser]" yt-dlp curl_cffi youtube-transcript-api | Out-Null
python -m playwright install chromium | Out-Null
Ok "Python tooling installed"

Info "Installing graphify CLI (code knowledge-graph)..."
& $uv tool install graphifyy 2>$null | Out-Null
Ok "graphify ready"

# ───────────── 3. Marketplaces ─────────────
Info "Adding plugin marketplaces..."
$markets = @(
  "obra/superpowers-marketplace","ruvnet/ruflo","kepano/obsidian-skills",
  "nextlevelbuilder/ui-ux-pro-max-skill","DietrichGebert/ponytail","pbakaus/impeccable",
  "anthropics/skills","coreyhaines31/marketingskills","charlie947/social-media-skills",
  "AgriciDaniel/claude-seo","anthropics/financial-services","anthropics/claude-for-legal",
  "taoufik123-collab/claude-watch"
)
foreach ($m in $markets) { & $claude plugin marketplace add $m 2>$null | Out-Null }
Ok "$($markets.Count) marketplaces added"

# ───────────── 4. Plugins (enabled) ─────────────
Info "Installing always-on plugins..."
$enabled = @(
  "superpowers@superpowers-marketplace","obsidian@obsidian-skills","ui-ux-pro-max@ui-ux-pro-max-skill",
  "ponytail@ponytail","impeccable@impeccable","document-skills@anthropic-agent-skills","watch@claude-watch"
)
foreach ($p in $enabled) { & $claude plugin install $p 2>$null | Out-Null }
Ok "Enabled plugins installed"

# ───────────── 5. Plugins (on-demand → installed then DISABLED) ─────────────
Info "Installing on-demand plugins (disabled by default)..."
$ondemand = @("ruflo-core@ruflo","ruflo-swarm@ruflo","marketing-skills@marketingskills",
              "social-media-skills@social-media-skills","claude-seo@agricidaniel-claude-seo")
foreach ($p in $ondemand) { & $claude plugin install $p 2>$null | Out-Null }
foreach ($p in $ondemand) { & $claude plugin disable ($p.Split("@")[0]) 2>$null | Out-Null }
Ok "On-demand plugins installed + disabled (financial-services/claude-for-legal are register-only — install a vertical when needed)"

# ───────────── 6. gsd-core (staged, no global hook) ─────────────
Info "Staging gsd-core (on-demand, no global hook)..."
$gsd = "$ClaudeHome\ondemand\gsd-core"
if (-not (Test-Path "$gsd\.claude-plugin\plugin.json")) {
  New-Item -ItemType Directory -Force -Path "$ClaudeHome\ondemand" | Out-Null
  Push-Location $env:TEMP
  npm pack @opengsd/gsd-core@latest 2>$null | Out-Null
  $tgz = Get-ChildItem "opengsd-gsd-core-*.tgz" | Select-Object -First 1
  if ($tgz) { tar -xzf $tgz.FullName 2>$null; if (Test-Path "$gsd") { Remove-Item $gsd -Recurse -Force }; Move-Item "package" $gsd -Force }
  Pop-Location
}
Ok "gsd-core staged at ~/.claude/ondemand/gsd-core (launch with: claude --plugin-dir <that path>)"

# ───────────── 7. Custom skills + CLAUDE.md ─────────────
Info "Copying custom skills + global CLAUDE.md..."
Copy-Item "$RepoRoot\CLAUDE.md" "$ClaudeHome\CLAUDE.md" -Force
foreach ($s in @("wrapup","project-kickoff","backup","devteam","research")) {
  New-Item -ItemType Directory -Force -Path "$ClaudeHome\skills\$s" | Out-Null
  Copy-Item "$RepoRoot\skills\$s\SKILL.md" "$ClaudeHome\skills\$s\SKILL.md" -Force
}
& $claude plugin --% >$null 2>&1   # no-op touch
# notebooklm skill (from the pip package)
if (Have notebooklm) { notebooklm skill install 2>$null | Out-Null }
Ok "Custom skills + CLAUDE.md installed"

# ───────────── 8. settings.json (hooks + statusline + plugin state) ─────────────
Info "Writing settings.json (paths templated to this user)..."
$ponyStatus = Get-ChildItem "$ClaudeHome\plugins\cache\ponytail\ponytail\*\hooks\ponytail-statusline.ps1" -ErrorAction SilentlyContinue | Select-Object -First 1
$nudge = '{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":\"Project tip: run /kickoff to see available skills and a token-efficient toolset recommendation.\"}}'
$settings = [ordered]@{
  hooks = @{ SessionStart = @(@{ hooks = @(@{ type="command"; shell="powershell"; timeout=10;
            command = "Write-Output '$nudge'" }) }) }
  enabledPlugins = [ordered]@{
    "superpowers@superpowers-marketplace"=$true; "obsidian@obsidian-skills"=$true;
    "ui-ux-pro-max@ui-ux-pro-max-skill"=$true; "ponytail@ponytail"=$true; "impeccable@impeccable"=$true;
    "document-skills@anthropic-agent-skills"=$true; "watch@claude-watch"=$true;
    "ruflo-core@ruflo"=$false; "ruflo-swarm@ruflo"=$false; "marketing-skills@marketingskills"=$false;
    "social-media-skills@social-media-skills"=$false; "claude-seo@agricidaniel-claude-seo"=$false }
  autoUpdatesChannel = "latest"; skipWorkflowUsageWarning = $true
}
if ($ponyStatus) { $settings.statusLine = @{ type="command"; command = "powershell -ExecutionPolicy Bypass -File `"$($ponyStatus.FullName)`"" } }
($settings | ConvertTo-Json -Depth 8) | Set-Content "$ClaudeHome\settings.json" -Encoding utf8
Ok "settings.json written (marketplaces re-added by the steps above)"

# ───────────── 9. Obsidian vault + search MCP ─────────────
Info "Setting up Obsidian vault + search MCP..."
if ($VaultRepo -notlike "<*>" -and -not (Test-Path "$VaultDir\.git")) { git clone $VaultRepo $VaultDir 2>$null }
if (-not (Test-Path $VaultDir)) { New-Item -ItemType Directory -Force -Path $VaultDir | Out-Null }
& $claude mcp add obsidian -s user -- npx -y obsidian-mcp "$VaultDir" 2>$null | Out-Null
Ok "Obsidian search MCP registered for $VaultDir"

# ───────────── 10. NotebookLM keepalive task (hidden) ─────────────
Info "Registering NotebookLM keepalive (hidden, every 15 min)..."
$nbExe = (Get-Command notebooklm -ErrorAction SilentlyContinue).Source
if ($nbExe) {
  $vbs = "$env:USERPROFILE\.notebooklm\keepalive.vbs"
  New-Item -ItemType Directory -Force -Path (Split-Path $vbs) | Out-Null
  "CreateObject(""WScript.Shell"").Run ""cmd /c """"$nbExe"""" auth refresh"", 0, True" | Set-Content $vbs -Encoding ascii
  $act = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$vbs`""
  $trg = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 15) -RepetitionDuration (New-TimeSpan -Days 3650)
  $set = New-ScheduledTaskSettingsSet -StartWhenAvailable -Hidden -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
  Register-ScheduledTask -TaskName "NotebookLM-KeepAlive" -Action $act -Trigger $trg -Settings $set -Force | Out-Null
  Ok "Keepalive task registered (silent)"
} else { Warn "notebooklm not on PATH yet — re-run after restarting the shell to register keepalive" }

# ───────────── Done ─────────────
Write-Host "`n=== Bootstrap complete. MANUAL post-steps: ===" -ForegroundColor White
Write-Host @"
  1. notebooklm login            (browser sign-in for NotebookLM; required once)
  2. gh auth login               (for GitHub backups)
  3. Obsidian: install 'Claudian' + 'Local REST API' from Community Plugins (GUI only)
  4. (optional) winget install ffmpeg   — only for /watch video frame-grab
  5. Restart Claude Code so plugins/skills/hooks/statusline load
  6. Recreate NotebookLM notebooks on first /wrapup (AI Brain auto-creates)
"@ -ForegroundColor Gray
