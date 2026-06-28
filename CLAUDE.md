# Global Claude Code Setup — Control Panel

A productivity stack tuned for **cost/efficiency**: a cheap always-on layer, with
heavy harnesses installed but **dormant** until explicitly summoned. Keep this file
lean — it is injected into every session.

## Always-on layer (~1.3k tokens total, no per-tool-call hooks)
Skills are loaded lazily: only a one-line description sits in context until a skill fires.

| Plugin | Purpose | Always-on |
|---|---|---|
| `superpowers` | Methodology skills: TDD, systematic-debugging, brainstorming, writing/executing-plans, dispatching-parallel-agents, code-review, git-worktrees | ~608 tok |
| `obsidian` (kepano) | Obsidian file formats: markdown, bases, json-canvas, obsidian-cli, defuddle (clean web→markdown) | ~417 tok |
| `ui-ux-pro-max` | UI/UX design systems, palettes, typography (search engine; on Windows use `python` not `python3`) | ~236 tok |
| `ponytail` | YAGNI / stdlib-first "lazy senior dev" ruleset — writes less code; **net token-saver** per task. Cmds: `/ponytail-review`, `/ponytail-audit` | ~622 tok |
| `impeccable` | Anti-AI-slop frontend audit; complements ui-ux-pro-max. On-demand `/impeccable …` cmds (audit/polish/critique). Silence its hook with `/impeccable hooks off` | ~229 tok |
| `document-skills` (Anthropic official) | Create real `.docx`/`.pdf`/`.xlsx`/`.pptx` files | ~734 tok |
| `humanizer` (skill) | De-robotify AI writing (emails/posts). Lightweight | small |

NotebookLM connector is also live (skill `notebooklm`). Also live: `wrapup` (save session → all 3 memory layers), `project-kickoff` (start-of-project tool picker — a SessionStart hook nudges you to run `/kickoff`), `devteam` (multi-agent coding; ruflo swarm only for heavy builds), and `research` (source → NotebookLM analysis → Obsidian, the composite pipeline). Memory upkeep: run `consolidate-memory` periodically (the "dream" routine — merge dupes, fix stale facts/dates, prune the index).

## On-demand harnesses (idle cost = 0)
Heavy hooks/MCP — enable only for the task, **disable when done**.

**ruflo** (swarm orchestrator — registers PreToolUse/PostToolUse hooks + a 300+ tool MCP server when enabled; 3–10× tokens in swarm mode):
```
claude plugin enable ruflo-core ruflo-swarm     # turn ON for a heavy parallel task
claude plugin disable ruflo-core ruflo-swarm    # turn OFF afterwards (do this!)
```
**Dev team (multi-agent coding):** `/devteam` skill routes by weight — Superpowers parallel subagents for light/medium work (cheap), escalates to the **ruflo swarm** only for genuinely heavy builds (4 roles: Architect→Coder(s)→Reviewer→Tester), enabling ruflo on demand and disabling after.

Full ruflo catalog is 38 plugins (marketplace `ruflo` already added). Add any on demand:
```
claude plugin install <name>@ruflo              # e.g. ruflo-rag-memory, ruflo-sparc, ruflo-goals, ruflo-autopilot
```
Then `disable` it when idle.

**gsd-core** (spec-driven phase workflow — global install would add always-on hooks, so it is NOT installed globally). Two on-demand options, both zero idle cost:
- Per-session, no install: `claude --plugin-dir "$HOME\.claude\ondemand\gsd-core"`
- Per-project, persistent for that repo only:
  `npx @opengsd/gsd-core@latest --claude --local`   (remove with `--uninstall`)

## On-demand content packs (installed, disabled — enable when doing that work)
Enable for the task, disable after — `claude plugin enable <name>` / `claude plugin disable <name>`:
- `marketing-skills` (coreyhaines31) — marketing/growth.
- `social-media-skills` (charlie947) — posts/threads/carousels/captions.
- `claude-seo` (AgriciDaniel) — SEO + AI-search (GEO/AEO) optimization.
- `humanizer` (blader) — already lightweight/available (de-robotify writing).
- **Domain packs (official Anthropic, register-only — install a vertical when needed):**
  - `financial-services` → `claude plugin install financial-analysis@claude-for-financial-services` (also investment-banking, equity-research, pitch-agent, market-researcher).
  - `claude-for-legal` → `claude plugin install commercial-legal@claude-for-legal` (also corporate-legal, privacy-legal, ip-legal, litigation-legal, …).

## Backups / GitHub (don't lose anything)
- **Obsidian vault** `$HOME\Vault` — git repo (Drive-synced too); pushed to a **private** GitHub repo. `.gitignore` excludes Drive temp + Obsidian workspace state.
- **Claude setup** — `~/.claude/CLAUDE.md`, `skills/wrapup`, `skills/project-kickoff`, `settings.json` backed up to a private repo.
- **DO NOT push** the native `memory/` dir or `~/.notebooklm/storage_state.json` — they hold credentials/auth cookies.

