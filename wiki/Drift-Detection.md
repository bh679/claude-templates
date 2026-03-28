[Home](Home) > [Features](Features) > Drift Detection

# Drift Detection

A GitHub Actions workflow that runs weekly to detect when consumer projects have outdated standards or missing template files.

## How It Works

1. The workflow runs every Monday at 09:00 UTC (before the weekly blog at 10:00)
2. It reads `consumers.json` to get the list of registered consumer projects
3. For each consumer, it checks the embedded standard version comments against the current versions in this repo
4. If a consumer is outdated, it opens a GitHub issue with details about what changed

### Consumer Registry

Each consumer project is registered in `consumers.json` with:

```json
{
  "repo": "bh679/project-slug",
  "template": "engineering/product",
  "claude_md_path": "CLAUDE.md",
  "description": "Project description"
}
```

Operator templates additionally specify `required_files` to check for missing scaffolding.

## Technical Notes

- Workflow file: `.github/workflows/drift-check.yml`
- Script: `.github/scripts/check-drift.sh`
- Requires a `PROJECT_PAT` secret for cross-repo access
- Can be triggered manually via `workflow_dispatch`
- Currently monitors 14 consumer projects

## Related

- [Standards](Standards)
- [Token System](Token-System)
- [Hook Versioning](Hook-Versioning)
