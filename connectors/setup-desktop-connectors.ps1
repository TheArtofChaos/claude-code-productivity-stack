<#
  setup-desktop-connectors.ps1 — register local MCP connectors into the Claude Desktop app
  so Cowork / desktop chat can automate against your Obsidian vault + NotebookLM (like Claude Code).
  Idempotent. Restart the Claude Desktop app afterwards. No personal data.

  Prereqs: Node (for npx obsidian-mcp); Python + `pip install fastmcp` + `notebooklm login` (for NotebookLM).
#>
param([string]$VaultDir = "$env:USERPROFILE\Vault")

$cfg = "$env:APPDATA\Claude\claude_desktop_config.json"
if (-not (Test-Path $cfg)) { '{ "mcpServers": {} }' | Set-Content $cfg -Encoding utf8 }

$j = Get-Content $cfg -Raw | ConvertFrom-Json
if (-not $j.PSObject.Properties.Name -contains 'mcpServers' -or -not $j.mcpServers) {
    $j | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([pscustomobject]@{}) -Force
}

# Obsidian — search/read/write the vault
$j.mcpServers | Add-Member -NotePropertyName 'obsidian' -NotePropertyValue ([pscustomobject]@{
    command = 'cmd'; args = @('/c', 'npx', '-y', 'obsidian-mcp', $VaultDir)
}) -Force

# NotebookLM — thin wrapper around the notebooklm CLI (server.py sits next to this script)
$py = (Get-Command python -ErrorAction SilentlyContinue).Source
if (-not $py) { $py = 'python' }
$server = Join-Path $PSScriptRoot 'notebooklm-mcp\server.py'
$j.mcpServers | Add-Member -NotePropertyName 'notebooklm' -NotePropertyValue ([pscustomobject]@{
    command = $py; args = @($server)
}) -Force

$j | ConvertTo-Json -Depth 16 | Set-Content $cfg -Encoding utf8
Write-Host "Added 'obsidian' + 'notebooklm' connectors to $cfg"
Write-Host "Now: pip install fastmcp ; notebooklm login ; then RESTART the Claude Desktop app."
