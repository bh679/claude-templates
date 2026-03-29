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
<!-- standard: workflow | version: 2.1.0 -->
# Workflow Standard — Four-Gate Approval

> **Source of truth** for all Claude product engineer sessions.

---

## Overview

Every feature follows a linear sequence:

```
Discover Session → Search Board → Gate 1 (Plan) → Implement → Gate 2 (Test) → Gate 3 (Merge) → Ship → Document → Gate 4 (Review)
```

One feature per session. Never work on multiple features in the same session. If the user asks for a new feature mid-session, document it as a board item (IDEA status) and finish the current feature first.

> **MANDATORY:** All four gates apply to EVERY change — bug fixes, hotfixes, one-liners,
> and fully-specified tasks. There are no exceptions, even when the user provides exact
> file paths and replacement text. Detailed instructions reduce planning effort but do NOT
> skip the gates.

---

## Gate 1 — Plan Approval

**Trigger:** Before writing any code.

1. Read `.claude/gates/gate-1-plan.md` for full gate instructions
2. Follow the procedure described there

**Gate requirement:** User clicks Approve in plan mode.

---

## Gate 2 — Testing Approval

**Trigger:** After isolated implementation is complete.

1. Read `.claude/gates/gate-2-test.md` for full gate instructions
2. Follow the procedure described there

**Gate requirement:** User tests manually and clicks Approve.

---

## Gate 3 — Merge Approval

**Trigger:** After user testing passes Gate 2.

1. Read `.claude/gates/gate-3-merge.md` for full gate instructions
2. Follow the procedure described there

**Gate requirement:** User clicks Approve, then agent merges the PR.

**Never merge without Gate 3 approval.** Not even for hotfixes.

---

## Gate 4 — Session Review

**Trigger:** After documentation is complete — the final gate before closing the session.

1. Read `standards/gates/session-review.md` for full gate instructions
2. Follow the procedure described there

**Gate requirement:** User clicks Approve after reviewing the report.

---

## Re-reading CLAUDE.md

Re-read the project CLAUDE.md at every gate transition. This ensures you always act on the current state of instructions, not a cached version from session start.
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

<!-- BEGIN STANDARD: versioning -->
<!-- standard: versioning | version: 2.1.0 -->
# Versioning Standard — SemVer

> Source of truth for version numbering. Follows [SemVer 2.0.0](https://semver.org/).

## Bump Conventions

| When | Bump | Example |
|---|---|---|
| Every commit during development | PATCH | `1.3.1` → `1.3.2` |
| Feature branch merged to main (Gate 3) | MINOR (reset PATCH) | `1.3.15` → `1.4.0` |
| Breaking API or architectural change | MAJOR (reset MINOR + PATCH) | `1.14.7` → `2.0.0` |

Update `package.json` version field on every commit.

## Where Version Lives

| Context | Location | Example |
|---|---|---|
| npm projects | `package.json` `version` field | `"1.3.15"` |
| Non-npm repos | `VERSION` file at repo root | `1.3.0` |

In multi-repo projects, each repo versions independently. For data files, use a `generatedVersion` field in output JSON.

## Git Tags

Tag every MINOR and MAJOR bump with lowercase `v` prefix and push immediately:
```bash
git tag v1.3.0 && git push origin v1.3.0
```
Patch-level tags are optional.

## Rollback

- **Non-trivial fix:** revert to last good tag (`git tag --sort=-version:refname | head -10`)
- **Simple fix (< 15 min):** bump forward with a new patch
- Never reuse a version number

## Data Contract Versioning

For repos consumed as data sources, add `"schemaVersion": "MAJOR.MINOR"`:

| Change type | Breaking? | Action |
|---|---|---|
| Add optional field | No | Bump minor |
| Add/remove/rename required field, change type | Yes | Bump major |

## Cross-Repo Version Gating

Declare minimum required versions in the consumer's `package.json` and validate at deploy time:

```json
{ "requiredAnalyticsVersion": "1.2.0", "requiredApiVersion": "1.5.0" }
```
<!-- END STANDARD: versioning -->
