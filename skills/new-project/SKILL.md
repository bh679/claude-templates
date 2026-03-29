---
name: new-project
description: >
  Bootstrap a new project using claude-templates standards and templates.
  Use when the user says "set up a new project", "create a new repo",
  "start a new project", "bootstrap a project", "new project",
  "new git repo", "new GitHub repo", or wants to initialise a project
  from a template.
---

# New Project Setup

This skill bootstraps a new project using the claude-templates system —
choosing the right template type, copying files, filling tokens, configuring
GitHub, and registering the project.

## When to Use

- When the user wants to create a new project, repo, or GitHub repository
- When the user asks to bootstrap or initialise a project from a template
- At the very start of a new project before any code has been written

## Pre-Check

Verify the `gh` CLI is authenticated:
```bash
gh auth status
```
If not authenticated, guide the user through `gh auth login` before proceeding.

---

## Step 1 — Choose a Template Type

First, discover what templates are available from GitHub:
```bash
gh api repos/bh679/claude-templates/contents/templates --jq '[.[] | select(.type == "dir") | .name]'
```

List the discovered template directories to the user, then ask which applies if not already specified. Also offer **None** for a plain repo with no Claude workflow templates.

Engineering templates are under `templates/engineering/`:
- `engineering/product` — Full-stack product development (3-gate workflow)
- `engineering/backend` — Backend API development (3-gate workflow + backend checklist)

---

## Step 2 — Gather Token Values

Before copying any files, collect values for all tokens relevant to the chosen template type.

### Engineering tokens (product and backend)

| Token | Example | Description |
|---|---|---|
| `{{PROJECT_NAME}}` | `Chess` | Human-readable project name |
| `{{PROJECT_SLUG}}` | `chess` | Lowercase, hyphenated — used in URLs and filenames |
| `{{PROJECT_NUMBER}}` | `3` | GitHub Project V2 number (find in project URL: `/projects/3`) |
| `{{LIVE_URL}}` | `brennan.games/chess` | Production URL |
| `{{BASE_PORT}}` | `3001` | Base port for local dev server |
| `{{REPO_LIST}}` | `chess-client, chess-api` | Comma-separated list of sub-repos |
| `{{GITHUB_USER}}` | `bh679` | GitHub username |
| `{{WIKI_URL}}` | `github.com/bh679/chess-client/wiki` | Wiki URL for the main client/frontend repo |

`{{PROJECT_NUMBER}}` can only be filled after Step 5 (GitHub setup). Leave as a placeholder and return to fill it in.

#### Backend-only additional tokens

| Token | Example | Description |
|---|---|---|
| `{{API_BASE_PATH}}` | `/api/v1` | Base path prefix for all endpoints |
| `{{DB_TYPE}}` | `PostgreSQL` | Database technology (or "None" if stateless) |
| `{{TEST_COMMAND}}` | `npm test` | Command to run automated tests |

### Operator tokens

| Token | Example | Description |
|---|---|---|
| `{{AGENT_NAME}}` | `Weekly Blog Agent` | Human-readable agent name |
| `{{SCHEDULE}}` | `0 9 * * 1` | Cron expression for when the agent runs |
| `{{TRIGGER_DESCRIPTION}}` | `Runs every Monday at 9am` | Plain-English description of the schedule |
| `{{DATA_SOURCES}}` | `- /tmp/github-events.json` | List of files written by fetch-data.sh that Claude reads |
| `{{OUTPUT_DESCRIPTION}}` | `Write a markdown post to posts/YYYY-MM-DD.md` | What the agent produces each run |

---

## Step 2b — Resolve Includes and Standards

After copying any template file, resolve tokens **before** replacing value tokens.

### Include tokens — `{{INCLUDE:<path>}}`

For each `{{INCLUDE:<path>}}` found in the copied file:
1. Read the referenced file from `~/Projects/Claude Templates/templates/<path>`
2. Replace the entire `{{INCLUDE:<path>}}` line with the file contents
3. Repeat until no `{{INCLUDE:...}}` tokens remain (includes can be nested)

