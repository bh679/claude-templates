# New Project Setup

> Operational manual for bootstrapping a new Brennan Hatton project using claude-templates.
> Referenced by `~/.claude/CLAUDE.md`.

---

## Step 1 — Choose a Template Type

Ask the user which template type applies if not already specified:

| Type | When to use |
|---|---|
| **Product Engineer** | Multi-repo project (client + API + wiki). Full 3-gate workflow. |
| **Operator** | Scheduled or automated agent. Single-repo. |
| **Repo** | Individual sub-repo within an existing Product Engineer project. |
| **None** | Plain repo — no Claude workflow templates needed. |

---

## Step 2 — Gather Token Values

Before copying any files, collect values for all tokens:

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

---

## Step 3 — Product Engineer Setup

Follow all sub-steps in order. Skip to the relevant step if using a different template type.

### 3a. Orchestrator repo

1. Copy `~/Projects/Claude Templates/templates/product-engineer/CLAUDE.md` → `<project>/CLAUDE.md`
   - Replace all `{{TOKENS}}` with collected values
2. Copy `~/Projects/Claude Templates/templates/product-engineer/.claude/settings.json` → `<project>/.claude/settings.json`
3. Copy `~/Projects/Claude Templates/templates/product-engineer/playwright.config.js` → `<project>/playwright.config.js`
4. Copy `~/Projects/Claude Templates/templates/product-engineer/package.json` → `<project>/package.json`
   - Update the `name` field to `{{PROJECT_SLUG}}`
   - Run `npm install`
5. Create placeholder directories:
   ```bash
   mkdir -p <project>/tests && touch <project>/tests/.gitkeep
   mkdir -p <project>/ports && touch <project>/ports/.gitkeep
   ```

### 3b. Sub-repos (repeat for each: client, API, etc.)

1. Copy `~/Projects/Claude Templates/templates/repo/CLAUDE.md` → `<sub-repo>/CLAUDE.md`
2. Replace all `{{TOKENS}}`

### 3c. Wiki repo (repeat for each wiki)

1. Copy `~/Projects/Claude Templates/templates/wiki/CLAUDE.md` → `<wiki-repo>/CLAUDE.md`
2. Copy `~/Projects/Claude Templates/templates/wiki/Home.md` → `<wiki-repo>/Home.md`
3. Copy `~/Projects/Claude Templates/templates/wiki/Features.md` → `<wiki-repo>/Features.md`
4. Replace all `{{TOKENS}}` in each file

---

## Step 4 — Operator Setup

No template exists yet for Operator. Set up as a plain repo and flag `templates/operator/` as a future addition to claude-templates.

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
  "template": "product-engineer",
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

## Step 7 — Install Skills (one-time per developer machine)

If skills are not yet installed on this machine:

```bash
cd ~/Projects/Claude\ Templates
./install-skills.sh
```

Verify `trigger-blog` appears in the Claude skill list.

---

## Step 8 — Verify Setup

Run through this checklist before the first feature session:

- [ ] No literal `{{` tokens remaining in any CLAUDE.md file
- [ ] `npm install` completed in orchestrator repo
- [ ] `tests/` and `ports/` directories exist with `.gitkeep`
- [ ] GitHub repo created and initial commit pushed
- [ ] GitHub Project V2 board exists with correct columns and fields
- [ ] `{{PROJECT_NUMBER}}` filled in with the actual project number
- [ ] Project registered in `~/Projects/Claude Templates/consumers.json`
- [ ] Skills installed (`trigger-blog` available)

---

## Reference

| Resource | Path |
|---|---|
| Templates | `~/Projects/Claude Templates/templates/` |
| Standards | `~/Projects/Claude Templates/standards/` |
| Skills | `~/Projects/Claude Templates/skills/` |
| Workflow standard | `~/Projects/Claude Templates/standards/workflow.md` |
| Git standard | `~/Projects/Claude Templates/standards/git.md` |
| Versioning standard | `~/Projects/Claude Templates/standards/versioning.md` |
| Wiki writing standard | `~/Projects/Claude Templates/standards/wiki-writing.md` |
