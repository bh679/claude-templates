# Hooks

> Reusable hooks that enforce standards across all Claude-powered projects.
> Organised by standard. Two types co-exist in the same folder structure.

---

## Hook Types

| Type | Trigger | Installed to | How |
|---|---|---|---|
| **Git hook** | Git event (pre-commit, etc.) | `.git/hooks/` | Copied |
| **Claude Code hook** | Claude tool use (Bash, Write, Edit) | `.claude/hooks/` | Symlinked |

Git hooks are **copied** because `.git/` is not committed.
Claude Code hooks are **symlinked** so updates to this repo propagate automatically.

---

## Folder Structure

```
standards/hooks/
  git/                          ← enforces git.md
    pre-bash.sh                 ← Claude Code: PreToolUse Bash
    post-bash.sh                ← Claude Code: PostToolUse Bash
    install-hooks.sh            ← installs git standard hooks only
  versioning/                   ← enforces versioning.md
    git-hook-pre-commit.sh      ← Git: pre-commit
    install-hooks.sh            ← installs versioning hooks only
  workflow/                     ← enforces workflow.md (future)
  wiki/                         ← enforces wiki-writing.md (future)
  install-hooks.sh              ← composite: calls all per-standard installers
  check-hooks.sh               ← compares installed vs source versions
  README.md
```

### Naming Conventions

- `pre-bash.sh` / `post-bash.sh` — Claude Code hooks (PreToolUse / PostToolUse on Bash)
- `pre-write.sh` / `post-write.sh` — Claude Code hooks (PreToolUse / PostToolUse on Write/Edit)
- `git-hook-<event>.sh` — Git hooks; the `<event>` suffix maps to the git hook name (e.g. `pre-commit`)

---

## Installation

Each standard has its own installer. Run only the ones your template uses.

### Per-standard (recommended)

```bash
# From your consumer project root:
~/Projects/Claude\ Templates/standards/hooks/git/install-hooks.sh
~/Projects/Claude\ Templates/standards/hooks/versioning/install-hooks.sh
```

### All standards at once

```bash
~/Projects/Claude\ Templates/standards/hooks/install-hooks.sh
```

| Standard | Installer | Installs |
|---|---|---|
| git | `git/install-hooks.sh` | `.claude/hooks/git/` (symlink) |
| versioning | `versioning/install-hooks.sh` | `.git/hooks/pre-commit` (copy) |

---

## settings.json — Claude Code Hook Config

After running `install-hooks.sh`, add this to your project's `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/git/pre-bash.sh" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/git/post-bash.sh" }
        ]
      }
    ]
  }
}
```

Add additional hook entries as more standards gain Claude Code hooks.

---

## Available Hooks

### git/ — git.md

#### `pre-bash.sh` (Claude Code — PreToolUse Bash)

Hard blocks:
- Commit directly to `main` / `master`
- `gh pr merge` without `--squash`

Soft warns:
- New branch missing `dev/` prefix

#### `post-bash.sh` (Claude Code — PostToolUse Bash)

Soft reminds:
- Push after every commit
- Clean up branch + worktree after merge
- Invoke `trigger-blog` after user-facing merges

---

### versioning/ — versioning.md

#### `git-hook-pre-commit.sh` (Git — pre-commit)

Hard blocks:
- `package.json` version not bumped since last commit
- Version format not matching SemVer (`MAJOR.MINOR.PATCH`)

---

## Hook Versioning

Every hook script declares a `HOOK_VERSION` variable on line 3:

```bash
#!/usr/bin/env bash
# git/pre-bash.sh
HOOK_VERSION="1.0.0"
```

### How it works

1. **Install scripts** write each hook's version to `.claude/hook-versions.json` in the consumer project
2. **`check-hooks.sh`** compares installed versions against source versions
3. Symlinked hooks auto-update but the version file tracks what was last installed
4. Copied hooks (git hooks) go stale — `check-hooks.sh` catches this

### Checking for updates

```bash
# From your consumer project root:
~/Projects/Claude\ Templates/standards/hooks/check-hooks.sh
```

Output:
```
  ✓  git/pre-bash.sh           — 1.0.0 (symlinked)
  ✓  git/post-bash.sh          — 1.0.0 (symlinked)
  ✗  versioning/git-hook-pre-commit.sh  — outdated
     Installed: 1.0.0  →  Source: 1.1.0  (copied)
```

### When to bump versions

Bump `HOOK_VERSION` in the hook script whenever you change the hook's behaviour.
Use semver: patch for tweaks, minor for new rules, major for breaking changes.

---

## Adding a New Hook

1. Create or identify the standard folder: `standards/hooks/<standard>/`
2. Add your script following the naming convention above
3. Add `HOOK_VERSION="1.0.0"` on line 3 of your script
4. Make it executable: `chmod +x <script>.sh`
5. For Claude Code hooks: add the entry to `settings.json` (see snippet above)
6. For Git hooks: re-run `install-hooks.sh` in consumer projects
7. Update this README

---

## Skipping Hooks

**Git hooks** — bypass for a specific commit (use sparingly):
```bash
git commit --no-verify -m "docs: update README"
```

**Claude Code hooks** — cannot be bypassed per-command. Remove from `settings.json` temporarily if needed, then restore.
