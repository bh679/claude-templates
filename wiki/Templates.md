[Home](Home) > Templates

# Templates

Copy-once starting points for new projects. Templates are copied into a project at init time and do not auto-propagate updates.

## Available Templates

| Template | Path | Description |
|---|---|---|
| [Engineering Product](Engineering-Product-Template) | `templates/engineering/product/` | Full-stack product development with 3-gate workflow |
| [Engineering Backend](Engineering-Backend-Template) | `templates/engineering/backend/` | Backend API development with HTTP diagnostics |
| [Operator](Operator-Template) | `templates/operator/` | Scheduled autonomous Claude agent |
| [Executive Ops Officer](Operator-Template) | `templates/executive-ops-officer/` | Executive operations variant of the operator template |
| [Wiki](Wiki-Template) | `templates/wiki/` | Wiki documentation starter files |
| [Repo](Engineering-Product-Template) | `templates/repo/` | Sub-repo CLAUDE.md for multi-repo projects |

## Shared Files

Templates share common content via the include system:

| File | Used by | Contains |
|---|---|---|
| `project-overview.md` | engineering templates | Project overview header |
| `engineering/base.md` | product, backend | Standards, core workflow, git/worktrees, versioning |
| `operator-base.md` | operator, executive-ops | State management, skip guard, turn limit, escalation |

## Bootstrapping Process

1. Copy the template files to the target project
2. Resolve `{{INCLUDE:...}}` tokens (inline shared content)
3. Resolve `{{STANDARD:...}}` tokens (inline versioned standards)
4. Replace `{{VALUE}}` tokens with project-specific values
5. Run setup commands (npm install, create directories)
6. Register in `consumers.json`

See the [Token System](Token-System) for details on token resolution.

## Related

- [Token System](Token-System)
- [New Project Skill](New-Project-Skill)
- [Standards](Standards)
