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
