<!-- standard: project-board | version: 1.0.0 -->
# Project Board Management

> **Source of truth** for GitHub Projects board interaction across all Claude-powered projects.

## Core Rules

- **Search before creating** — always check for existing board items to avoid duplicates
- **Use `gh` CLI** with the GraphQL API for all create/update operations
- **Required fields:** Status, Priority, Categories, Time Estimate, Complexity

## Common Operations

### Find an existing item

```bash
gh project item-list {{PROJECT_NUMBER}} --owner {{GITHUB_USER}} --format json | jq '.items[] | select(.title | test("search term"; "i"))'
```

### Update item status

```bash
gh project item-edit --project-id <id> --id <item-id> --field-id <status-field-id> --single-select-option-id <option-id>
```

## Workflow Integration

- **Before implementation:** search the board for existing items related to your task
- **After Gate 1 planning:** create or update the board item with the planned work
- **After Gate 3 merge:** update the board item status to Done
