<!-- standard: versioning | version: 1.0.0 -->
# Versioning Standard — V.MM.PPPP

> **Source of truth** for version numbering across all Claude-powered projects.


## Versioning

Format: `V.MM.PPPP`
- Bump **PPPP** on every commit
- Bump **MM** on every merged feature (reset PPPP to 0000)
- Bump **V** only for breaking changes

Update `package.json` version field on every commit.

---

## Format

```
V.MM.PPPP
```

| Segment | Name | Description |
|---|---|---|
| `V` | Major | Breaking changes, architectural rewrites. Rarely bumped. |
| `MM` | Minor | Feature completion (one per merged feature). Zero-padded to 2 digits. |
| `PPPP` | Patch | Individual commits within a feature. Zero-padded to 4 digits. |

**Example:** `V1.03.0027` = Major version 1, 3rd feature merged, 27th commit in that feature.

---

## Bump Rules

### Patch (PPPP) — every commit

Bump PPPP on every commit during development:

```
V1.02.0001  →  V1.02.0002  →  V1.02.0003
```

Reset PPPP to `0000` when bumping MM.

### Minor (MM) — every merged feature

Bump MM when a feature branch is merged to main:

```
V1.02.0015  →  V1.03.0000
```

Zero-pad to 2 digits: `01`, `02`, ..., `09`, `10`, `11`, ...

### Major (V) — breaking changes only

Bump V for:
- Complete architectural rewrites
- Breaking API changes that require client updates
- Major platform migrations

Reset MM and PPPP to `00.0000` on major bump:
```
V1.14.0007  →  V2.00.0000
```

---

## Where Version Lives

Each sub-repo has its own `package.json` with a `version` field:

```json
{
  "name": "chess-client",
  "version": "1.02.0015"
}
```

Note: The `V` prefix appears in git tags and display strings, but `package.json` uses the numeric form (`1.02.0015` not `V1.02.0015`).

---

## Version Commit

Every version bump gets its own commit immediately before or after the feature commit:

```
feat: add user registration flow
version: bump to V1.03.0000
```

Or inline — bump the version in the same commit as the feature work. Either is acceptable, but be consistent within a project.

---

## Multi-Repo Projects

In projects with multiple sub-repos (e.g. chess-client + chess-api), each repo versions independently. They do not need to stay in sync.

If the project has a `requiredApiVersion` field in the client's package.json, update it when the API introduces a breaking change.

---

## Git Tags

Tag after every MM (minor) bump:

```bash
git tag v1.03.0000
git push origin v1.03.0000
```

Tags use lowercase `v` prefix: `v1.03.0000`.

---

## README Version Badge

The README does not need a version badge — the `package.json` version is the source of truth. Update the README's "Latest Version" section only on major bumps.

---

## Rollback Procedure

When a bad version is deployed, follow these steps:

### Revert to a Previous Tagged Version

```bash
# Find the last known-good tag
git tag --sort=-version:refname | head -10

# Check out the known-good version
git checkout v1.02.0000

# Or create a hotfix branch from the good tag
git checkout -b hotfix/rollback-from-v1.03 v1.02.0000
```

### PM2 Rollback

For PM2-managed services:

```bash
# Stop the current process
pm2 stop <app-name>

# Check out the previous good version
git checkout v1.02.0000

# Install dependencies and restart
npm install
pm2 restart <app-name>

# Verify the rollback
pm2 logs <app-name> --lines 20
```

### Bump Forward vs Revert

- **Revert** when the fix is non-trivial and users are affected now. Roll back to the last good tag, then develop the fix on a branch.
- **Bump forward** when the fix is simple (< 15 minutes). Create a new patch commit with the fix and deploy it.
- Never reuse a version number. If `V1.03.0000` was bad, the fix is `V1.03.0001` or a rollback to `V1.02.0015` — not a re-tag of `V1.03.0000`.

---

## Data Contract Versioning

For repos consumed as data sources (not npm packages), use schema versioning to prevent breaking consumers silently.

### Schema Version Field

Add a `schemaVersion` field to the root of any JSON file consumed by other repos:

```json
{
  "schemaVersion": "1.00",
  "data": { ... }
}
```

Use `MAJOR.MINOR` format (no patch — schema changes are intentional, not incremental commits).

### Consumer Version Declaration

Consumer repos declare their minimum required schema version in `package.json`:

```json
{
  "name": "consumer-dashboard",
  "version": "1.04.0012",
  "requiredSchemaVersions": {
    "coo-agent/dashboard.json": "1.00",
    "analytics/report.json": "2.01"
  }
}
```

Deploy scripts should validate that consumed data files meet the minimum declared schema version.

### Breaking vs Non-Breaking Schema Changes

