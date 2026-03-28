[Home](Home) > [Features](Features) > Versioning Standard

# Versioning Standard

The V.MM.PPPP version scheme used across all Claude-powered projects.

## How It Works

### Format

```
V.MM.PPPP
```

| Segment | Name | When to bump |
|---|---|---|
| V | Major | Breaking changes, architectural rewrites |
| MM | Minor | Every merged feature (Gate 3) — resets PPPP to 0000 |
| PPPP | Patch | Every commit during development |

Example: `V1.03.0027` = Major version 1, 3rd feature merged, 27th commit in that feature.

### Git Tags

Tag every minor (MM) bump. Tags use lowercase `v` prefix: `v1.03.0000`.

### Cross-Repo Gating

Consumer repos declare required versions of their dependencies in `package.json`:

```json
{
  "requiredAnalyticsVersion": "1.02.0000"
}
```

Deploy scripts validate version compatibility before starting.

### Data Contract Versioning

JSON files consumed by other repos include a `schemaVersion` field. Breaking schema changes bump the major version.

## Technical Notes

- Current version: 1.0.0
- Version lives in `package.json` (numeric form, no V prefix)
- Enforced by the versioning pre-commit hook
- Operator repos without package.json use a `VERSION` file

## Related

- [Git Standards](Git-Standards)
- [Hook Versioning](Hook-Versioning)
- [Enforceable Hooks](Enforceable-Hooks)
