# Bootstrapping a New Project

## Token Reference

### Product Engineer Tokens

When copying `templates/product-engineer/`, replace these tokens:

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
| `{{PROJECT_DESCRIPTION}}` | `A multiplayer chess platform` | One-sentence project description, used in wiki Home.md |

### Backend Engineer Tokens

When copying `templates/backend-engineer/`, replace these tokens:

| Token | Example | Description |
|---|---|---|
| `{{PROJECT_NAME}}` | `Chess API` | Human-readable project name |
| `{{PROJECT_SLUG}}` | `chess-api` | Lowercase, hyphenated, used in URLs and filenames |
| `{{PROJECT_NUMBER}}` | `3` | GitHub Project V2 number (find in project URL: `/projects/3`) |
| `{{LIVE_URL}}` | `api.brennan.games/chess` | Production API URL |
| `{{BASE_PORT}}` | `4001` | Base port for local dev server |
| `{{REPO_LIST}}` | `chess-api` | Comma-separated list of sub-repos |
| `{{GITHUB_USER}}` | `bh679` | GitHub username |
| `{{WIKI_URL}}` | `github.com/bh679/chess-api/wiki` | Wiki URL |
| `{{API_BASE_PATH}}` | `/api/v1` | Base path prefix for all endpoints |
| `{{DB_TYPE}}` | `PostgreSQL` | Database technology (or "None" if stateless) |
| `{{TEST_COMMAND}}` | `npm test` | Command to run automated tests |
| `{{PROJECT_DESCRIPTION}}` | `A chess game REST API` | One-sentence project description, used in wiki Home.md |

### Operator Tokens

When copying `templates/operator/`, replace these tokens:

| Token | Example | Description |
|---|---|---|
| `{{AGENT_NAME}}` | `Weekly Blog Writer` | Human-readable name for the operator agent |
| `{{SCHEDULE}}` | `0 10 * * 1` | Cron expression for when the operator runs |
| `{{TRIGGER_DESCRIPTION}}` | `Every Monday at 10:00 UTC` | Human-readable description of the schedule |
| `{{DATA_SOURCES}}` | `GitHub events from bh679/* repos, pending-context.json` | What data the fetch script gathers |
| `{{OUTPUT_DESCRIPTION}}` | `A weekly markdown blog post saved to posts/YYYY-MM-DD.md` | What the operator produces each run |

---

## Bootstrapping Checklist

### Operator Project

- [ ] Copy `templates/operator/CLAUDE.md` → `<repo>/CLAUDE.md`
  - Replace all `{{TOKENS}}`
  - Fill in the skip guard condition
- [ ] Copy `templates/operator/.github/workflows/operator.yml` → `<repo>/.github/workflows/<agent-slug>.yml`
  - Replace `{{SCHEDULE}}` with your cron expression
  - Replace `{{AGENT_NAME}}` and `{{TRIGGER_DESCRIPTION}}`
- [ ] Copy `templates/operator/.github/scripts/fetch-data.sh` → `<repo>/.github/scripts/fetch-data.sh`
  - Implement the data fetching logic (replace the TODO block)
- [ ] Copy `templates/operator/guidelines.md` → `<repo>/guidelines.md`
  - Fill in all sections (tone, format, length, include/exclude rules)
- [ ] Copy `templates/operator/state.json` → `<repo>/state.json`
- [ ] Add the repo to `consumers.json` in claude-templates with `"template": "operator"` and `"required_files"`

---

### Product Engineer Project

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
- [ ] Copy `templates/wiki/Deployment.md` → `<wiki-repo>/Deployment.md` (optional — add when project has a deployment method)

---

### Backend Engineer Project

### 1. Project-level setup

- [ ] Copy `templates/backend-engineer/CLAUDE.md` → `<project>/CLAUDE.md`
  - Replace all `{{TOKENS}}`
- [ ] Copy `templates/product-engineer/.claude/settings.json` → `<project>/.claude/settings.json`
  - Add any project-specific tool permissions
- [ ] Create `<project>/ports/.gitkeep`

### 2. Sub-repo setup (for each sub-repo)

- [ ] Copy `templates/repo/CLAUDE.md` → `<sub-repo>/CLAUDE.md`
  - Replace all `{{TOKENS}}`

### 3. Wiki setup

- [ ] Copy `templates/wiki/CLAUDE.md` → `<wiki-repo>/CLAUDE.md`
  - Replace all `{{TOKENS}}`
- [ ] Copy `templates/wiki/Home.md` → `<wiki-repo>/Home.md`
- [ ] Copy `templates/wiki/Features.md` → `<wiki-repo>/Features.md`
- [ ] Copy `templates/wiki/Endpoints.md` → `<wiki-repo>/Endpoints.md`
- [ ] Copy `templates/wiki/Deployment.md` → `<wiki-repo>/Deployment.md` (optional)

---

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

### Operator

```
<operator-repo>/
├── CLAUDE.md                     (filled-in operator template)
├── guidelines.md                 (output quality rules)
├── state.json                    (cross-run memory)
└── .github/
    ├── workflows/
    │   └── <agent-slug>.yml      (cron-triggered workflow)
    └── scripts/
        └── fetch-data.sh         (data gathering script)
```

### Product Engineer

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
├── Features.md
└── Deployment.md                 (optional)
```

### Backend Engineer

```
<project>/                        (orchestrator repo)
├── CLAUDE.md                     (filled-in backend engineer template)
├── .claude/
│   └── settings.json
└── ports/
    └── .gitkeep

<sub-repo>/                       (e.g. chess-api)
└── CLAUDE.md                     (filled-in repo template)

<wiki-repo>.wiki/                 (e.g. chess-api.wiki)
├── CLAUDE.md
├── Home.md
├── Features.md
├── Endpoints.md
└── Deployment.md                 (optional)
```
