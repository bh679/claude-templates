# {{REPO_NAME}} — Developer Guide

<!-- Source: github.com/bh679/claude-templates/templates/repo/CLAUDE.md -->

This is the `{{REPO_NAME}}` sub-repo for the {{PROJECT_NAME}} project.

- **Tech stack:** {{TECH_STACK}}
- **Local dev port:** `{{DEV_PORT}}`
- **Project orchestrator:** {{PROJECT_REPO_URL}}

---

## Setup

```bash
npm install
npm run dev   # or: {{START_COMMAND}}
```

---

## Versioning

<!-- Full policy: github.com/bh679/claude-templates/standards/versioning.md -->

Format: `V.MM.PPPP` in `package.json`.

- Bump `PPPP` on every commit
- Bump `MM` on every merged feature (reset PPPP to `0000`)
- Bump `V` only for breaking changes

---

## Branching & Git

<!-- Full policy: github.com/bh679/claude-templates/standards/git.md -->

- Feature branches: `dev/<feature-slug>`
- All development in **git worktrees** (never directly on `main`)
- Commit after every meaningful unit of work
- Push immediately after every commit

### Blocked commands

The following are blocked in `.claude/settings.json`:
- `git push --force`
- `git reset --hard`
- `rm -rf`

---

## Build & Test

```bash
npm run build    # production build
npm run test     # unit tests
```

For UI/integration testing, use the Playwright setup in the project orchestrator repo.

---

## Key Files

| File | Purpose |
|---|---|
| `{{MAIN_ENTRY}}` | Application entry point |
| `package.json` | Dependencies and version |
| `.env.example` | Required environment variables |

---

## Environment Variables

Copy `.env.example` to `.env` and fill in values. Never commit `.env`.

Required variables:
- `{{ENV_VAR_1}}` — {{ENV_VAR_1_DESCRIPTION}}
- `{{ENV_VAR_2}}` — {{ENV_VAR_2_DESCRIPTION}}
