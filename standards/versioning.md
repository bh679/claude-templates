<!-- standard: versioning | version: 2.0.0 -->
# Versioning Standard — SemVer

> **Source of truth** for version numbering across all Claude-powered projects.
> Format follows [Semantic Versioning 2.0.0](https://semver.org/).

## Bump Conventions

| When | Bump | Example |
|---|---|---|
| Every commit during development | PATCH | `1.3.1` → `1.3.2` |
| Feature branch merged to main (Gate 3) | MINOR (reset PATCH) | `1.3.15` → `1.4.0` |
| Breaking API or architectural change | MAJOR (reset MINOR + PATCH) | `1.14.7` → `2.0.0` |

Update `package.json` version field on every commit.

---

## Where Version Lives

| Context | Location | Example |
|---|---|---|
| npm projects | `package.json` `version` field | `"1.3.15"` |
| Non-npm repos | `VERSION` file at repo root | `1.3.0` |
| Data files | `generatedVersion` field in output JSON | `"1.3.0"` |

In multi-repo projects, each repo versions independently.

---

## Git Tags

- Tag every MINOR and MAJOR bump: `git tag v1.3.0`
- Use lowercase `v` prefix: `v1.3.0`
- Push tags immediately: `git push origin v1.3.0`
- Patch-level tags are optional but encouraged for hotfixes

---

## Rollback

- **Revert** to last good tag when the fix is non-trivial
- **Bump forward** with a new patch when the fix is simple (< 15 min)
- Never reuse a version number

```bash
git tag --sort=-version:refname | head -10   # find last good tag
git checkout v1.2.0                           # roll back
```

---

## Data Contract Versioning

For repos consumed as data sources, add a `schemaVersion` field (`MAJOR.MINOR` format):

```json
{
  "schemaVersion": "1.0",
  "data": { ... }
}
```

| Change type | Breaking? | Action |
|---|---|---|
| Add optional field | No | Bump minor |
| Add/remove/rename required field, change type | Yes | Bump major |

---

## Cross-Repo Version Gating

Declare dependencies in the consumer's `package.json`:

```json
{
  "requiredAnalyticsVersion": "1.2.0",
  "requiredApiVersion": "1.5.0"
}
```

Deploy scripts should validate consumed versions meet declared minimums before starting.