Example: `{{INCLUDE:engineering/base.md}}` reads `~/Projects/Claude Templates/templates/engineering/base.md` and inlines it.

### Standard tokens — `{{STANDARD:<name>}}`

For each `{{STANDARD:<name>}}` found in the file:
1. Read `~/Projects/Claude Templates/standards/<name>.md`
2. The file's first line contains a version comment: `<!-- standard: <name> | version: X.Y.Z -->`
3. Replace the entire `{{STANDARD:<name>}}` line with the full file contents (including the version comment)

The embedded version comment enables drift detection — consumer projects can compare their version against the current version in the standards repo.

### Gate files — `.claude/gates/*.md`

Gate files copied from `standards/gates/` may also contain `{{STANDARD:<name>}}` tokens. After copying gate files, resolve these tokens the same way as in CLAUDE.md — replace the token line with the full contents of `standards/<name>.md`.

### Resolution order

1. Resolve all `{{INCLUDE:...}}` tokens (recursive — includes may contain other includes)
2. Resolve all `{{STANDARD:...}}` tokens in CLAUDE.md **and** `.claude/gates/*.md` files
3. Replace all `{{VALUE}}` tokens with collected values

---

## Step 3 — Engineering Product Setup

Follow all sub-steps in order. Skip to Step 4 if using a different template type.

### 3a. Orchestrator repo

1. Copy `~/Projects/Claude Templates/templates/engineering/product/CLAUDE.md` → `<project>/CLAUDE.md`
   - Resolve all `{{INCLUDE:...}}` tokens (see Step 2b)
   - Resolve all `{{STANDARD:...}}` tokens (see Step 2b)
   - Replace all `{{TOKENS}}` with collected values
2. Copy `~/Projects/Claude Templates/templates/engineering/product/.claude/settings.json` → `<project>/.claude/settings.json`
3. Copy `~/Projects/Claude Templates/templates/engineering/product/playwright.config.js` → `<project>/playwright.config.js`
4. Copy `~/Projects/Claude Templates/templates/engineering/product/package.json` → `<project>/package.json`
   - Update the `name` field to `{{PROJECT_SLUG}}`
   - Run `npm install`
5. Create placeholder directories:
   ```bash
   mkdir -p <project>/tests && touch <project>/tests/.gitkeep
   mkdir -p <project>/ports && touch <project>/ports/.gitkeep
   ```
6. Install hooks:
   ```bash
   cd <project>
   ~/Projects/Claude\ Templates/standards/hooks/git/install-hooks.sh
   ~/Projects/Claude\ Templates/standards/hooks/versioning/install-hooks.sh
   ```

### 3b. Sub-repos (repeat for each: client, API, etc.)

Each sub-repo gets its own engineering template based on its role:
- **Frontend/full-stack sub-repos** → use `engineering/product`
- **Backend/API sub-repos** → use `engineering/backend`

Ask the user which template to use for each sub-repo if not obvious from the name.

1. Copy the appropriate engineering CLAUDE.md → `<sub-repo>/CLAUDE.md`
   - `~/Projects/Claude Templates/templates/engineering/product/CLAUDE.md` for frontend/full-stack
   - `~/Projects/Claude Templates/templates/engineering/backend/CLAUDE.md` for backend/API
2. Resolve all `{{INCLUDE:...}}` tokens (see Step 2b)
3. Resolve all `{{STANDARD:...}}` tokens (see Step 2b)
4. Replace all `{{TOKENS}}` with values appropriate to the sub-repo
5. Install hooks:
   ```bash
   cd <sub-repo>
   ~/Projects/Claude\ Templates/standards/hooks/git/install-hooks.sh
   ~/Projects/Claude\ Templates/standards/hooks/versioning/install-hooks.sh
   ```

### 3c. Wiki repo (repeat for each wiki)