## Deferred / not installed
- **Graphify** (code→knowledge-graph) — **INSTALLED** (CLI `graphify` v0.8.47 at `~/.local/bin`; `graphifyy` is the author's real package per `github.com/safishamsi/graphify`). **Code-only, per-project, NO global hook** (`graphify install` was deliberately NOT run). Usage (offline, no API key): **`graphify update .`** builds/refreshes the **code** graph (use this — bare `graphify .` also ingests docs and errors without an LLM key). Then `graphify query "..."` / `path "A" "B"` / `explain "X"` against `graphify-out/graph.json`. Auto-rebuild via `graphify watch <path>`. Verified on a real 28-file module: 561 nodes/943 edges, queries return file:line. `/kickoff` + `/devteam` auto-engage it on code projects. **Never on `$HOME\Vault`** (Obsidian's own graph covers notes; doc extraction would bill the LLM API). Note: v0.8.47 has **no `graphify-obsidian` vault export** (seen in some videos) — for code, querying `graph.json` is better/cheaper than flooding the vault with stub notes; graph→notes would need a CLI upgrade or a small stub-generator (on request).
- **Higgsfield MCP** — skipped (paid media service; conflicts with the free-tools preference).

## Memory — three layers, tiered recall (cheapest first)
Three complementary stores. **On recall, escalate only when the cheaper tier lacks the answer:**
1. **Native memory** (`CLAUDE.md` + per-project `memory/` dir) — already auto-loaded into context → checking it costs ~0 extra tokens. **Always try here first.**
2. **Obsidian vault** (`$HOME\Vault`) — local files. `grep` then read the specific note. Cheap, targeted, no external call. Use when the fact is browsable knowledge / a project page.
3. **NotebookLM "AI Brain"** (`notebooklm ask` against id `<auto-created on first /wrapup>`, account <your-google-account>) — searches the full session archive server-side. Heaviest footprint (external tool call) → **last resort**, for deep history not in 1–2.

**Save (inverse):** one-line durable fact → native memory · browsable knowledge/project page → vault · full session record → `/wrapup` (writes native memory, a vault session note, **and** pushes a log to the AI Brain — all three).

- `/wrapup` triggers: "/wrapup", "wrap up", "save this session", "end of session".
- **Auth rule (EVERY `notebooklm` call):** never skip/fail on an auth error. On any auth failure, run `notebooklm auth refresh`; if still failing, `notebooklm login`; then **retry the command once**. Applies to all calls — ask, source add, recall, sync, `/wrapup`. (Refresh works on a warm cookie; a fully-dead one needs the `login` re-grab.)
- Proactive backstop: a Windows Scheduled Task **`NotebookLM-KeepAlive`** runs `notebooklm auth refresh` every 15 min to keep the cookie warm, so the rule above rarely has to fire. Only if the browser profile itself logs out is a one-time interactive `notebooklm login` needed.
- Doc-corpus RAG (e.g. LightRAG): **not pursued** — the vault + `index.md` + `obsidian-mcp` + NotebookLM already cover doc Q&A. Don't re-propose.

## External memory = token savings
Offload bulky reference material instead of pasting it into context, then query on demand:
- **NotebookLM** — `notebooklm` skill (manuals, transcripts, doc sets) + the **AI Brain** session archive above.
- **Obsidian vault** — `$HOME\Vault` (filesystem mode, free/local). Human-browsable knowledge base + second memory + task tracking. Read/write markdown directly with the `obsidian` skills; conventions + structure in `$HOME\Vault\CLAUDE.md` (auto-loaded when Claude Code opens the vault), dashboard `$HOME\Vault\Home.md`. Follows the Karpathy "LLM Wiki" / AI-Second-Brain pattern (Inbox=immutable raw → AI-maintained Wiki with index.md + log.md; ingest/query/lint workflows).
  - **Vault search MCP** (active, user scope): `claude mcp add obsidian -s user -- npx -y obsidian-mcp "$HOME\Vault"` (StevenStavrakis/obsidian-mcp — search/read/create/edit notes from disk; vault is git+Drive backed). Gives search-as-a-tool over grep.
  - **Vault → NotebookLM:** notebook **"Vault"** `<auto-created>` holds the Wiki notes for audio overviews + Q&A. No live sync — re-run `notebooklm source add` weekly for changed notes.
  - **Optional sidebar:** Claudian (free, official Obsidian community plugin) runs Claude Code in an Obsidian pane — install via Obsidian → Community plugins → Browse → "Claudian".

## Cost rules of thumb
- Keep the always-on layer as-is; don't enable a harness "just in case".
- Use `superpowers` `dispatching-parallel-agents` for parallelism before reaching for a ruflo swarm.
- Run `claude plugin details <name>` to see any plugin's projected token cost before enabling.
