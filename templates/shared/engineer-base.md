<!-- Shared engineer base — github.com/bh679/claude-templates/templates/shared/engineer-base.md -->
<!-- Included at copy time via {{INCLUDE:shared/engineer-base.md}} -->

## MANDATORY: Read Standards Before Anything Else

You MUST fetch and read each of these documents in full before taking any action.
Do not proceed until all three have been read.

- WebFetch `https://raw.githubusercontent.com/bh679/claude-templates/main/standards/workflow.md`
- WebFetch `https://raw.githubusercontent.com/bh679/claude-templates/main/standards/git.md`
- WebFetch `https://raw.githubusercontent.com/bh679/claude-templates/main/standards/versioning.md`

---

## Core Workflow

```
Discover Session → Search Board → Gate 1 (Plan) → Implement → Gate 2 (Test) → Gate 3 (Merge) → Ship → Document
```

One feature per session. Never work on multiple features simultaneously.
**Re-read this CLAUDE.md at every gate transition.**

> **MANDATORY:** All three gates apply to EVERY change — bug fixes, hotfixes, one-liners,
> and fully-specified tasks. There are no exceptions, even when the user provides exact
> file paths and replacement text. Detailed instructions reduce planning effort but do NOT
> skip the gates.

### Before ANY Implementation

1. Search project board for existing items
2. Enter plan mode (Gate 1)

---

## Session Identification

Each session has an immutable UUID and an editable title.

**Title format:** `<STATUS> - <Task Name> - {{PROJECT_NAME}}`

| Code | Meaning |
|---|---|
| `IDEA` | Exploring / not started |
| `PLAN` | Gate 1 in progress |
| `DEV` | Implementing |
| `TEST` | Gate 2 in progress |
| `DONE` | Merged and shipped |

**At session start:**
1. Discover the session ID: `ls -lt ~/.claude/projects/ | head -20`
2. Set initial title to `PLAN - <task name> - {{PROJECT_NAME}}`
3. Update title on every status transition

---

## Project Board Management

- Search for existing board items before creating new ones (avoid duplicates)
- Create/update items via `gh` CLI using the GraphQL API
- Required fields: Status, Priority, Categories, Time Estimate, Complexity

```bash
# Find existing item
gh project item-list {{PROJECT_NUMBER}} --owner {{GITHUB_USER}} --format json | jq '.items[] | select(.title | test("search term"; "i"))'

# Update item status
gh project item-edit --project-id <id> --id <item-id> --field-id <status-field-id> --single-select-option-id <option-id>
```

---

## Git & Development Environment

**Key rules:**
- All feature work in **git worktrees** — never directly on `main`
- **Commit after every meaningful unit of work**
- **Push immediately after every commit**
- Branch naming: `dev/<feature-slug>`

### Worktree Setup (after Gate 1 approval)

```bash
# In the sub-repo that needs changes
git worktree add ../worktrees/{{PROJECT_SLUG}}-<feature-slug> -b dev/<feature-slug>
cd ../worktrees/{{PROJECT_SLUG}}-<feature-slug>
npm install
```

### Worktree Teardown (after Gate 3 merge)

```bash
git worktree remove ../worktrees/{{PROJECT_SLUG}}-<feature-slug>
git branch -d dev/<feature-slug>
```

### Port Management

Each session claims a unique port to avoid conflicts:

```bash
# Claim a port
echo '{"port": {{BASE_PORT}}, "session": "<session-id>", "feature": "<feature-slug>"}' > ./ports/<session-id>.json

# Release port after session ends
rm ./ports/<session-id>.json
```

Base port: `{{BASE_PORT}}`. If occupied, increment by 1 until a free port is found.

---

## Versioning

Format: `V.MM.PPPP`
- Bump **PPPP** on every commit
- Bump **MM** on every merged feature (reset PPPP to 0000)
- Bump **V** only for breaking changes

Update `package.json` version field on every commit.

---

## Gate 3 — Merge Approval

After user testing passes:
1. Create a PR with a clear title and description
2. Enter plan mode and present: file diff summary, PR link, breaking changes (if any)
3. Wait for user approval, then merge

**Never merge without Gate 3 approval — not even for hotfixes.**

---

## Documentation

> **READ NOW before writing or editing any wiki page:**
> WebFetch `https://raw.githubusercontent.com/bh679/claude-templates/main/standards/wiki-writing.md`
>
> Do not write a single wiki line until you have read it in full.

---

## After Gate 3: Blog Context

After a successful Gate 3 merge, invoke the `trigger-blog` skill to automatically
capture and queue the feature context for the weekly blog agent.

---

## Key Rules Summary

- Always use plan mode for all three gates
- Never merge without Gate 3 approval
- **Gates apply to ALL changes — bug fixes, hotfixes, one-liners, and fully-specified tasks**
- Re-read CLAUDE.md at every gate
- Check for existing board items before creating
- Clean up worktrees and ports when done
- One feature per session
- Commit and push after every meaningful unit of work
