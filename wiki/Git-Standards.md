[Home](Home) > [Features](Features) > Git Standards

# Git Standards

Branch naming, commit format, merge strategy, and worktree conventions enforced across all projects.

## How It Works

### Branch Naming

All feature branches use `dev/<feature-slug>` with kebab-case naming. One branch per feature/session.

### Commit Format

```
<type>: <short description>
```

Types: `feat`, `fix`, `version`, `docs`, `test`, `chore`, `refactor`

### Merge Strategy

- Always merge via Pull Request (never direct push to main)
- Branch must be up to date with main before creating a PR
- Use squash merge for feature branches
- Delete the feature branch after merge

### Worktrees

Recommended for multi-repo projects. Each feature gets an isolated worktree so multiple sessions can work simultaneously without conflicts.

```bash
git worktree add ../worktrees/<feature-slug> -b dev/<feature-slug>
```

### Force Push Protection

Force push, hard reset, and `rm -rf` are blocked in `.claude/settings.json`.

## Technical Notes

- Current version: 1.1.0
- Enforced by hooks in `standards/hooks/git/`
- Pre-bash hook blocks: commits to main, PR merge without squash
- Post-bash hook reminds: push after commit, clean up after merge

## Related

- [Three-Gate Workflow](Three-Gate-Workflow)
- [Enforceable Hooks](Enforceable-Hooks)
- [Merge-Main-Before-PR Enforcement](Merge-Main-Before-PR)
