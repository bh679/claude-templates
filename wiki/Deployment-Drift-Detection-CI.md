[Home](Home) > [Deployment](Deployment) > Drift Detection CI

# Deployment — Drift Detection CI

GitHub Actions workflow that monitors consumer projects for outdated standards.

## Prerequisites

- GitHub repository with Actions enabled
- `PROJECT_PAT` secret configured with cross-repo read access
- `consumers.json` with registered consumer projects

## Environment Variables

| Variable | Required | Description | Example |
|---|---|---|---|
| `PROJECT_PAT` | Yes | GitHub PAT with repo read access to consumer projects | `ghp_...` |

## Deployment Procedure

The workflow is already configured in `.github/workflows/drift-check.yml`. It runs automatically every Monday at 09:00 UTC.

1. Ensure `PROJECT_PAT` secret is set in repo settings
2. Add consumer projects to `consumers.json`
3. The workflow triggers automatically on schedule

To trigger manually:
```bash
gh workflow run "Template Drift Check"
```

## How It Works

1. Checks out claude-templates
2. Reads `consumers.json` for the list of monitored projects
3. For each consumer, compares embedded standard versions against current versions
4. Opens GitHub issues for any outdated consumers

## Rollback Procedure

1. Disable the workflow in GitHub Actions settings
2. Or remove the cron trigger from the workflow file

## Health Check

- Check workflow runs: `gh run list --workflow=drift-check.yml`
- Check for open drift issues: `gh issue list --label=drift`

## Related

- [Drift Detection](Drift-Detection)
- [Standards](Standards)
