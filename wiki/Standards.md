[Home](Home) > Standards

# Standards

Versioned policy documents that serve as the source of truth across all Claude-powered projects. Standards are embedded into consumer projects via `{{STANDARD:name}}` tokens at bootstrap time.

## Available Standards

| Standard | Version | Covers |
|---|---|---|
| [Git Standards](Git-Standards) | 1.1.0 | Branch naming, commit messages, worktrees, merge strategy |
| [Three-Gate Workflow](Three-Gate-Workflow) | 1.1.0 | Plan, Test, Merge approval gates |
| [Versioning](Versioning-Standard) | 1.0.0 | V.MM.PPPP scheme, bump rules, tagging |
| [Wiki Writing](Wiki-Writing-Standard) | 1.0.0 | Documentation style, breadcrumbs, templates |
| [Operator](Operator-Standard) | 1.0.0 | Scheduled autonomous agent scaffolding |
| [Unit Testing](Unit-Testing-Standard) | 1.0.0 | Test requirements, coverage, organization |
| [HTTP Diagnostics](HTTP-Diagnostics-Standard) | 1.0.0 | Health endpoints, error logging, usage tracking |

## How Standards Work

1. Standards live in `standards/` as versioned markdown files
2. Each file has a version comment on line 1: `<!-- standard: name | version: X.Y.Z -->`
3. Templates reference standards via `{{STANDARD:name}}` tokens
4. At bootstrap time, the full standard content is inlined into the consumer's CLAUDE.md
5. The version comment enables drift detection — consumers can compare their embedded version against the current source

## Version Bump Rules

- **Patch** (0.0.x): Clarification or typo — no behavioural change
- **Minor** (0.x.0): New section or guidance — backwards compatible
- **Major** (x.0.0): Removed or changed rules — may break consumer workflows

## Related

- [Token System](Token-System)
- [Drift Detection](Drift-Detection)
- [Enforceable Hooks](Enforceable-Hooks)
