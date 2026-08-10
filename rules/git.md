<!-- standard: git | version: 1.5.0 -->
# Git Standards

## Branch Naming
Format: `dev/<feature-slug>` — kebab-case, 3-5 words, one branch per feature/session.

## Git Worktrees
**All development happens in a git worktree — single-repo or multi-repo, feature or one-line hotfix.**
The working checkout of `main` is never used for feature work. Create the worktree before writing any code:

```bash
git worktree add .claude/worktrees/<feature-slug> -b dev/<feature-slug>
```

All development happens in isolation — never directly on `main`. This is enforced by
`hooks/git/pre-bash.sh`, which blocks `git commit` outside a worktree.

**Exemptions:** a repo that legitimately never uses worktrees can opt out with a
`.claude/no-worktree` marker file at its root. For a single command, set
`CLAUDE_ALLOW_NON_WORKTREE=1`.

## Commits
**Commit and push after every meaningful unit of work.** Never end a session with uncommitted changes.
```bash
git push origin dev/<feature-slug>
```

### Message Format
```
<type>: <short description>

<optional body>
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
| `perf`     | Performance improvement |
| `ci`       | CI/CD configuration changes |


## Merge Strategy
- Always merge via **Pull Request** (never direct push to main)
- Branch must be up to date with `main` before PR _(enforced by hook)_
- **Squash merge** feature branches to keep main history clean
- PR title format: `<type>: <description>`
- Delete feature branch after merge


## PR Procedure
When creating a PR:
1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch


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


## Force Push and Destructive Commands
**Blocked** in `.claude/settings.json`: `git push --force`, `git reset --hard`, `rm -rf`. If you think you need one, ask the user.


## Tagging Releases
Tag on minor/major version bumps. See [`versioning.md`](versioning.md) for format.
```bash
git tag v<version> && git push origin v<version>
```
