# Cowork — what it can and can't do (corrected)

**Key fact:** Cowork runs in an **isolated cloud Linux sandbox**. It CANNOT touch your Windows machine, run PowerShell, run `bootstrap.ps1`, do interactive logins, or install Obsidian/desktop plugins. Those are **local** steps. Do NOT ask Cowork to run the setup — it can't, and it's right to refuse.

## Division of labor
| Task | Who does it |
|---|---|
| Install the stack (`bootstrap.ps1`), plugin/tool installs, `notebooklm login`, `gh auth login`, add connectors in the app UI | **You, locally** — in your terminal, or via **Claude Code** (runs on your machine) |
| Read/write your Obsidian vault from Cowork | **Cowork** — via **"Connect the folder" → `$HOME\Vault`** (folder-connection bridges local files into its sandbox) |
| Vet the installer / build a runbook | **Cowork** — connect `<this-repo>`, it reads `MANIFEST.md`/`README.md`/`bootstrap.ps1` |
| NotebookLM automation | **Claude Code only** (local stdio MCP; a cloud Cowork sandbox can't reach a local process). In Cowork, use NotebookLM manually / in its own tab. |

## To use Cowork with your knowledge base
1. In Cowork, choose **Connect the folder** and select **`$HOME\Vault`** (read/write your notes) — optionally also `<this-repo>`.
2. Then just work: "search my vault for X", "draft a note in Outputs about Y", "process my Inbox". It edits the files directly.
3. Follow `$HOME\Vault\CLAUDE.md` conventions (Inbox→Wiki→Outputs).

## Doing the actual install (local — you or Claude Code)
Run in your own terminal (idempotent):
```
pwsh -ExecutionPolicy Bypass -File "<this-repo>\bootstrap.ps1"
```
Then: `notebooklm login`; `gh auth login`; install **Claudian** + **Local REST API** in Obsidian; `pip install fastmcp`.
Verify: `claude plugin list`, `claude mcp list` (obsidian + notebooklm = Connected). These are already done on the current machine.
