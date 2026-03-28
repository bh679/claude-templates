<!-- standard: git | version: 1.2.0 -->
# Git Standards

> **Source of truth** for git workflow across all Claude-powered projects.

---

## Branch Naming

```
dev/<feature-slug>
```

Examples:
- `dev/user-authentication`
- `dev/board-score-recalculation`
- `dev/fix-login-redirect`

Rules:
- Always prefix with `dev/`
- Use kebab-case
- Keep it short but descriptive (3-5 words max)
- One branch per feature/session

---

## Git Worktrees

**Recommended for multi-repo projects. Optional for single-repo projects.**

For single-repo projects, a feature branch (`dev/<feature-slug>`) checked out normally is sufficient — no worktree needed. Use worktrees when you need multiple features or sub-repos running simultaneously (e.g. a client + API pair that must run together on separate ports).

All feature development happens in an **isolated environment** — never directly on `main`.

### Manual Setup

If your tooling doesn't create a worktree automatically:

```bash
# In the repo root
git worktree add ../worktrees/<feature-slug> -b dev/<feature-slug>
cd ../worktrees/<feature-slug>
npm install   # or whatever the repo setup requires
```

### After Feature Merge

After merge, clean up the branch and worktree. See **Post-Merge Cleanup** below for the full procedure. If continuing work, create a fresh worktree on a new branch — never commit to `main`.

### Why worktrees?

- Multiple sessions can work on different features simultaneously without conflicts
- `main` stays clean and always deployable
- Each worktree has its own working directory — no stashing needed

---

## Commit Frequency

**Commit after every meaningful unit of work.** Do not accumulate changes.

What counts as a commit:
- A function is added or modified
- A bug is fixed
- A file is created
- A test is added
- A config is changed

Never: end a session with uncommitted changes.

### Push After Every Commit

```bash
git push origin dev/<feature-slug>
```

Push immediately after every commit. This creates a remote backup and keeps the PR diff current.

---

## Commit Message Format

```
<type>: <short description>
```

| Type | When to use |
|---|---|
| `feat` | New feature or user-visible addition |
| `fix` | Bug fix |
| `version` | Version bump commit (auto-generated) |
| `docs` | Wiki or documentation update |
| `test` | Test additions or changes |
| `chore` | Config, tooling, dependency updates |
| `refactor` | Code restructuring without behaviour change |

Examples:
```
feat: add email validation to registration form
fix: correct JWT expiry on password reset
version: bump to V.01.0012
docs: update Features wiki with login flow
test: add Playwright test for checkout flow
```

---

## Merge Strategy

- Always merge via **Pull Request** (never direct push to main)
- Branch must be up to date with `main` before creating a PR _(enforced by hook)_
- Use **squash merge** for feature branches to keep main history clean
- PR title matches the commit message format: `feat: <description>`
- Delete the feature branch after merge (see Post-Merge Cleanup below)

---

## Post-Merge Cleanup

After a PR is successfully merged, **always** run the full cleanup sequence:

```bash
# 1. Switch back to main and pull the merge
git checkout main
git pull origin main

# 2. Delete the remote feature branch
git push origin --delete dev/<feature-slug>

# 3. Delete the local feature branch
git branch -d dev/<feature-slug>
```

### Continuing Work in the Same Session

If the session continues after merge, **create a new branch before any new commits**:

```bash
git checkout -b dev/<next-feature-slug>
```

Never reuse a merged branch. Never commit directly to `main`.

### Worktree Variant

If working in a git worktree, exit the worktree first, then clean up:

```bash
# From the worktree directory — exit back to the main checkout
# Then remove the worktree and its branch
git worktree remove ../worktrees/<feature-slug>
git branch -d dev/<feature-slug>
git push origin --delete dev/<feature-slug>
```

If continuing work, create a fresh worktree:

```bash
git worktree add ../worktrees/<next-feature-slug> -b dev/<next-feature-slug>
```

---

## Force Push and Destructive Commands

The following are **blocked** in `.claude/settings.json`:
- `git push --force *`
- `git reset --hard *`
- `rm -rf *`

These must never be used. If you think you need one, ask the user.

---

## Tagging Releases

After a minor version milestone (MM bump), tag the release:

```bash
git tag v<version>   # e.g. git tag v1.02.0000
git push origin v<version>
```

See [`versioning.md`](versioning.md) for version format details.
