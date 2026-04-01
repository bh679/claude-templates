[Home](Home) > [Features](Features) > Enforceable Hooks

# Enforceable Hooks

Git hooks and Claude Code hooks that enforce standards automatically during development.

## How It Works

Two types of hooks co-exist:

### Git Hooks (copied)

Triggered by git events. Copied into `.git/hooks/` because the `.git/` directory is not committed.

| Hook | Standard | Enforces |
|---|---|---|
| `pre-commit` | versioning.md | Blocks commits if package.json version not bumped |

### Claude Code Hooks (symlinked)

Triggered by Claude tool use. Symlinked into `.claude/hooks/` so updates propagate automatically.

| Hook | Standard | Enforces |
|---|---|---|
| `pre-bash.sh` | git.md | Blocks commits to main, blocks non-squash merges |
| `post-bash.sh` | git.md | Reminds to push after commit, clean up after merge |

### Installation

Per-standard (recommended):

```bash
~/Projects/Claude\ Templates/hooks/git/install-hooks.sh
~/Projects/Claude\ Templates/hooks/versioning/install-hooks.sh
```

Or all at once:

```bash
~/Projects/Claude\ Templates/hooks/install-hooks.sh
```

## Technical Notes

- Hook scripts declare `HOOK_VERSION` on line 3 for version tracking
- Install scripts write versions to `.claude/hook-versions.json`
- `check-hooks.sh` compares installed vs source versions
- Claude Code hooks require matching entries in `.claude/settings.json`

## Related

- [Git Standards](Git-Standards)
- [Hook Versioning](Hook-Versioning)
- [Merge-Main-Before-PR Enforcement](Merge-Main-Before-PR)