1. Copy `~/Projects/Claude Templates/templates/wiki/CLAUDE.md` → `<wiki-repo>/CLAUDE.md`
2. Copy `~/Projects/Claude Templates/templates/wiki/Home.md` → `<wiki-repo>/Home.md`
3. Copy `~/Projects/Claude Templates/templates/wiki/Features.md` → `<wiki-repo>/Features.md`
4. Replace all `{{TOKENS}}` in each file

---

## Step 3b — Engineering Backend Setup

Follow all sub-steps in order. Skip to Step 4 if using a different template type.

### 3b-a. Orchestrator repo

1. Copy `~/Projects/Claude Templates/templates/engineering/backend/CLAUDE.md` → `<project>/CLAUDE.md`
   - Resolve all `{{INCLUDE:...}}` tokens (see Step 2b)
   - Resolve all `{{STANDARD:...}}` tokens (see Step 2b)
   - Replace all `{{TOKENS}}` with collected values
2. Copy `~/Projects/Claude Templates/templates/engineering/product/.claude/settings.json` → `<project>/.claude/settings.json`
   - Add any project-specific tool permissions
3. Create `<project>/ports/.gitkeep`
4. Install hooks:
   ```bash
   cd <project>
   ~/Projects/Claude\ Templates/standards/hooks/git/install-hooks.sh
   ~/Projects/Claude\ Templates/standards/hooks/versioning/install-hooks.sh
   ```

### 3b-b. Sub-repos and wiki

Same as Step 3b and 3c in Step 3 above (each sub-repo gets its own engineering template), plus:
- Copy `~/Projects/Claude Templates/templates/wiki/Endpoints.md` → `<wiki-repo>/Endpoints.md`

---

## Step 4 — Operator Setup

Follow these steps for a scheduled/automated agent repo. Skip to Step 5 if using a different template type.

### 4a. Copy template files

```bash
cp ~/Projects/Claude\ Templates/templates/operator/CLAUDE.md        <repo>/CLAUDE.md
cp ~/Projects/Claude\ Templates/templates/operator/guidelines.md    <repo>/guidelines.md
cp ~/Projects/Claude\ Templates/templates/operator/state.json       <repo>/state.json
mkdir -p <repo>/.github/workflows <repo>/.github/scripts
cp ~/Projects/Claude\ Templates/templates/operator/.github/workflows/operator.yml   <repo>/.github/workflows/operator.yml
cp ~/Projects/Claude\ Templates/templates/operator/.github/scripts/fetch-data.sh   <repo>/.github/scripts/fetch-data.sh
chmod +x <repo>/.github/scripts/fetch-data.sh
```

### 4b. Replace all tokens

Replace `{{AGENT_NAME}}`, `{{SCHEDULE}}`, `{{TRIGGER_DESCRIPTION}}`, `{{DATA_SOURCES}}`, and `{{OUTPUT_DESCRIPTION}}` in:
- `CLAUDE.md`
- `guidelines.md`
- `.github/workflows/operator.yml`
- `.github/scripts/fetch-data.sh`

### 4c. Fill in the TODOs

- **`fetch-data.sh`** — replace the example `gh api` call with real data fetching for this agent
- **`guidelines.md`** — fill in tone, format, length, inclusion/exclusion rules, and output naming
- **`CLAUDE.md` skip guard** — define the condition under which the agent should do nothing (no new data, nothing to report, etc.)

### 4d. Add GitHub secret

In the GitHub repo settings, add a repository secret:
- Name: `ANTHROPIC_API_KEY`
- Value: your Anthropic API key

The `GITHUB_TOKEN` is provided automatically by GitHub Actions.

---

## Step 5 — GitHub Setup

1. Create the GitHub repository (or repositories for multi-repo projects)
2. Push an initial commit to establish `main`
3. Create a **GitHub Project V2** board:
   - Columns: `Backlog`, `IDEA`, `PLAN`, `DEV`, `TEST`, `DONE`
   - Fields: `Priority`, `Categories`, `Time Estimate`, `Complexity`, `Score`
4. Note the Project V2 number from the board URL (`/projects/<number>`) — go back and fill in `{{PROJECT_NUMBER}}` in CLAUDE.md
5. Enable GitHub Actions if drift detection is needed

