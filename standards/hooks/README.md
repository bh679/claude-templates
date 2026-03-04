# Git Hooks

> Reusable git hooks that enforce standards across all Claude-powered projects.
> See [`versioning.md`](../versioning.md) for the V.MM.PPPP format specification.

---

## Available Hooks

### `pre-commit-version-check.sh`

Runs before every commit to enforce two rules:

1. **Version was bumped** — `package.json` version must differ from the previous commit (PPPP bump at minimum)
2. **Format is valid** — version must match `V.MM.PPPP` (`1.02.0015`, not `v1.2.15`)

| Segment | Rules |
|---|---|
| `V` | Integer (e.g. `0`, `1`, `2`) |
| `MM` | 2-digit, zero-padded (`01`, `02`, ..., `99`) |
| `PPPP` | 4-digit, zero-padded (`0000`, `0001`, ..., `9999`) |

#### Error examples

```
ERROR: Version was not bumped.
  Previous: 1.02.0015
  Current:  1.02.0015

Every commit must bump the version (PPPP at minimum).
Example: 1.02.0015 -> 1.02.0016
```

```
ERROR: Invalid version format in package.json.
  Found:    "1.2.15"
  Expected: V.MM.PPPP (e.g. 1.02.0015)
```

---

## Installation

### Quick install

From your **project root** (the repo you want to add the hook to):

```bash
~/Projects/Claude\ Templates/standards/hooks/install-hooks.sh
```

This copies the hook into `.git/hooks/pre-commit`. If a pre-commit hook already exists, it is backed up to `.git/hooks/pre-commit.bak`.

### Manual install

```bash
cp ~/Projects/Claude\ Templates/standards/hooks/pre-commit-version-check.sh \
   .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Worktree support

The install script detects worktrees automatically — it installs to the correct `.git/hooks/` directory regardless of whether you're in a worktree or the main repo.

---

## Skipping the hook

If you need to bypass the version check for a specific commit (e.g. docs-only changes):

```bash
git commit --no-verify -m "docs: update README"
```

Use sparingly. The standard expects every commit to bump the version.

---

## Adding new hooks

1. Create the hook script in this directory: `standards/hooks/<hook-name>.sh`
2. Make it executable: `chmod +x <hook-name>.sh`
3. Update `install-hooks.sh` to include the new hook
4. Document it in this README
