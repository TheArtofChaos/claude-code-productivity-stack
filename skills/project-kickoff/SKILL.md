---
name: project-kickoff
description: >-
  Start-of-project routine. Triggers on "/kickoff", "project kickoff", "start project",
  "what skills should I use", or when the user begins focused work on a project. Lists all
  available skills/harnesses with descriptions, assesses the current project, recommends a
  tailored set for productivity + token/cost efficiency + output quality, and lets the user choose.
---

# Project Kickoff

Help the user pick the right tools for the project at hand — maximize productivity and output
while protecting token/cost budget. Be concise; this routine itself costs tokens, so don't pad it.

## Procedure

### Step 1 — Inventory the available toolset
Present everything available, grouped and each with a one-line description. Pull the live list:
- Plugins/skills: run `claude plugin list` and note the skills the harness has loaded.
- Group as: **(a) Always-on skills** (superpowers set, obsidian, ui-ux-pro-max, notebooklm, wrapup, project-kickoff),
  **(b) On-demand harnesses** (ruflo — `enable ruflo-core ruflo-swarm`; gsd-core — `--plugin-dir`/`--local`),
  **(c) Built-in skills** (deep-research, code-review, simplify, verify, run, security-review, etc.),
  **(d) Memory layers** (native → vault `$HOME\Vault` → NotebookLM AI Brain).
Keep each line short. Don't dump full skill bodies.

### Step 2 — Assess the project
Quickly read signal, not everything: project `CLAUDE.md`/`README`, language/stack, repo size,
git state, and the task the user stated. Infer: Is it greenfield or maintenance? Heavy parallel
work? UI work? Research-heavy? Spec/architecture-heavy? Large doc corpus?

### Step 3 — Recommend (with reasons + cost framing)
Propose a tailored set, each with a one-line "why" and its cost posture:
- Default-on for almost every project: the **memory loop** (cheap recall, `/wrapup` to save) — it
  saves tokens long-term by avoiding context re-explanation.
- Map project traits → tools, e.g.:
  - UI/frontend → `ui-ux-pro-max`.
  - Multi-file/parallelizable build → superpowers `dispatching-parallel-agents`; escalate to **ruflo swarm only if truly large** (3–10× tokens — call this out).
  - Spec/architecture-driven → **gsd-core** on-demand.
  - Research/unknowns → `deep-research`; offload bulky sources to **NotebookLM/Obsidian** instead of pasting.
  - Large/unfamiliar **code** repo → **Graphify** code graph: if the `graphify` CLI is present and the project is real code (not the vault/docs), run `graphify .` once to build the graph, then navigate with `graphify query|path|explain` instead of grepping (offline, no API, 7–70× fewer tokens). Per-project; rebuild via `graphify hook install` (git hooks). **Never** run it on `$HOME\Vault`. Pairs with `/devteam` for heavy coding.
  - Before shipping → `code-review` / `verify` / `security-review`.
- Explicitly flag anything that would **hurt** token/cost efficiency if left on (e.g. enabling a ruflo swarm for a small task).

### Step 4 — Let the user choose, then activate
Ask the user which to use (offer your recommended set as the default). For their picks:
- Always-on skills need no action (already available) — just confirm you'll lean on them.
- On-demand: give/run the exact enable command (ruflo `claude plugin enable …`; gsd `--plugin-dir …`).
- Note which to **disable again** when the heavy task is done.

### Step 5 — Confirm
Summarize the chosen working set in 2–3 lines and proceed with the actual task.

## Obsidian vault workflow (mention when relevant)
The vault `$HOME\Vault` uses a 3-layer flow: **Inbox/** (raw drops) → **Wiki/** (permanent, backlinked
knowledge: Knowledge + Projects) → **Outputs/** (generated deliverables for review). Loop:
brain-dump → context-aware prompting → refinement (cross-reference Wiki) → save & link. Offer to
process Inbox items, cross-reference Wiki, or stage deliverables in Outputs when the project fits.

## Code-graph navigation (code projects only)
For a sizable **code** repo, offer to build a Graphify graph: `graphify update .` (offline, code-only, no API key — NOT bare `graphify .`, which needs an LLM key for docs). Then navigate with `graphify query "..."` / `explain "X"` / `path "A" "B"` instead of grepping (huge token savings on big repos). Skip for the Obsidian vault, docs, and small projects.

## Note
The memory layers (native + Obsidian + NotebookLM) are token-saving in the long run for any
recurring/large-context project — recall replaces re-explanation, and offloading bulky reference
keeps the context window lean. They only fail to pay off on trivial one-off chats.
