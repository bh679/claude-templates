<!-- standard: versioning | version: 2.1.0 -->
# Versioning Standard — SemVer

Follows [SemVer 2.0.0](https://semver.org/).

## Bump Conventions
| When | Bump | Example |
|---|---|---|
| Every commit during development | PATCH | `1.3.1` → `1.3.2` |
| Feature branch merged to main (Gate 3) | MINOR (reset PATCH) | `1.3.15` → `1.4.0` |
| Breaking API or architectural change | MAJOR (reset MINOR + PATCH) | `1.14.7` → `2.0.0` |

Update `package.json` version field on every commit.

## Where Version Lives
| Context | Location | Example |
|---|---|---|
| npm projects | `package.json` `version` field | `"1.3.15"` |
| Non-npm repos | `VERSION` file at repo root | `1.3.0` |

In multi-repo projects, each repo versions independently. For data files, use a `generatedVersion` field in output JSON.

## Git Tags
Tag every MINOR and MAJOR bump with lowercase `v` prefix and push immediately:
```bash
git tag v1.3.0 && git push origin v1.3.0
```
Patch-level tags are optional.

## Rollback
- **Non-trivial fix:** revert to last good tag (`git tag --sort=-version:refname | head -10`)
- **Simple fix (< 15 min):** bump forward with a new patch
- Never reuse a version number

## Data Contract Versioning
For repos consumed as data sources, add `"schemaVersion": "MAJOR.MINOR"`:

| Change type | Breaking? | Action |
|---|---|---|
| Add optional field | No | Bump minor |
| Add/remove/rename required field, change type | Yes | Bump major |

## Cross-Repo Version Gating
Declare minimum required versions in the consumer's `package.json` and validate at deploy time:

```json
{ "requiredAnalyticsVersion": "1.2.0", "requiredApiVersion": "1.5.0" }
```
