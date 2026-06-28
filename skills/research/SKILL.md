---
name: research
description: >-
  End-to-end research pipeline. Triggers on "/research", "research this", "build a research brief",
  or "deep dive on X". Collects source(s) — URL / YouTube / files / topic — offloads the heavy
  analysis + any deliverable to NotebookLM (Google's compute = tokens you don't pay for), and files
  the results into the Obsidian vault as linked notes. The composite "super-skill" pattern.
---

# Research pipeline (source → NotebookLM → Obsidian)

Chains tools we already have into one flow. Offload heavy analysis to NotebookLM; land browsable, linked outputs in the vault. Keep Claude's role to orchestration + filing (cheap).

## Input
A topic, one or more URLs (articles / YouTube), or local files. Ask which if unclear.

## Steps
1. **Collect sources → `$HOME\Vault\Inbox\` (immutable raw layer).**
   - YouTube → transcript via `youtube-transcript-api` (or the `/watch` engine).
   - Article/URL → `defuddle` (or WebFetch) → clean markdown.
   - Files → copy/reference as-is.
2. **Offload analysis to NotebookLM (token-saving).**
   - Resolve a notebook for the topic: `notebooklm list --json` → reuse, else `notebooklm create "<topic>" --json`. **Honor the global auth rule** (on any auth error: refresh → login → retry once; never skip).
   - Add sources: `notebooklm source add <file|url> --notebook <id>` (≤50 per notebook).
   - Get the synthesis + any deliverable the user wants: `notebooklm ask "<question>"` for a brief; or `notebooklm generate audio|infographic|mind-map|slide-deck|flashcards` for artifacts (these run on Google's compute — minutes, not your tokens).
3. **File results into the vault.**
   - Durable knowledge → a `Wiki/` note; generated deliverable/brief for review → `Outputs/`. Use `[[wikilinks]]`, update `Wiki/index.md`, append `## [YYYY-MM-DD] research | <topic>` to `Wiki/log.md`.
   - Record where any NotebookLM artifacts (audio/infographic) live.
4. **Confirm** sources collected, what NotebookLM produced, vault note path(s), and notebook id.

## Notes
- Pattern is swappable: replace the source step for any domain (PDFs, articles, transcripts). You can drop the NotebookLM step for small jobs (just file straight to the vault).
- Cost posture: NotebookLM does the heavy lifting off your token budget; Claude orchestrates + files. Pairs with `/wrapup` (session memory) and the tiered recall.
