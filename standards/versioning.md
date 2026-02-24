# Versioning Standard — V.MM.PPPP

> **Source of truth** for version numbering across all Claude-powered projects.
> Consumer projects reference this doc with a pointer comment in their CLAUDE.md.

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

Bump MM when a feature branch is merged to main (Gate 3):

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
