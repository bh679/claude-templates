[Home](Home) > [Standards](Standards) > Project Board Standard

# Project Board Standard

GitHub Projects board interaction rules enforced across all Claude-powered projects.

## How It Works

All project board operations use the `gh` CLI with the GraphQL API. The standard enforces a search-before-create rule to prevent duplicate items.

### Core Rules

- Search for existing board items before creating new ones
- Use required fields: Status, Priority, Categories, Time Estimate, Complexity
- Update board items at each workflow gate (planning, testing, merge)

### Workflow Integration

1. **Before implementation** - search the board for existing items related to your task
2. **After Gate 1 planning** - create or update the board item with the planned work
3. **After Gate 3 merge** - update the board item status to Done

## Technical Notes

- Current version: 1.0.0
- Uses `{{PROJECT_NUMBER}}` and `{{GITHUB_USER}}` tokens, resolved at bootstrap
- Embedded in engineering templates via `{{STANDARD:project-board}}`

## Related

- [Standards](Standards)
- [Three-Gate Workflow](Three-Gate-Workflow)
- [Token System](Token-System)
