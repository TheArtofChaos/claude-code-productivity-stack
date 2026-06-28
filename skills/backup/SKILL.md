---
name: backup
description: >-
  Refresh and push the GitHub backups. Triggers on "/backup", "backup", "push backups",
  or "save to github". Re-copies the curated ~/.claude setup files into the staging repo,
  then commits + pushes both private repos (claude-code-setup and obsidian-vault). Never
  backs up credentials, native memory, or auth cookies.
---

# Backup → GitHub

Keep the two private repos fresh: **claude-code-setup** (bespoke Claude glue) and **obsidian-vault** (notes).

Paths:
- Setup source: `$HOME\.claude\`
- Setup staging repo: `<this-repo>\`  → remote `origin` (claude-code-setup)
- Vault repo: `$HOME\Vault\`  → remote `origin` (obsidian-vault)
- gh: `C:\Program Files\GitHub CLI\gh.exe` (or `gh` if on PATH); git is on PATH.

## 🔒 Never back up (hard rule)
- `~/.claude/projects/*/memory/` (may contain credentials, e.g. passwords or tokens)
- `~/.notebooklm/` / any `storage_state.json` (Google auth cookies)
- API tokens / secrets of any kind
If a file under those paths would be copied, STOP and skip it.

## Procedure

### Step 1 — Refresh the setup staging copy
Copy the curated, secret-free files into the staging repo (create dirs as needed):
```
copy  ~/.claude/CLAUDE.md                              -> claude-setup-backup/CLAUDE.md
copy  ~/.claude/settings.json                          -> claude-setup-backup/settings.json
copy  ~/.claude/skills/wrapup/SKILL.md                 -> claude-setup-backup/skills/wrapup/SKILL.md
copy  ~/.claude/skills/project-kickoff/SKILL.md        -> claude-setup-backup/skills/project-kickoff/SKILL.md
copy  ~/.claude/skills/backup/SKILL.md                 -> claude-setup-backup/skills/backup/SKILL.md
```
(Add any other *custom* skill you've authored under `~/.claude/skills/` — but NOT plugin-managed or
marketplace skills, which reinstall from source.)

### Step 2 — Commit + push the setup repo
```
git -C "<this-repo>" add -A
git -C "<this-repo>" -c user.name="<your-git-username>" commit -m "backup: <YYYY-MM-DD>"
git -C "<this-repo>" push
```
If "nothing to commit", skip the push and say so.

### Step 3 — Commit + push the vault
The vault `.gitignore` already excludes Drive temp + Obsidian workspace state.
```
git -C "$HOME\Vault" add -A
git -C "$HOME\Vault" -c user.name="<your-git-username>" commit -m "vault backup: <YYYY-MM-DD>"
git -C "$HOME\Vault" push
```
If "nothing to commit", skip.

### Step 4 — Report
State, per repo: pushed (with short stat) or "no changes". Use today's real date in commit messages.

## Notes
- Auth is via the gh keyring (account <your-git-username>); if push fails on auth, tell the user to run `gh auth login`.
- This is on-demand. (It is NOT wired into `/wrapup` — run it explicitly when you want a snapshot.)
