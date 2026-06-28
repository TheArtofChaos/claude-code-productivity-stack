# Claude Code Productivity Stack — Onboarding

A plug-and-play configuration of **Claude Code** tuned for one goal: **maximum capability per token spent.** Clone it, run one script, and you inherit a cost-engineered setup with persistent memory, on-demand heavy automation, code-graph navigation, and a research pipeline. No secrets or personal data are included.

---

## What it does
Turns Claude Code from a stateless assistant into a **cost-aware, memory-keeping engineering environment**:
- A small **always-on skill layer** (methodology, an efficiency ruleset, UI/UX intelligence, document generation) that costs almost nothing until used.
- **Heavyweight automation kept dormant** (multi-agent "swarm", spec-driven workflow, vertical packs) — installed but disabled, so idle cost is zero; you enable it per task and disable after.
- **Three-layer persistent memory** so you stop re-explaining context every session.
- **Code knowledge-graph navigation** so the assistant traverses a repo by structure instead of reading everything.
- A **research pipeline** that offloads heavy analysis to free external compute and files results as linked notes.

## How it works
| Layer | What | Why it's cheap |
|---|---|---|
| **Always-on skills** | Lazy-loaded: only a one-line description sits in context until a skill fires | Adds ~2% of the context window per session, not the full skill bodies |
| **On-demand harnesses** | Swarm / spec-engine / vertical packs **installed but disabled** | 0 idle cost; no per-tool-call hook tax until you turn them on |
| **Memory (tiered recall)** | Native facts → local Obsidian vault → external notebook; always tries the cheapest source first | Recall replaces re-explaining context; deep history lives off-context |
| **Code graph** | A local graph (functions, calls, communities) you query by structure | 7–70× fewer tokens than searching a large repo; fully offline for code |
| **Research pipeline** | Source → external-compute analysis/deliverables → linked notes | Heavy analysis runs on free compute, not your token budget |

**The operating loop:** start a project → a prompt recommends a token-efficient toolset → work (with a multi-agent team only for big builds) → wrap up to persist decisions → one-command backup.

## What it saves you
- **Tokens / cost:** always-on footprint held near a fixed ~2% floor; the coding model is constrained to write less (a published, independently-reproduced benchmark shows ~71% fewer lines of code, ~53% lower cost, ~71% faster on a top-tier model); the most expensive automation is off by default.
- **Time:** no re-explaining context to a fresh session; up to ~70% faster on constrained coding tasks.
- **Compounding knowledge:** every session enriches a searchable knowledge base — institutional memory that survives session and staff turnover.
- **Portability:** the whole environment is one script away on any machine — no manual rebuild, no lock-in.

See `docs/Claude-Code-Stack-Overview.pdf` for the full architecture + economics one-pager.

---

## Quickstart
**Prereqs:** Claude Code, Node ≥20, Git, Python ≥3.10 (Windows / PowerShell).
```powershell
git clone <this-repo>
cd <this-repo>
pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1
```
The script is idempotent (safe to re-run). It installs all marketplaces/plugins (with the right enabled/disabled state), the Python + graph tooling, the custom skills, a freshly-generated `settings.json`, the vault search connector, and a silent auth-keepalive task.

**Manual post-steps** the script prints:
1. `notebooklm login` (browser sign-in — for the memory/notebook features)
2. `gh auth login` (for GitHub backups)
3. Install the **Claudian** + **Local REST API** plugins in Obsidian (Community Plugins)
4. Restart Claude Code so everything loads

## Daily usage
- `/kickoff` — at the start of a project, get a token-efficient toolset recommendation.
- `/devteam` — multi-agent coding; escalates to the heavy swarm only for big builds, then powers down.
- `/research <topic|url>` — source → external analysis → linked notes in the vault.
- `/wrapup` — persist the session to all memory layers.
- `/backup` — version the whole setup + vault to git.
- `consolidate-memory` — periodic memory tidy-up (merge dupes, fix stale facts, prune).

## What's inside
See `MANIFEST.md` for the full inventory (every plugin, skill, tool, and connector) and `CLAUDE.md` for the control panel that loads into every session. Account-specific values (notebook IDs, your Google account, machine paths) are auto-created or templated — nothing personal is shipped.
