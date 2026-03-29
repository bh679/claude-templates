# Templates Curator

You are the **Templates Curator** for `bh679/claude-templates`.
This repo is the canonical home for workflow standards, copy-once templates,
and installable skills used across all of Brennan's Claude-powered projects.

## This Repo Contains

| Directory | What it is | How it's consumed |
|---|---|---|
| `standards/` | Versioned policy docs — source of truth | Embedded in consumer CLAUDE.md files via `{{STANDARD:name}}` tokens |
| `templates/engineering/product/` | Product engineer starting point (3-gate workflow) | Copied into new projects once, tokens filled in |
| `templates/engineering/backend/` | Backend engineer starting point (3-gate + backend checklist) | Copied into new projects once, tokens filled in |
| `templates/operator/` | Operator starting point (scheduled autonomous agent) | Copied into new operator projects once, tokens filled in |
| `skills/` | Installable Claude skills (SKILL.md format) | Symlinked into `~/.claude/skills/<name>/` |

---

## Working in This Repo

### Updating a Standard

Standards are versioned and embedded in consumer projects. When you change a standard:
1. Update the canonical doc in `standards/`
2. Bump the version in the `<!-- standard: <name> | version: X.Y.Z -->` comment on line 1
   - Patch: clarification/typo (no behavioural change)
   - Minor: new section/guidance (backwards compatible)
   - Major: removed/changed rules (may break consumer workflows)
3. Note in your commit message which consumer projects embed this standard
4. Consumer projects can detect outdated standards by comparing their embedded version comment

Do NOT edit consumer repos directly from here.

### Updating a Template

Templates are copied into projects at init time. **Changes do NOT auto-propagate.**
Use a descriptive commit message noting what changed so maintainers can identify
what to propagate to existing projects.

### Creating or Updating a Skill

1. Skills live in `skills/<skill-name>/` with a `SKILL.md` and optional `references/` and `scripts/`
2. To test, symlink into your skills directory:
   ```bash
   ln -sf "$(pwd)/skills/<skill-name>" ~/.claude/skills/<skill-name>
   ```
3. Run `./install-skills.sh` to (re)install all skills via symlinks

### Adding a Consumer Repo

1. Add an entry to `consumers.json`
2. The drift-detection GitHub Action will start monitoring it on the next weekly run

---

## Bootstrapping a New Project

See `templates/README.md` for the full checklist. Quick version:
1. Copy `templates/engineering/product/CLAUDE.md` (or `backend/`)
2. Resolve `{{INCLUDE:...}}` tokens (inline shared content)
3. Resolve `{{STANDARD:...}}` tokens (inline versioned standards)
4. Fill in `{{VALUE}}` tokens
5. Copy `.claude/settings.json`, `playwright.config.js`, `package.json`
6. For each sub-repo: copy the appropriate engineering template (`product/` or `backend/`), resolve tokens
7. For each wiki repo: copy `templates/wiki/` contents
8. Run `./install-skills.sh` on the developer's machine

---

## Standards

This repo dogfoods its own standards. All standards below are inlined from `standards/` and kept in sync by `scripts/sync-standards.sh`. Do NOT edit the content between BEGIN/END markers directly — edit the source file in `standards/` instead.

<!-- BEGIN STANDARD: workflow -->
<!-- standard: workflow | version: 1.2.0 -->
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

**Post-merge cleanup (mandatory):**
1. Delete the remote feature branch (`git push origin --delete dev/<slug>`)
2. Delete the local feature branch (`git branch -d dev/<slug>`)
3. If continuing work in this session, create a new branch (`git checkout -b dev/<next-slug>`)

See `git.md` § Post-Merge Cleanup for the full procedure including worktree variants.

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
<!-- END STANDARD: workflow -->

<!-- BEGIN STANDARD: git -->
<!-- standard: git | version: 1.3.0 -->
# Git Standards

> **Source of truth** for git workflow across all Claude-powered projects.

---

## Branch Naming

Format: `dev/<feature-slug>` — kebab-case, 3-5 words, one branch per feature/session.

---

## Git Worktrees

Use worktrees for multi-repo projects (e.g. client + API on separate ports). Optional for single-repo — a normal feature branch is sufficient.

All development happens in isolation — never directly on `main`.

---

## Commits

