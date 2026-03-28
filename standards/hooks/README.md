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
  versioning/                   ← enforces versioning.md
    git-hook-pre-commit.sh      ← Git: pre-commit
  workflow/                     ← enforces workflow.md (future)
  wiki/                         ← enforces wiki-writing.md (future)
  install-hooks.sh
  README.md
```

### Naming Conventions

- `pre-bash.sh` / `post-bash.sh` — Claude Code hooks (PreToolUse / PostToolUse on Bash)
- `pre-write.sh` / `post-write.sh` — Claude Code hooks (PreToolUse / PostToolUse on Write/Edit)
- `git-hook-<event>.sh` — Git hooks; the `<event>` suffix maps to the git hook name (e.g. `pre-commit`)

---

## Installation

Run from your **consumer project's root directory**:

```bash
~/Projects/Claude\ Templates/standards/hooks/install-hooks.sh
```

This installs:
- All `git-hook-*.sh` scripts → `.git/hooks/` (copied, executable)
- All standard folders containing Claude hooks → `.claude/hooks/<standard>/` (symlinked)

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
- Version format not matching `V.MM.PPPP`

---

## Adding a New Hook

1. Create or identify the standard folder: `standards/hooks/<standard>/`
2. Add your script following the naming convention above
3. Make it executable: `chmod +x <script>.sh`
4. For Claude Code hooks: add the entry to `settings.json` (see snippet above)
5. For Git hooks: re-run `install-hooks.sh` in consumer projects
6. Update this README

---

## Skipping Hooks

**Git hooks** — bypass for a specific commit (use sparingly):
```bash
git commit --no-verify -m "docs: update README"
```

**Claude Code hooks** — cannot be bypassed per-command. Remove from `settings.json` temporarily if needed, then restore.
