---
name: handoff
description: >-
  Session handoff for cache-cheap continuation. Triggers on "/handoff", "hand off this session",
  or "continue in a fresh session". Summarizes the session (files built, decisions, exact pickup
  point) so you can /clear (or open a new session) and resume with full context but a fresh, cheap
  prompt cache. Distinct from /wrapup, which persists long-term memory.
---

# Session Handoff (cache-cheap continuation)

When the context has grown large/expensive (or you've idled past the ~1h cache TTL), continue in a
FRESH session without losing your place — and without dragging a bloated, re-cached context forward.
A fresh session pays one small cache-create instead of re-caching a huge context every turn.

## When
`/handoff`, "hand off", "continue fresh", or when `/context` shows the window is heavy mid-task.
(For *ending* work, use `/wrapup` instead — that persists memory.)

## Procedure
1. Produce a dense, self-contained **HANDOFF** block the user can copy into a new session:
   - **Goal / task** — what we're doing and why.
   - **Done so far** — key files created/edited (with paths), decisions (+ why), what's verified.
   - **Exact pickup point** — the very next concrete step.
   - **Open questions / constraints / preferences** — anything unresolved.
   Assume the new session has zero prior context.
2. Tell the user: copy it, run `/clear` (or open a new session), paste it, continue.
3. Do NOT write long-term memory here (that's `/wrapup`) — this is purely cheap in-flight continuation.

Pairs with the **Cache discipline** rules in the global `CLAUDE.md`.
