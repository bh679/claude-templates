# Bootstrapping a New Project

## Token Reference

When copying templates, replace these tokens with project-specific values:

| Token | Example | Description |
|---|---|---|
| `{{PROJECT_NAME}}` | `Chess` | Human-readable project name |
| `{{PROJECT_SLUG}}` | `chess` | Lowercase, hyphenated, used in URLs and filenames |
| `{{PROJECT_NUMBER}}` | `3` | GitHub Project V2 number (find in project URL: `/projects/3`) |
| `{{LIVE_URL}}` | `brennan.games/chess` | Production URL |
| `{{BASE_PORT}}` | `3001` | Base port for local dev server |
| `{{REPO_LIST}}` | `chess-client, chess-api` | Comma-separated list of sub-repos |
| `{{GITHUB_USER}}` | `bh679` | GitHub username |
| `{{WIKI_URL}}` | `github.com/bh679/chess-client/wiki` | Wiki URL for the main client/frontend repo |

---

## Bootstrapping Checklist

### 1. Project-level setup (orchestrator repo)

- [ ] Copy `templates/product-engineer/CLAUDE.md` → `<project>/CLAUDE.md`
  - Replace all `{{TOKENS}}`
  - Verify the GitHub Project V2 number is correct
- [ ] Copy `templates/product-engineer/.claude/settings.json` → `<project>/.claude/settings.json`
  - Add any project-specific tool permissions
- [ ] Copy `templates/product-engineer/playwright.config.js` → `<project>/playwright.config.js`
- [ ] Copy `templates/product-engineer/package.json` → `<project>/package.json`
  - Update `name` field
  - Run `npm install`
- [ ] Create `<project>/tests/.gitkeep`
- [ ] Create `<project>/ports/.gitkeep`

### 2. Sub-repo setup (for each sub-repo: client, API, etc.)

- [ ] Copy `templates/repo/CLAUDE.md` → `<sub-repo>/CLAUDE.md`
  - Replace all `{{TOKENS}}`

### 3. Wiki setup (for each wiki repo)

- [ ] Copy `templates/wiki/CLAUDE.md` → `<wiki-repo>/CLAUDE.md`
  - Replace all `{{TOKENS}}`
- [ ] Copy `templates/wiki/Home.md` → `<wiki-repo>/Home.md`
- [ ] Copy `templates/wiki/Features.md` → `<wiki-repo>/Features.md`

### 4. GitHub setup

- [ ] Create GitHub repository
- [ ] Create GitHub Project V2 board with columns: Backlog, IDEA, PLAN, DEV, TEST, DONE
- [ ] Add project fields: Priority, Categories, Time Estimate, Complexity, Score
- [ ] Enable GitHub Actions if using drift detection

### 5. Skills (one-time per developer machine)

- [ ] Run `./install-skills.sh` from the claude-templates repo root
- [ ] Verify `trigger-blog` appears in Claude skill list

---

## File Structure After Bootstrapping

```
<project>/                        (orchestrator repo)
├── CLAUDE.md                     (filled-in product engineer template)
├── .claude/
│   └── settings.json
├── package.json
├── playwright.config.js
├── tests/
│   └── .gitkeep
└── ports/
    └── .gitkeep

<sub-repo>/                       (e.g. chess-client)
└── CLAUDE.md                     (filled-in repo template)

<wiki-repo>.wiki/                 (e.g. chess-client.wiki)
├── CLAUDE.md
├── Home.md
└── Features.md
```
