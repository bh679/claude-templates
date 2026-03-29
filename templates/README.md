# Bootstrapping a New Project

## Token System

Templates use three token types, resolved at copy time in this order:

### 1. Include Tokens — `{{INCLUDE:<path>}}`

Inline shared content from another file. Path is relative to the `templates/` directory.

**Example:** `{{INCLUDE:engineering/base.md}}` inlines `templates/engineering/base.md`.

### 2. Standard Tokens — `{{STANDARD:<name>}}`

Inline a versioned standard from `standards/<name>.md`. When resolved, the full standard
content is embedded with a version comment so consumer projects can detect drift:

```markdown
<!-- standard: git | version: 1.0.0 -->
# Git Standards
...full content...
```

Available standards: `workflow`, `git`, `versioning`, `wiki-writing`, `operator`, `http-diagnostics`

**Version tracking:** Each standard has a `<!-- standard: <name> | version: X.Y.Z -->` header.
When a standard is updated, its version is bumped. Consumer projects can compare their embedded
version against the current version in this repo to check if they need updating.

### 3. Value Tokens — `{{TOKEN_NAME}}`

Replaced with project-specific values collected during setup.

**Resolution order:**
1. Copy the template file to the target project
2. Resolve all `{{INCLUDE:...}}` tokens (recursive)
3. Resolve all `{{STANDARD:...}}` tokens (inline standard with version comment)
4. Replace all `{{VALUE}}` tokens with collected values

---

## Shared Files

| File | Used by | Contains |
|---|---|---|
| `project-overview.md` | engineering/project-overview.md | Project overview header (PROJECT_NAME, LIVE_URL) |
| `engineering/project-overview.md` | engineering/product, engineering/backend | Includes project-overview.md + adds Repos, GitHub Project, Wiki fields |
| `engineering/base.md` | engineering/product, engineering/backend | Standards (via STANDARD tokens), core workflow, session ID, board mgmt, git/worktrees, port mgmt, versioning, Gate 3, documentation, blog trigger, key rules |
| `operator-base.md` | operator, executive-ops-officer | State management (state.json read/update/commit), skip guard, turn limit (30), human escalation (GitHub issue + stop) |

---

## Token Reference

### Engineering — Product Tokens

When copying `templates/engineering/product/`, replace these tokens:

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

### Engineering — Backend Tokens

When copying `templates/engineering/backend/`, replace these tokens:

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

## Standard Version Tracking

Each standard file has a version comment on line 1:

```markdown
<!-- standard: git | version: 1.0.0 -->
```

**Bump rules:**
- **Patch** (0.0.x): Clarification, typo fix, formatting — no behavioural change
- **Minor** (0.x.0): New section, new guidance — backwards compatible
- **Major** (x.0.0): Removed or changed existing rules — may break consumer workflows

**Automated enforcement:** Version bumps are enforced by:
- A **CI check** that fails PRs changing standards without a version bump
- A **local pre-commit hook** for fast feedback before push
- A **version manifest** (`standards-versions.json`) that stays in sync

See [`docs/version-enforcement.md`](../docs/version-enforcement.md) for full details.

**Automated drift detection:** Consumer projects embed the version comment when standards
are inlined via `{{STANDARD:...}}` tokens. A weekly GitHub Actions workflow compares
consumer versions against current versions and opens issues in outdated repos.

See [`docs/drift-detection.md`](../docs/drift-detection.md) for full details.

---

## Bootstrapping Checklist

### Operator Project

- [ ] Copy `templates/operator/CLAUDE.md` → `<repo>/CLAUDE.md`
  - Resolve all `{{INCLUDE:...}}` tokens (inline shared content)
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

### Engineering — Product Project

### 1. Project-level setup (orchestrator repo)

- [ ] Copy `templates/engineering/product/CLAUDE.md` → `<project>/CLAUDE.md`
  - Resolve all `{{INCLUDE:...}}` tokens (inline shared content)
  - Resolve all `{{STANDARD:...}}` tokens (inline versioned standards)
  - Replace all `{{TOKENS}}`
  - Verify the GitHub Project V2 number is correct
- [ ] Copy `standards/gates/` → `<project>/.claude/gates/`
- [ ] Copy `templates/engineering/product/.claude/settings.json` → `<project>/.claude/settings.json`
  - Add any project-specific tool permissions
