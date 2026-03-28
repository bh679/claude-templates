<!-- standard: workflow | version: 1.1.0 -->
# Workflow Standard — Three-Gate Approval

> **Source of truth** for all Claude product engineer sessions.

---

## Overview

Every feature follows a linear sequence:

```
Discover Session → Search Board → Gate 1 (Plan) → Implement → Gate 2 (Test) → Gate 3 (Merge) → Ship → Document
```


One feature per session. Never work on multiple features in the same session.


> **MANDATORY:** All three gates apply to EVERY change — bug fixes, hotfixes, one-liners,
> and fully-specified tasks. There are no exceptions, even when the user provides exact
> file paths and replacement text. Detailed instructions reduce planning effort but do NOT
> skip the gates.


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
   - Deployment impact assessment (see Deployment Impact Checklist below)
4. Present the plan to the user via `ExitPlanMode`

**Gate requirement:** User clicks Approve in plan mode.

**Never skip:** Even for "simple" changes. Plan mode catches assumptions early.

### Deployment Impact Checklist

During Gate 1 planning, assess whether the planned changes may impact deployment. A change impacts deployment if it involves any of the following:

| Category | Example |
|---|---|
| Environment variable additions, removals, or changes | Adding `STRIPE_API_KEY` for payment integration |
| New dependencies or major version bumps | Upgrading `pg` from v7 to v8 (breaking changes) |
| Port or networking changes | Changing API from port 3000 to 8080 |
| Database schema migrations | Adding a `subscriptions` table |
| New API endpoints requiring reverse proxy or load balancer config | New `/api/webhooks/stripe` needs proxy rule |
| Docker/container configuration changes | Changing base image from `node:18` to `node:20` |
| Build step changes (new tools, changed commands, new artifacts) | Adding `prisma generate` to build pipeline |
| New external service integrations (credentials/config needed) | Integrating Redis for session storage |
| Startup or shutdown procedure changes | Switching from `node server.js` to PM2 cluster mode |
| Infrastructure requirement changes (memory, CPU, storage) | Feature requires 2GB+ RAM for image processing |

**If any items apply:**
1. Check for existing `Deployment-*.md` wiki pages in the project wiki
2. Read and review the relevant deployment docs to understand current procedures
3. Include "Update deployment documentation" as a task in the plan
4. Note which specific deployment methods are affected

**If no deployment wiki pages exist yet and the project has a known deployment method:**
Create a `Deployment.md` index page and at least one `Deployment-<Method>.md` page as part of the documentation step after Gate 3.

---

## Gate 2 — Testing Approval

**Trigger:** After isolated implementation is complete.

**Agent actions:**
1. Run unit tests per the [Unit Testing standard](unit-testing.md) — verify 80%+ line coverage
2. Run integration/e2e tests (curl for APIs, Playwright MCP for UI)
3. Take screenshots of the feature using `browser_take_screenshot`
4. Use `browser_snapshot` for accessibility tree analysis
5. Enter plan mode and present a **Gate 2 Testing Report** containing:
   - Unit test summary: total, passed, failed, skipped, coverage %
   - Screenshot paths (for blogging)
   - Clickable local URL with port
   - Step-by-step user testing instructions
   - Integration/e2e test results summary
   - What passed / what failed

**Gate requirement:** User tests manually and clicks Approve.

**Screenshot naming:** `gate2-<feature-slug>-<timestamp>.png` in `./test-results/`

---

## Gate 3 — Merge Approval

**Trigger:** After user testing passes Gate 2.

**Agent actions:**
1. Ensure branch is up to date with `main` _(enforced by hook — will block `gh pr create` if behind)_
2. Create a PR with a clear title and description
3. Enter plan mode and present:
   - File diff summary (which files changed, what changed)
   - PR link
   - Any breaking changes or migration steps
4. Wait for approval

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
- **Deployment-impacting changes** → update the relevant `Deployment-*.md` wiki pages
- Follow the wiki CLAUDE.md template for structure and formatting

If deployment docs were flagged in the Gate 1 plan:
1. Update the affected `Deployment-<Method>.md` pages with the new requirements
2. If a new deployment method was introduced, create a new `Deployment-<Method>.md` page
3. Update the `Deployment.md` index if new pages were added

Then trigger the blog skill if applicable:
```
trigger-blog
```