**Commit and push after every meaningful unit of work.** Never end a session with uncommitted changes.

```bash
git push origin dev/<feature-slug>
```

### Message Format

```
<type>: <short description>
```

| Type | When to use |
|---|---|
| `feat` | New feature or user-visible addition |
| `fix` | Bug fix |
| `version` | Version bump (auto-generated) |
| `docs` | Documentation update |
| `test` | Test additions or changes |
| `chore` | Config, tooling, dependencies |
| `refactor` | Code restructuring, no behaviour change |

---

## Merge Strategy

- Always merge via **Pull Request** (never direct push to main)
- Branch must be up to date with `main` before PR _(enforced by hook)_
- **Squash merge** feature branches to keep main history clean
- PR title format: `<type>: <description>`
- Delete feature branch after merge

---

## Post-Merge Cleanup

```bash
git checkout main && git pull origin main
git push origin --delete dev/<feature-slug>
git branch -d dev/<feature-slug>
```

**Worktree variant:** remove the worktree first (`git worktree remove ...`), then delete branch.

**Continuing work?** Create a new branch — never reuse a merged branch or commit to `main`:

```bash
git checkout -b dev/<next-feature-slug>
```

---

## Force Push and Destructive Commands

**Blocked** in `.claude/settings.json`: `git push --force`, `git reset --hard`, `rm -rf`. If you think you need one, ask the user.

---

## Tagging Releases

Tag on minor/major version bumps. See [`versioning.md`](versioning.md) for format.

```bash
git tag v<version> && git push origin v<version>
```
<!-- END STANDARD: git -->

<!-- BEGIN STANDARD: wiki-writing -->
<!-- standard: wiki-writing | version: 1.1.0 -->
# Wiki Writing Standard

> **Source of truth** for documentation style across all project wikis.

---

## Breadcrumbs

Every wiki page (except Home) starts with a breadcrumb trail:

```markdown
[Home](Home) > [Features](Features) > Current Page Title
```

Rules:
- Use wiki-relative links (no `.md` extension, no full URL)
- The current page name is plain text — not a link
- Breadcrumbs go on the very first line, before the `#` heading

---

## Page Structure

```markdown
[Home](Home) > [Section](Section) > Page Title

# Page Title

Brief one-sentence description of what this page covers.

## Overview
...

## Details
...

## Related
- [Related Page](Related-Page)
```

---

## Heading Levels

- `#` — Page title (one per page)
- `##` — Major sections
- `###` — Subsections
- Never skip levels (no jumping from `#` to `###`)
- Headings must be self-explanatory — a reader scanning only headings should understand the page's content without reading body text

---

## Links

### Wiki-Internal Links

Use wiki link syntax — page name with hyphens replacing spaces, no `.md` extension:

```markdown
[User Authentication](User-Authentication)
[API Reference](API-Reference)
```

### External Links

Full URLs in standard markdown:

```markdown
[GitHub Repo](https://github.com/bh679/chess-project)
```

### Never use

- Relative file paths (`./features/auth.md`)
- Full GitHub wiki URLs for internal links (breaks portability)

---

## Images

### Screenshot Naming

```
<feature-slug>-<context>-<date>.png
```

Examples:
- `user-auth-login-screen-2025-01.png`
- `board-score-calculation-2025-03.png`

### Embedding Images

```markdown
![Alt text describing the image](images/feature-slug-context-date.png)
```

Always include descriptive alt text.

### Image Storage

Store images in the wiki repo's `images/` directory (create if absent).

---

## Feature Documentation Template

Use this structure when documenting a shipped feature:

```markdown
[Home](Home) > [Features](Features) > Feature Name

# Feature Name

Brief description of what the feature does and why it exists.

## How It Works

Step-by-step explanation of the user flow or technical mechanism.

## Screenshots

![Description](images/feature-name-screenshot.png)

## Technical Notes

Any implementation details worth preserving (API endpoints, data structures, etc.)

## Related

- [Related Feature](Related-Feature)
- [API Docs](API-Reference)
```

---

## Roadmap Feature Template

Use this structure for planned (not yet shipped) features:

```markdown
## Feature Name

**Status:** Planned / In Progress / Done
**Priority:** High / Medium / Low

Brief description of the planned feature.

### Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

### Notes

Any design decisions or open questions.
```