---

## Step 6 — Register as a Consumer

Add the new project to `~/Projects/Claude Templates/consumers.json`:

```json
{
  "repo": "bh679/{{PROJECT_SLUG}}",
  "template": "engineering/product",
  "claude_md_path": "CLAUDE.md",
  "description": "{{PROJECT_NAME}} — short description"
}
```

Commit and push:

```bash
cd ~/Projects/Claude\ Templates
git add consumers.json
git commit -m "chore: add {{PROJECT_SLUG}} to consumers.json"
git push
```

---

## Step 7 — Install Skills and Hooks

### Skills (one-time per developer machine)

If skills are not yet installed on this machine:

```bash
cd ~/Projects/Claude\ Templates
./install-skills.sh
```

Verify `trigger-blog` appears in the Claude skill list.

### Hooks (once per repo)

Each standard has its own installer. Run only the ones relevant to the template:

| Standard | Installer | Templates that use it |
|---|---|---|
| git.md | `standards/hooks/git/install-hooks.sh` | engineering/product, engineering/backend |
| versioning.md | `standards/hooks/versioning/install-hooks.sh` | engineering/product, engineering/backend |

Run from each repo root:

```bash
cd <repo>
~/Projects/Claude\ Templates/standards/hooks/git/install-hooks.sh
~/Projects/Claude\ Templates/standards/hooks/versioning/install-hooks.sh
```

Or install all standards at once:

```bash
cd <repo> && ~/Projects/Claude\ Templates/standards/hooks/install-hooks.sh
```

Claude Code hooks are symlinked — updates propagate automatically. Git hooks are copied — re-run to pick up future changes.

---

## Step 8 — Verify Setup

### Engineering checklist

- [ ] No literal `{{INCLUDE:` tokens remaining (all includes resolved)
- [ ] No literal `{{STANDARD:` tokens remaining in CLAUDE.md or `.claude/gates/` files
- [ ] No literal `{{` value tokens remaining in any CLAUDE.md file
- [ ] Standards version comments are present (e.g. `<!-- standard: git | version: 1.0.0 -->`)
- [ ] `npm install` completed in orchestrator repo (product only)
- [ ] `tests/` and `ports/` directories exist with `.gitkeep` (product only)
- [ ] GitHub repo created and initial commit pushed
- [ ] GitHub Project V2 board exists with correct columns and fields
- [ ] `{{PROJECT_NUMBER}}` filled in with the actual project number
- [ ] Project registered in `~/Projects/Claude Templates/consumers.json`
- [ ] Skills installed (`trigger-blog` available)
- [ ] Hooks installed in orchestrator repo (`.claude/hooks/git/` symlink exists, `.git/hooks/pre-commit` exists)
- [ ] Hooks installed in each sub-repo

### Operator checklist

- [ ] No literal `{{` tokens remaining in any file
- [ ] All TODOs resolved in `fetch-data.sh`, `guidelines.md`, and `CLAUDE.md` skip guard
- [ ] `ANTHROPIC_API_KEY` secret added to GitHub repo settings
- [ ] GitHub repo created and initial commit pushed
- [ ] Workflow runs successfully via `workflow_dispatch` before relying on the schedule
- [ ] Project registered in `~/Projects/Claude Templates/consumers.json`

---

## Error Handling

- **Template type not specified:** Ask the user before proceeding
- **Token value unknown:** Ask the user — do not guess or use placeholder values
- **`gh` CLI not authenticated:** Run `gh auth status` and guide the user through login
- **Template file missing:** Verify the claude-templates repo is up to date (`git pull`)
- **`npm install` fails:** Show the error and let the user resolve dependency issues

## Output Format

After completing all steps, report a summary:

```
New project setup complete

Project: {{PROJECT_NAME}}
Template: Engineering Product | Engineering Backend | Operator | None
Repos created: {{list}}
Consumer registered: Yes / No
Skills installed: Yes / No
Verification: All checks passed / Issues found (list)
```