| Change type | Breaking? | Action |
|---|---|---|
| Add a new optional field | No | Bump minor (`1.00` → `1.01`) |
| Add a new required field | Yes | Bump major (`1.01` → `2.00`) |
| Remove a field | Yes | Bump major |
| Rename a field | Yes | Bump major |
| Change a field's type | Yes | Bump major |
| Reorder fields | No | No bump needed |

---

## Operator/Agent Repos

Some repos (e.g. `coo-agent`, `sentinel-agent`) have no `package.json` and are not npm packages. They still need versioning when consumed by other systems.

### When to Add Versioning

Add versioning when the repo:
- Produces data files consumed by other repos or dashboards
- Is deployed as a scheduled agent whose output format matters
- Has consumers that depend on its structure or behavior

If the repo is purely internal with no consumers, versioning is optional.

### How to Version Without package.json

**Option A — VERSION file** (preferred for simple repos):

Create a `VERSION` file at the repo root:

```
1.03.0000
```

Bump this file following the same V.MM.PPPP rules. Reference it in scripts:

```bash
VERSION=$(cat VERSION)
echo "Running coo-agent $VERSION"
```

**Option B — Metadata field in primary data files** (preferred when the repo's output is a data file):

```json
{
  "schemaVersion": "1.00",
  "generatedBy": "coo-agent",
  "generatedVersion": "1.03.0000",
  "data": { ... }
}
```

**Example:** `coo-agent`'s `dashboard.json` should include:

```json
{
  "schemaVersion": "1.00",
  "generatedBy": "coo-agent",
  "entries": [ ... ]
}
```

---

## Git Tags (Extended)

Tagging is **mandatory** on every minor (MM) bump. Tags are the primary mechanism for rollbacks and release tracking.

### Tagging Requirements

- Tag **every** minor bump: `git tag v1.03.0000`
- Tag **every** major bump: `git tag v2.00.0000`
- Patch-level tags are optional but encouraged for hotfixes
- Push tags immediately: `git push origin <tag>`

### Retroactive Tagging

If tags were missed, add them from git history:

```bash
# Find the commit where a version was bumped
git log --oneline --all --grep="bump to V1.03"

# Tag that commit retroactively
git tag v1.03.0000 <commit-hash>

# Push all missing tags at once
git push origin --tags
```

### Tag-Based Rollback

```bash
# List available tags
git tag --sort=-version:refname

# Roll back to a specific tagged version
git checkout v1.02.0000

# Or reset main to a tagged version (destructive — confirm with team first)
git checkout main
git reset --hard v1.02.0000
git push --force-with-lease origin main
```

### Tag Naming

| Context | Format | Example |
|---|---|---|
| Git tag | Lowercase `v` prefix | `v1.03.0000` |
| Display / docs | Uppercase `V` prefix | `V1.03.0000` |
| package.json | No prefix | `1.03.0000` |

---

## Cross-Repo Version Gating

When one repo depends on a specific version of another repo's output, declare and validate that dependency explicitly.

### Declaring Version Dependencies

In the consumer's `package.json`, add a field for each dependency:

```json
{
  "name": "chess-max-dashboard",
  "version": "1.04.0003",
  "requiredAnalyticsVersion": "1.02.0000",
  "requiredApiVersion": "1.05.0000"
}
```

Use the naming convention `required<RepoName>Version`.

### Deploy-Time Validation

Deploy scripts should validate version compatibility before starting:

```bash
#!/bin/bash
# validate-versions.sh

REQUIRED=$(node -p "require('./package.json').requiredAnalyticsVersion")
ACTUAL=$(node -p "require('../analytics/package.json').version")

if [ "$(printf '%s\n' "$REQUIRED" "$ACTUAL" | sort -V | head -1)" != "$REQUIRED" ]; then
  echo "ERROR: Analytics version $ACTUAL is below required $REQUIRED"
  exit 1
fi

echo "Version check passed: analytics $ACTUAL >= $REQUIRED"
```

### Example: CMD → CMUA Relationship

Chess Max Dashboard (CMD) consumes data from Chess Max Usage Analytics (CMUA). The dependency is declared as:

```json
// CMD's package.json
{
  "name": "chess-max-dashboard",
  "version": "1.04.0003",
  "requiredAnalyticsVersion": "1.02.0000"
}
```

When CMUA introduces a breaking change (e.g. renames a field in its output):
1. CMUA bumps its major version: `V1.05.0012` → `V2.00.0000`
2. CMD is updated to handle the new format
3. CMD bumps `requiredAnalyticsVersion` to `"2.00.0000"`
4. CMD's deploy script validates CMUA's version before starting

This ensures CMD never runs against an incompatible CMUA version.