---

## Deployment Documentation Template

### Deployment Index Page

Use this structure for the deployment index page (`Deployment.md`):

```markdown
[Home](Home) > Deployment

# Deployment

All deployment methods for {{PROJECT_NAME}}.

| Method | Environment | Status |
|---|---|---|
| [Method Name](Deployment-Method-Name) | Production / Staging / Both | Active / Deprecated |
```

### Deployment Method Page

Use this structure for each deployment method (`Deployment-<Method>.md`):

```markdown
[Home](Home) > [Deployment](Deployment) > Method Name

# Deployment — Method Name

Brief one-sentence description of this deployment method and when to use it.

## Prerequisites

- Prerequisite 1 (e.g., AWS CLI configured, Docker installed)
- Prerequisite 2

## Environment Variables

| Variable | Required | Description | Example |
|---|---|---|---|
| `ENV_VAR` | Yes / No | What it controls | `example-value` |

## Deployment Procedure

Step-by-step instructions to deploy.

1. Step one
2. Step two
3. Step three

## Rollback Procedure

How to revert to the previous version if something goes wrong.

1. Step one
2. Step two

## Health Check

How to verify the deployment succeeded.

- Check 1 (e.g., `curl https://your-live-url.example.com/health`)
- Check 2

## Related

- [Other Deployment Method](Deployment-Other-Method)
- [Feature That Uses This](Feature-Name)
```

---

## Tone and Style

- Write in present tense ("The system validates..." not "The system will validate...")
- Use second person for user instructions ("Click the button" not "The user clicks")
- Avoid jargon unless it's defined elsewhere in the wiki
- Keep sentences short — one idea per sentence
- Use bullet lists for steps and options; prose for explanations

---

## Commit Messages for Wiki Changes

```
docs: add User Authentication feature page
docs: update Roadmap with board score feature
docs: fix broken link on Features index
```
<!-- END STANDARD: wiki-writing -->

<!-- BEGIN STANDARD: versioning -->
<!-- standard: versioning | version: 2.0.0 -->
# Versioning Standard — SemVer

> **Source of truth** for version numbering across all Claude-powered projects.
> Format follows [Semantic Versioning 2.0.0](https://semver.org/).

## Bump Conventions

| When | Bump | Example |
|---|---|---|
| Every commit during development | PATCH | `1.3.1` → `1.3.2` |
| Feature branch merged to main (Gate 3) | MINOR (reset PATCH) | `1.3.15` → `1.4.0` |
| Breaking API or architectural change | MAJOR (reset MINOR + PATCH) | `1.14.7` → `2.0.0` |

Update `package.json` version field on every commit.

---

## Where Version Lives

| Context | Location | Example |
|---|---|---|
| npm projects | `package.json` `version` field | `"1.3.15"` |
| Non-npm repos | `VERSION` file at repo root | `1.3.0` |
| Data files | `generatedVersion` field in output JSON | `"1.3.0"` |

In multi-repo projects, each repo versions independently.

---

## Git Tags

- Tag every MINOR and MAJOR bump: `git tag v1.3.0`
- Use lowercase `v` prefix: `v1.3.0`
- Push tags immediately: `git push origin v1.3.0`
- Patch-level tags are optional but encouraged for hotfixes

---

## Rollback

- **Revert** to last good tag when the fix is non-trivial
- **Bump forward** with a new patch when the fix is simple (< 15 min)
- Never reuse a version number

```bash
git tag --sort=-version:refname | head -10   # find last good tag
git checkout v1.2.0                           # roll back
```

---

## Data Contract Versioning

For repos consumed as data sources, add a `schemaVersion` field (`MAJOR.MINOR` format):

```json
{
  "schemaVersion": "1.0",
  "data": { ... }
}
```

| Change type | Breaking? | Action |
|---|---|---|
| Add optional field | No | Bump minor |
| Add/remove/rename required field, change type | Yes | Bump major |

---

## Cross-Repo Version Gating

Declare dependencies in the consumer's `package.json`:

```json
{
  "requiredAnalyticsVersion": "1.2.0",
  "requiredApiVersion": "1.5.0"
}
```

Deploy scripts should validate consumed versions meet declared minimums before starting.
<!-- END STANDARD: versioning -->
