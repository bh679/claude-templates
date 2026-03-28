<!-- Engineering base — github.com/bh679/claude-templates/templates/engineering/base.md -->
<!-- Included at copy time via {{INCLUDE:engineering/base.md}} -->

## Standards

The following standards are embedded from `bh679/claude-templates`. To check for updates,
compare the `standard-version` comments below against the current versions in the standards repo.

{{STANDARD:workflow}}

---

{{STANDARD:git}}

---

{{STANDARD:versioning}}

---


### Before ANY Implementation

1. Search project board for existing items
2. Enter plan mode (Gate 1)

---

## Project Board Management

- Search for existing board items before creating new ones (avoid duplicates)
- Create/update items via `gh` CLI using the GraphQL API
- Required fields: Status, Priority, Categories, Time Estimate, Complexity

```bash
# Find existing item
gh project item-list {{PROJECT_NUMBER}} --owner {{GITHUB_USER}} --format json | jq '.items[] | select(.title | test("search term"; "i"))'

# Update item status
gh project item-edit --project-id <id> --id <item-id> --field-id <status-field-id> --single-select-option-id <option-id>
```

---

## Documentation

{{STANDARD:wiki-writing}}

---


## Key Rules Summary

- Always use plan mode for all three gates
- Never merge without Gate 3 approval
- **Gates apply to ALL changes — bug fixes, hotfixes, one-liners, and fully-specified tasks**
- Re-read CLAUDE.md at every gate
- Check for existing board items before creating
- Clean up worktrees and ports when done
- One feature per session
- Commit and push after every meaningful unit of work