- [ ] Copy `templates/engineering/product/playwright.config.js` → `<project>/playwright.config.js`
- [ ] Copy `templates/engineering/product/package.json` → `<project>/package.json`
  - Update `name` field
  - Run `npm install`
- [ ] Create `<project>/tests/.gitkeep`
- [ ] Create `<project>/ports/.gitkeep`

### 2. Sub-repo setup (for each sub-repo: client, API, etc.)

Each sub-repo gets its own engineering template based on its role:
- **Frontend/full-stack** → `templates/engineering/product/CLAUDE.md`
- **Backend/API** → `templates/engineering/backend/CLAUDE.md`

- [ ] Copy the appropriate engineering CLAUDE.md → `<sub-repo>/CLAUDE.md`
  - Resolve all `{{INCLUDE:...}}` tokens (inline shared content)
  - Resolve all `{{STANDARD:...}}` tokens (inline versioned standards)
  - Replace all `{{TOKENS}}` with values appropriate to the sub-repo

### 3. Wiki setup (for each wiki repo)

- [ ] Copy `templates/wiki/CLAUDE.md` → `<wiki-repo>/CLAUDE.md`
  - Replace all `{{TOKENS}}`
- [ ] Copy `templates/wiki/Home.md` → `<wiki-repo>/Home.md`
- [ ] Copy `templates/wiki/Features.md` → `<wiki-repo>/Features.md`
- [ ] Copy `templates/wiki/Deployment.md` → `<wiki-repo>/Deployment.md` (optional — add when project has a deployment method)

---

### Engineering — Backend Project

### 1. Project-level setup

- [ ] Copy `templates/engineering/backend/CLAUDE.md` → `<project>/CLAUDE.md`
  - Resolve all `{{INCLUDE:...}}` tokens (inline shared content)
  - Resolve all `{{STANDARD:...}}` tokens (inline versioned standards)
  - If this backend exposes HTTP services: uncomment `{{STANDARD:http-diagnostics}}`
  - Replace all `{{TOKENS}}`
- [ ] Copy `standards/gates/` → `<project>/.claude/gates/`
- [ ] Copy `templates/engineering/product/.claude/settings.json` → `<project>/.claude/settings.json`
  - Add any project-specific tool permissions
- [ ] Create `<project>/ports/.gitkeep`
- [ ] If HTTP diagnostics enabled:
  - Create `<project>/diagnostics/.gitkeep`
  - Add `diagnostics/*.jsonl` and `diagnostics/snapshots/` to `.gitignore`

### 2. Sub-repo setup (for each sub-repo)

Each sub-repo gets its own engineering template based on its role (see Product checklist above for details).

- [ ] Copy the appropriate engineering CLAUDE.md → `<sub-repo>/CLAUDE.md`
  - Resolve all `{{INCLUDE:...}}` tokens (inline shared content)
  - Resolve all `{{STANDARD:...}}` tokens (inline versioned standards)
  - Replace all `{{TOKENS}}` with values appropriate to the sub-repo

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

### Engineering — Product

```
<project>/                        (orchestrator repo)
├── CLAUDE.md                     (filled-in product engineer template with embedded standards)
├── .claude/
│   ├── settings.json
│   └── gates/
│       ├── gate-1-plan.md
│       ├── gate-2-test.md
│       └── gate-3-merge.md
├── package.json
├── playwright.config.js
├── tests/
│   └── .gitkeep
└── ports/
    └── .gitkeep

<sub-repo>/                       (e.g. chess-client)
└── CLAUDE.md                     (filled-in engineering template with embedded standards)

<wiki-repo>.wiki/                 (e.g. chess-client.wiki)
├── CLAUDE.md
├── Home.md
├── Features.md
└── Deployment.md                 (optional)
```

### Engineering — Backend

```
<project>/                        (orchestrator repo)
├── CLAUDE.md                     (filled-in backend engineer template with embedded standards)
├── .claude/
│   ├── settings.json
│   └── gates/
│       ├── gate-1-plan.md
│       ├── gate-2-test.md
│       └── gate-3-merge.md
└── ports/
    └── .gitkeep

<sub-repo>/                       (e.g. chess-api)
└── CLAUDE.md                     (filled-in engineering template with embedded standards)

<wiki-repo>.wiki/                 (e.g. chess-api.wiki)
├── CLAUDE.md
├── Home.md
├── Features.md
├── Endpoints.md
└── Deployment.md                 (optional)
```
