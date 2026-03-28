[Home](Home) > [Features](Features) > New Project Skill

# New Project Skill

A global Claude skill that automates bootstrapping new projects from templates.

## How It Works

Triggered by `/new-project` or phrases like "set up a new project". The skill walks through an 8-step process:

1. **Choose template type** — discovers available templates from the repo
2. **Gather token values** — collects project-specific values (name, slug, port, etc.)
3. **Resolve includes and standards** — inlines shared content and versioned standards
4. **Copy template files** — sets up orchestrator, sub-repos, and wiki
5. **GitHub setup** — creates repos, Project V2 board, pushes initial commit
6. **Register as consumer** — adds to `consumers.json` for drift detection
7. **Install skills and hooks** — symlinks skills and installs enforcement hooks
8. **Verify setup** — runs a checklist to confirm everything is in place

## Technical Notes

- Requires `gh` CLI to be authenticated
- Supports engineering/product, engineering/backend, and operator template types
- Token resolution follows a strict order: INCLUDE, STANDARD, VALUE
- Reports a summary on completion

## Related

- [Token System](Token-System)
- [Templates](Templates)
- [Skills](Skills)
