# Claude Code Productivity Stack — Plug-and-Play Setup

Portable, version-controlled backup of a cost-tuned Claude Code stack: a cheap always-on skill layer, heavy harnesses kept on-demand, a three-layer memory system (native + Obsidian + NotebookLM), code knowledge-graph navigation, and a research pipeline. **Contains no secrets or personal data** — credentials, auth cookies, and private notes are deliberately excluded.

## What's here
- `bootstrap.ps1` — idempotent installer; restores the whole stack on a fresh machine/account.
- `MANIFEST.md` — full inventory of every plugin, skill, tool, and connector.
- `CLAUDE.md` — the global control panel (loaded into every session).
- `settings.json` — hooks, status line, plugin enable/disable state.
- `skills/` — the bespoke skills (`wrapup`, `project-kickoff`, `backup`, `devteam`, `research`).

## Plug-and-play restore
```powershell
# Prereqs: Claude Code, Node >=20, Git, Python 3.10+
git clone <THIS_REPO>
cd <THIS_REPO>
pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1
```
Then do the **manual post-steps** the script prints (NotebookLM login, `gh auth login`, install the `Claudian` Obsidian plugin, restart Claude Code). Total: a few minutes.

## Keeping it fresh
Run `/backup` from Claude Code anytime — it re-syncs this repo and the vault repo to GitHub. Excludes native memory and auth cookies (which hold credentials).

## Transfer notes (new account / machine)
- `bootstrap.ps1` generates `settings.json` with the new machine's paths; nothing is hardcoded to the old machine.
- NotebookLM notebooks (e.g. "AI Brain", "Vault") **auto-recreate on first `/wrapup`** — `wrapup` finds them by title, not by ID, so any IDs in `CLAUDE.md` are convenience references that self-heal.
- If your Google account differs, update the one email reference line in `CLAUDE.md`.
- The Obsidian vault is a **separate repo** — set `$VaultRepo` in `bootstrap.ps1` (or clone it manually); the search MCP points at `$VaultDir`.
- After bootstrap + `notebooklm login`, run `/backup` once to confirm the loop.

## Stakeholder overview
`docs/Claude-Code-Stack-Overview.pdf` — a sanitized one-pager (no personal data) on the architecture, token economics, and ROI, suitable for dev team / stakeholders. Source: `docs/report.html`.

## Design principle
Cheap layer always on (lazy-loaded skills ≈ a one-line description each until fired); expensive harnesses (swarm, spec-engines) installed but **disabled** so idle cost is zero; heavy analysis offloaded to NotebookLM (free Google compute) and code navigation to a local graph — minimizing token spend while maximizing capability.
