---
name: wrapup
description: >-
  Save / wrap up the current session into long-term memory. Triggers on "/wrapup",
  "wrap up", "save this session", "end of session", or "session summary". Reviews the
  conversation, updates native project memory, and pushes a session log to the NotebookLM
  "AI Brain" notebook for token-free recall in future sessions.
---

# Session Wrap-Up — Infinite Memory

Persist what matters from this session into **three complementary stores**:

1. **Native memory** (always-loaded, high-signal facts) — the per-project memory dir.
2. **Obsidian vault** (`$HOME\Vault`) — human-browsable session note, linked into the project page.
3. **NotebookLM "AI Brain"** (full session log, queried on demand at ~no token cost).

This keeps future sessions cheap: durable facts ride in native memory; a browsable copy lives
in the vault; deep history lives in NotebookLM and is pulled only when needed.

## When to run
On any of: `/wrapup`, "wrap up", "save this session", "end of session", "session summary".
Also offer to run it proactively when a substantial piece of work completes.

## Procedure

### Step 1 — Review the session
Scan the conversation and extract, concisely:
- **Completed work** — what was actually done/changed (with key paths).
- **Decisions** — choices made and the *why* (not just the what).
- **Learnings** — non-obvious facts discovered (gotchas, root causes, constraints).
- **Open items** — unfinished work, blockers, follow-ups.
- **User preferences / feedback** — how the user wants things done.
Skip anything trivially re-derivable from the code or git history.

### Step 2 — Update native memory
Memory dir for the current project (Windows):
`C:\Users\<USER>\.claude\projects\<project-slug>\memory\`
(`<project-slug>` = the cwd with drive/separators turned into dashes, e.g.
`<your-project-slug>`). Create the dir only if absent.

Follow the existing memory convention exactly:
- One fact per file, kebab-case `name`, with frontmatter:
  `---\nname: <slug>\ndescription: <one-line>\nmetadata:\n  type: user | feedback | project | reference\n---`
- For `feedback`/`project`, add **Why:** and **How to apply:** lines. Link related notes with `[[name]]`.
- Add/refresh a one-line pointer in `MEMORY.md` (`- [Title](file.md) — hook`).
- **Update** an existing file rather than duplicating; delete facts proven wrong.
- Convert relative dates to absolute. Don't store what the repo/CLAUDE.md already records.

### Step 3 — Write the session log
Write a concise markdown log (objective, what changed, decisions+why, open items, key paths/commands)
to a working file (`<cwd>\.notebooklm\sessions\session-YYYY-MM-DD.md` if a project notebook exists,
else `%TEMP%\session-YYYY-MM-DD.md`). Use today's real date.

### Step 3b — Save a copy into the Obsidian vault
Also write the log to `$HOME\Vault\Memory\Sessions\session-YYYY-MM-DD.md` with frontmatter
(`type: session`, `tags`, `updated: YYYY-MM-DD`) and a top-line link to the relevant project page
(e.g. `Project:: [[<your-project>]]`). If a session note for today already exists, append a new
`## <time>` section rather than overwriting. Add a bullet under the project page's recent-activity
if the session was notable. This is a local file write — no auth needed.

### Step 4 — Push to NotebookLM (auto-recover on auth failure)
Verify auth: `notebooklm auth check --test --json` → require `"status":"ok"` and `checks.token_fetch:true`.
If it fails, **auto-recover before skipping**: run `notebooklm auth refresh` (silent server-side); if still not ok, run `notebooklm login` (re-grabs from the persistent browser profile — usually instant, no manual sign-in). Re-check, then proceed. Only if BOTH fail (browser profile itself logged out → needs interactive sign-in) do you save Steps 2–3 locally and tell the user to run `notebooklm login`. Never hard-error.

Resolve the target notebook:
1. Project notebook: if `<cwd>\.notebooklm\config.json` exists, read its `notebook_id`.
2. Else the global brain: `notebooklm list --json` → find the notebook titled **"AI Brain"**.
   If none exists, create it: `notebooklm create "AI Brain" --json` (parse `.notebook.id`).

Push the log as a source:
```
notebooklm source add "<path-to-session-log.md>" --notebook <NOTEBOOK_ID>
```

### Step 5 — Confirm
Report briefly: which native-memory files were written/updated, the Obsidian vault note path,
and whether the NotebookLM push succeeded (or was skipped pending login).

## Recall (the other half of the loop) — tiered, cheapest first
When you need past context, escalate only as needed:
1. **Native memory** — already in context; check it first (~0 extra tokens).
2. **Obsidian vault** `$HOME\Vault` — `grep` then read the specific note (cheap, local).
3. **AI Brain** — last resort for deep history: `notebooklm ask "what did we decide about X?"`
   (one external call). Far cheaper than rebuilding context in-chat.

## Notes
- This skill is built on the installed `notebooklm` (teng-lin) CLI; it does not replace it.
- Default memory scope is the single global **AI Brain** notebook (works across all projects).
  To use a dedicated notebook for a project, drop `{"notebook_id":"..."}` in `<cwd>\.notebooklm\config.json`.
