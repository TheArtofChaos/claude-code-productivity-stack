---
name: devteam
description: >-
  Spin up a multi-agent "dev team" for a coding task. Triggers on "/devteam", "spin up a dev team",
  "use the agent swarm", "build this with agents", or "heavy coding". Routes light/medium parallel
  work to Superpowers subagents (cheap, always-on) and escalates to the ruflo swarm ONLY for
  genuinely heavy, parallelizable builds — enabling ruflo on demand and disabling it after.
---

# Dev Team (multi-agent coding)

A 4-role team — **Architect → Coder(s) → Reviewer → Tester**. Reuse existing orchestration; don't reinvent it.

## Decision gate (cheapest tier that fits — ponytail)
1. **Small/medium change** → just do it, or one subagent. No team. (Most tasks stop here.)
2. **Several independent files/workstreams, light coordination** → **Superpowers** `dispatching-parallel-agents` / `subagent-driven-development`. Always-on, cheap. **Default for parallel work.**
3. **Heavy** — large multi-module build, big migration/refactor, many parallel workstreams needing a coordinator + shared memory → **ruflo swarm** (3–10× tokens). Enable on demand, disable after.

State which tier you chose and why. Only climb to ruflo when the job is genuinely heavy — that's the whole point of keeping it off by default.

## Roles
- **Architect** — plan/spec, decompose into independent tasks, define interfaces. (`brainstorming` + `writing-plans`, or ruflo `architect`.)
- **Coder(s)** — implement workstreams in parallel, one agent per stream, isolated in git worktrees. (ruflo `coder` / Superpowers parallel agents.)
- **Reviewer** — correctness + over-engineering pass on each diff. (`requesting-code-review` + `/ponytail-review`, or ruflo `reviewer`.)
- **Tester** — write/run tests, verify behavior. (`test-driven-development` + `verification-before-completion`.)

## ruflo lifecycle (heavy tier only)
1. **Enable:** `claude plugin enable ruflo-core ruflo-swarm` (registers the swarm MCP + agents; takes effect next session).
2. **Run:** use ruflo's `swarm` / `swarm-init` skills — topology `hierarchical` for a PM-led team, `mesh` for peers. The coordinator fans tasks to architect/coder/reviewer agents with worktree isolation.
3. **Disable when done:** `claude plugin disable ruflo-core ruflo-swarm` — drops the always-on hooks + 300+ tool MCP. Don't leave it on.

## Rules
- Plan before fan-out; integrate + review before claiming done (`verification-before-completion`).
- Parallel coders use git worktrees (`using-git-worktrees` / ruflo worktree isolation) so they don't clobber each other.
- Report the tier used and the token posture; if you escalated to ruflo, confirm you disabled it after.
