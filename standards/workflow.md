# Workflow Standard — Three-Gate Approval

> **Source of truth** for all Claude product engineer sessions.
> Consumer projects reference this doc with a pointer comment in their CLAUDE.md.

---

## Overview

Every feature follows a linear sequence:

```
Discover Session → Search Board → Gate 1 (Plan) → Implement → Gate 2 (Test) → Gate 3 (Merge) → Ship → Document
```

One feature per session. Never work on multiple features in the same session.

---

## Gate 1 — Plan Approval

**Trigger:** Before writing any code.

**Agent actions:**
1. Enter plan mode (`EnterPlanMode`)
2. Explore the codebase — read relevant files, understand existing patterns
3. Write a plan to the plan file covering:
   - What will be built
   - Which files will be changed and why
   - Estimated complexity
   - Risks or dependencies
4. Present the plan to the user via `ExitPlanMode`

**Gate requirement:** User clicks Approve in plan mode.

**Never skip:** Even for "simple" changes. Plan mode catches assumptions early.

---

## Gate 2 — Testing Approval

**Trigger:** After isolated implementation is complete.

**Agent actions:**
1. Run automated tests (curl for APIs, Playwright MCP for UI)
2. Take screenshots of the feature using `browser_take_screenshot`
3. Use `browser_snapshot` for accessibility tree analysis
4. Enter plan mode and present a **Gate 2 Testing Report** containing:
   - Screenshot paths (for blogging)
   - Clickable local URL with port
   - Step-by-step user testing instructions
   - Automated test results summary
   - What passed / what failed

**Gate requirement:** User tests manually and clicks Approve.

**Screenshot naming:** `gate2-<feature-slug>-<timestamp>.png` in `./test-results/`

---

## Gate 3 — Merge Approval

**Trigger:** After user testing passes Gate 2.

**Agent actions:**
1. Create a PR with a clear title and description
2. Enter plan mode and present:
   - File diff summary (which files changed, what changed)
   - PR link
   - Any breaking changes or migration steps
3. Wait for approval

**Gate requirement:** User clicks Approve, then agent merges the PR.

**Never merge without Gate 3 approval.** Not even for hotfixes.

---

## Session Identification

Each Claude Code session has an immutable UUID (the CLI session ID) and an editable title.

**Title format:** `<STATUS> - <Task Name> - <Project Name>`

| Status code | Meaning |
|---|---|
| `IDEA` | Exploring / not yet started |
| `PLAN` | Gate 1 in progress |
| `DEV` | Implementing |
| `TEST` | Gate 2 in progress |
| `DONE` | Merged and shipped |

**Agent responsibilities:**
1. Discover session ID at session start (check `~/.claude/projects/<hash>/` or use `claude session`)
2. Update title on every status transition
3. Sync title to GitHub Project V2 board item

**Discovering the session ID:**
```bash
# List recent sessions — find the one matching current window title
ls -lt ~/.claude/projects/ | head -20
```

---

## Re-reading CLAUDE.md

Re-read the project CLAUDE.md at every gate transition. This ensures you always act on the current state of instructions, not a cached version from session start.

---

## One Feature Per Session Rule

- Never start a second feature without closing the first
- If the user asks for a new feature mid-session, document it as a new board item (IDEA status) and finish the current feature first
- Session title must reflect the active feature at all times

---

## After Gate 3: Documentation

After merging, update the relevant wiki:
- **Frontend/client features** → project wiki (e.g. Chess Wiki)
- **Backend/API features** → API repo wiki
- Follow the wiki CLAUDE.md template for structure and formatting

Then trigger the blog skill if applicable:
```
trigger-blog
```
