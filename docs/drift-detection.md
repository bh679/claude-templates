# Drift Detection

> Monitors consumer projects for outdated standards and missing template scaffolding.

---

## How It Works

A weekly GitHub Actions workflow checks every consumer project listed in `consumers.json` for two types of drift:

1. **Fingerprint drift** — missing key sections from the template (engineering only)
2. **Version drift** — embedded standards older than the current versions in this repo

When drift is detected, the workflow opens a GitHub issue in the consumer repo with details of what's outdated.

---

## Architecture

```
consumers.json               ← list of monitored projects
.github/scripts/
  check-drift.sh             ← main drift check logic
  standards-versions.json    ← current standard versions (generated)
  build-versions-manifest.sh ← regenerates the manifest
.github/workflows/
  drift-check.yml            ← weekly cron trigger (Mondays 09:00 UTC)
```

---

## Consumer Types

### Engineering Projects

Checked for **both** fingerprint and version drift.

**Fingerprint check:** The consumer's CLAUDE.md is fetched via GitHub API and searched for required strings (Gate 1, Gate 2, Gate 3, V.MM.PPPP, EnterPlanMode, etc.). Missing fingerprints indicate the CLAUDE.md has diverged from the template.

**Version check:** The consumer's CLAUDE.md is searched for `<!-- standard: <name> | version: X.Y.Z -->` comments. Each found version is compared against `standards-versions.json`. If the consumer's version is lower, the standard is outdated.

### Operator Projects

Checked for **file existence** and **version drift**.

**File check:** Required files listed in `consumers.json` are verified to exist in the consumer repo via GitHub API.

**Version check:** Same as engineering — extracts version comments from the consumer's CLAUDE.md and compares against current versions.

---

## consumers.json Format

```json
[
  {
    "repo": "bh679/chess-project",
    "template": "engineering/product",
    "claude_md_path": "CLAUDE.md",
    "description": "Chess game platform orchestrator"
  },
  {
    "repo": "bh679/weekly-blog",
    "template": "operator",
    "description": "Weekly development blog writer",
    "required_files": [
      ".github/workflows/weekly-blog.yml",
      "state.json"
    ]
  }
]
```

| Field | Required | Description |
|---|---|---|
| `repo` | Yes | GitHub repo in `owner/name` format |
| `template` | Yes | Template type: `engineering/product`, `engineering/backend`, or `operator` |
| `claude_md_path` | Engineering only | Path to CLAUDE.md in the consumer repo |
| `description` | No | Human-readable description |
| `required_files` | Operator only | List of files that must exist |

---

## Drift Issue Format

When drift is detected, an issue is opened in the consumer repo with the label `claude-template-drift`. The issue includes:

- **Missing Fingerprints** — which template sections are absent (engineering only)
- **Missing Files** — which scaffolding files are missing (operator only)
- **Outdated Standards** — which standards are behind, with version numbers (e.g. `git: v1.0.0 → v1.2.0`)
- **What to Do** — actionable steps to resolve the drift

Duplicate issues are avoided — if an open `claude-template-drift` issue already exists, no new issue is created.

---

## Running Locally

```bash
# Dry run — see what would be flagged (requires gh CLI authenticated)
.github/scripts/check-drift.sh consumers.json templates/engineering/product

# Regenerate the version manifest first
.github/scripts/build-versions-manifest.sh
```

**Requirements:**
- `gh` CLI authenticated with a PAT that has access to consumer repos
- `jq` installed

---

## Adding a Consumer Project

1. Add an entry to `consumers.json` with the appropriate fields
2. The drift check will automatically include it on the next weekly run (or manual trigger)
3. Ensure the consumer repo has the `claude-template-drift` label created (the workflow creates it automatically on first issue)

---

## Workflow Schedule

| Trigger | When |
|---|---|
| Scheduled | Every Monday at 09:00 UTC |
| Manual | Via `workflow_dispatch` in GitHub Actions |

The workflow requires a `PROJECT_PAT` secret with repo access to open issues in consumer repos.

---

## How Consumers Update Outdated Standards

When a consumer receives a drift issue listing outdated standards:

1. Open the consumer's CLAUDE.md
2. Find the `<!-- standard: <name> | version: X.Y.Z -->` comment for each outdated standard
3. Replace the entire standard section (from the version comment to the next `---` separator) with the current content from the corresponding file in `rules/` or `playbooks/`
4. Re-run `install-hooks.sh` to update any copied git hooks
5. Close the drift issue
