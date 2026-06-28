# Stack Manifest

Complete inventory of the Claude Code productivity stack restored by `bootstrap.ps1`. No personal data.

## Always-on layer (skills — lazy-loaded, ~one-line cost each until fired)
| Plugin | Source | Purpose |
|---|---|---|
| superpowers | obra/superpowers-marketplace | TDD, debugging, brainstorming, planning, parallel-agent dispatch, code-review, worktrees |
| ponytail | DietrichGebert/ponytail | YAGNI/stdlib-first "lazy senior dev" — net token-saver per coding task |
| obsidian | kepano/obsidian-skills | Obsidian markdown / bases / canvas / CLI / defuddle |
| ui-ux-pro-max | nextlevelbuilder/ui-ux-pro-max-skill | UI/UX design systems, palettes, typography |
| impeccable | pbakaus/impeccable | Anti-AI-slop frontend audit (on-demand commands; hook silenceable) |
| document-skills | anthropics/skills | Create real .docx / .pdf / .xlsx / .pptx |
| watch | taoufik123-collab/claude-watch | "Watch" a video (transcript + optional frames) |
| notebooklm | notebooklm-py (pip) | NotebookLM CLI bridge (memory + deliverables) |

**Custom skills** (in `skills/`): `wrapup` (save session → all 3 memory layers), `project-kickoff` (start-of-project tool picker), `backup` (push setup + vault to git), `devteam` (multi-agent coding router), `research` (source → NotebookLM → vault pipeline).

## On-demand layer (installed but DISABLED — enable per task, disable after)
| Plugin | Source | When |
|---|---|---|
| ruflo-core / ruflo-swarm | ruvnet/ruflo | Heavy parallel "agent swarm" builds (3–10× tokens) |
| marketing-skills | coreyhaines31/marketingskills | Marketing/growth work |
| social-media-skills | charlie947/social-media-skills | Posts/threads/carousels |
| claude-seo | AgriciDaniel/claude-seo | SEO + AI-search optimization |
| gsd-core | @opengsd/gsd-core (npx) | Spec-driven phase workflow — staged at `~/.claude/ondemand/gsd-core`, loaded via `--plugin-dir` |
| financial-services / claude-for-legal | anthropics/* | Register-only; install a vertical when needed |

## Tooling (installed by bootstrap)
Node ≥20, Git, Python ≥3.10, `uv`, GitHub CLI, `graphify` (code knowledge-graph), `notebooklm-py[browser]` + Playwright Chromium, `yt-dlp`, `curl_cffi`, `youtube-transcript-api`.

## Connectors / automation
- **Obsidian search MCP** — `obsidian-mcp` (user scope), points at the vault; search-as-a-tool over notes.
- **NotebookLM-KeepAlive** — hidden Windows scheduled task, `notebooklm auth refresh` every 15 min (keeps auth warm).
- **SessionStart hook** — one-line `/kickoff` nudge. **Statusline** — ponytail mode badge.

## Memory — three layers, tiered recall (cheapest first)
1. **Native** (`CLAUDE.md` + per-project `memory/`) — auto-recalled, ~0 extra tokens.
2. **Obsidian vault** — human-browsable knowledge base (Inbox → Wiki → Outputs; AI-Second-Brain `index.md` + `log.md`).
3. **NotebookLM** — deep session/doc archive, queried on demand; written by `/wrapup`.

## Vault structure (separate repo)
`Inbox/` (raw) → `Wiki/` (Knowledge + Projects, backlinked) → `Outputs/` (generated), plus `Tasks/`, `Memory/Sessions/`, and a vault-root `CLAUDE.md` schema (auto-loads when Claude Code opens the vault).
