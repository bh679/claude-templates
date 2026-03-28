[Home](Home) > [Features](Features) > Engineering Product Template

# Engineering Product Template

Full-stack product development template with the three-gate workflow, Playwright testing, and GitHub Project V2 board integration.

## How It Works

The template provides a complete Claude-powered development environment for product engineering. After bootstrapping, the project has:

- **CLAUDE.md** with embedded standards (git, workflow, versioning, wiki-writing)
- **Playwright** for e2e testing with screenshot capture
- **Package.json** with test scripts
- **Settings.json** with tool permissions and blocked commands
- **Git hooks** for version enforcement and merge rules

### Files Included

```
templates/engineering/product/
├── CLAUDE.md              — Main instructions (uses INCLUDE and STANDARD tokens)
├── .claude/settings.json  — Tool permissions
├── package.json           — Dependencies (Playwright)
├── playwright.config.js   — Test configuration
```

### Token Reference

| Token | Example | Description |
|---|---|---|
| `{{PROJECT_NAME}}` | Chess | Human-readable name |
| `{{PROJECT_SLUG}}` | chess | URL/filename slug |
| `{{PROJECT_NUMBER}}` | 3 | GitHub Project V2 number |
| `{{LIVE_URL}}` | brennan.games/chess | Production URL |
| `{{BASE_PORT}}` | 3001 | Local dev server port |
| `{{REPO_LIST}}` | chess-client, chess-api | Sub-repos |
| `{{GITHUB_USER}}` | bh679 | GitHub username |
| `{{WIKI_URL}}` | github.com/bh679/chess-client/wiki | Wiki URL |

## Related

- [Engineering Backend Template](Engineering-Backend-Template)
- [Three-Gate Workflow](Three-Gate-Workflow)
- [Token System](Token-System)
- [New Project Skill](New-Project-Skill)
