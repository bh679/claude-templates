[Home](Home) > [Features](Features) > Token System

# Token System

Templates use three token types, resolved at copy time in a specific order, to compose project-specific CLAUDE.md files from shared components.

## How It Works

### 1. Include Tokens — `{{INCLUDE:<path>}}`

Inline shared content from another file. Path is relative to the `templates/` directory. Includes can be nested.

Example: `{{INCLUDE:engineering/base.md}}` inlines the shared engineering base content.

### 2. Standard Tokens — `{{STANDARD:<name>}}`

Inline a versioned standard from `rules/<name>.md` or `playbooks/<name>.md`. The full content is embedded with a version comment enabling drift detection.

Example: `{{STANDARD:git}}` inlines the git standard with its version header.

### 3. Value Tokens — `{{TOKEN_NAME}}`

Replaced with project-specific values collected during setup. Examples: `{{PROJECT_NAME}}`, `{{BASE_PORT}}`, `{{GITHUB_USER}}`.

### Resolution Order

1. Resolve all `{{INCLUDE:...}}` tokens (recursive)
2. Resolve all `{{STANDARD:...}}` tokens
3. Replace all `{{VALUE}}` tokens

## Technical Notes

- Available standards: workflow, git, versioning, wiki-writing, operator, http-diagnostics, unit-testing
- A shared file that is itself inlined must never contain an include token naming itself — not even inside an HTML comment. Resolution is recursive, so the token would be re-emitted every pass and loop forever. Provenance comments name the path in prose instead.
- Only a token alone on its own line is live. Tokens inside HTML comments or code spans are documentation and are left as-is.
- Token reference tables for each template type are in `templates/README.md`
- The `/new-project` skill automates the full resolution process

## Related

- [Templates](Templates)
- [Standards](Standards)
- [New Project Skill](New-Project-Skill)
- [Drift Detection](Drift-Detection)
