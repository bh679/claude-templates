---
name: apply-template
description: >
  Apply or update a claude-templates template to an existing project. Detects
  current template state, compares standards/hooks/settings against the latest
  versions, and walks the user through each change interactively. Use when the
  user says "apply template", "update template", "sync standards", "update
  CLAUDE.md", "update hooks", "check for template updates", or when drift
  detection has flagged the project as outdated.
---

# Apply Template

This skill applies or updates a claude-templates template to an existing project.
It detects what already exists, compares against the latest canonical versions,
and presents each difference **one at a time** for the user to approve or skip.
Custom content is always preserved.

## When to Use

- Applying a template to a project that has never had one
- Updating an outdated project to the latest standards, hooks, and settings
- After drift detection flags a project as outdated
- When the user wants to sync their project with the latest template

## Pre-Check

Verify the `gh` CLI is authenticated:
```bash
gh auth status
```
If not authenticated, guide the user through `gh auth login`.

Ensure the claude-templates repo is available locally and up to date:
```bash
if [ -d ~/Projects/Claude\ Templates ]; then
  cd ~/Projects/Claude\ Templates && git pull
else
  echo "claude-templates repo not found. Clone it first:"
  echo "  gh repo clone bh679/claude-templates ~/Projects/Claude\ Templates"
fi
```

Record the target project root (the current working directory when the skill is invoked):
```bash
TARGET_ROOT="$(pwd)"
TEMPLATES_ROOT=~/Projects/Claude\ Templates
```

---

## Step 1 — Detect Current State

Scan the target project to understand what exists:

```bash
# Check for key files
ls -la CLAUDE.md 2>/dev/null
ls -la .claude/settings.json 2>/dev/null
ls -la .claude/hook-versions.json 2>/dev/null
ls -la .claude/hooks/ 2>/dev/null
ls -la .git/hooks/pre-commit 2>/dev/null

# Get the git remote to match against consumers.json
git remote get-url origin 2>/dev/null
```

From the remote URL, extract `owner/repo` and look it up in `consumers.json`:
```bash
jq '.[] | select(.repo == "<owner/repo>")' "$TEMPLATES_ROOT/consumers.json"
```

This tells you:
- **template** — the template type (e.g., `engineering/product`)
- **claude_md_path** — where CLAUDE.md lives
- Whether the project is registered at all

**If not found in consumers.json:** Ask the user which template type applies. List the available templates:
```bash
ls -d "$TEMPLATES_ROOT"/templates/engineering/*/  "$TEMPLATES_ROOT"/templates/operator/ "$TEMPLATES_ROOT"/templates/repo/ 2>/dev/null
```

**Classify the project state:**

| State | How to detect |
|---|---|
| **Greenfield** | No CLAUDE.md exists |
| **Partial** | CLAUDE.md exists but no `<!-- standard: ... | version: ... -->` comments |
| **Applied (possibly outdated)** | CLAUDE.md has standard version comments |

Read `~/.claude/skills/apply-template/references/template-components.md` to know exactly which files, standards, hooks, and settings each template type expects.

**If greenfield:** Proceed through Steps 2-10 as a first-time application — you will need to gather token values (see the `new-project` skill for the token reference) and resolve templates before copying.

---

## Step 2 — Compare Standards Versions

Extract embedded standard versions from the target CLAUDE.md:
```bash
grep '<!-- standard:.*version:' CLAUDE.md
```

Compare against the latest versions manifest:
```bash
cat "$TEMPLATES_ROOT/.github/scripts/standards-versions.json"
```

Build and present a comparison table to the user:

```
Standards Comparison:
  workflow        — installed: 1.1.0 → latest: 1.2.0  (MINOR update)
  git             — installed: 1.2.0 → latest: 1.2.0  (current)
  versioning      — installed: 1.0.0 → latest: 2.0.0  (MAJOR update)
  wiki-writing    — not found → latest: 1.1.0          (missing)
  port-management — not found → latest: 1.1.1          (missing)
```

Determine which standards should be present for this template type by consulting the template-components reference.

Note: Do NOT apply any changes yet. This step is information gathering only.

---

## Step 3 — Compare Hook Versions

Run the existing hook checker from the target project root:
```bash
cd "$TARGET_ROOT"
"$TEMPLATES_ROOT/standards/hooks/check-hooks.sh"
```

If `.claude/hook-versions.json` does not exist, report that no hooks are installed.

Present the results to the user. Note which hooks are outdated or missing.

---

## Step 4 — Compare settings.json

If `.claude/settings.json` exists in the target project, compare it against the template version:

```bash
# Read target settings
cat .claude/settings.json

# Read template settings (use the detected template type)
cat "$TEMPLATES_ROOT/templates/<template-type>/.claude/settings.json"
```

Identify and categorise differences:

| Category | Examples |
|---|---|
| **Missing from target (template has, target doesn't)** | Missing deny rules, missing hook configs |
| **User additions (target has, template doesn't)** | Custom permissions, custom hooks |
| **Matching** | Entries present in both |

If `.claude/settings.json` does not exist, note it as missing entirely.

---

## Step 5 — Update Standards in CLAUDE.md (Interactive)

**CRITICAL: Present each standard update ONE AT A TIME. Wait for user approval before proceeding to the next.**

### For each OUTDATED standard (version behind latest):

1. Read the latest standard content:
   ```bash
   cat "$TEMPLATES_ROOT/standards/<name>.md"
   ```

2. Present to the user:
   - Standard name and what it governs
   - Version change: `X.Y.Z → A.B.C`
   - Bump type: PATCH (clarification only), MINOR (new guidance, backwards compatible), or MAJOR (breaking changes)
   - For MAJOR bumps, add a warning: "This is a major version change that may affect your existing workflow."

3. Ask the user: **Update / Skip / Show diff**
   - If "Show diff": summarise the key changes between old and new version
   - If "Update": replace the standard block in CLAUDE.md (see Replacement Logic below)
   - If "Skip": move to the next standard

### For each MISSING standard (expected by template but not in CLAUDE.md):

1. Present to the user:
   - Standard name and what it covers (one sentence)
   - Version: `A.B.C` (new)

2. Ask the user: **Add / Skip**
   - If "Add": insert the standard at the appropriate location in CLAUDE.md
   - If "Skip": move to the next standard

### Replacement Logic

**If BEGIN/END markers exist** (pattern: `<!-- BEGIN STANDARD: name -->` ... `<!-- END STANDARD: name -->`):
- Replace everything between the markers with the new standard content
- This is the same logic as `scripts/sync-standards.sh`

**If only version comments exist** (pattern: `<!-- standard: name | version: X.Y.Z -->`):
- Find the version comment line
- The standard block runs from that line to the next `---` separator (a line that is exactly `---`)
- Replace that entire block (version comment through the line before `---`) with the new standard content
- Preserve the `---` separator

**For new standards being added:**
- Consult `templates/engineering/base.md` for the canonical ordering of standards
- Insert the new standard at the correct position relative to existing standards
- Add a `---` separator before and after

### Preserving Custom Content

- NEVER modify lines that are NOT inside a recognized standard block
- If you cannot confidently identify the standard block boundaries, show the user the surrounding context and ask them to confirm the boundaries before replacing

---

## Step 6 — Update Hooks (Interactive)

For each outdated or missing hook identified in Step 3:

1. Present to the user:
   - Hook name and file path (e.g., `git/pre-bash.sh`)
   - What it enforces (e.g., "Blocks commits to main, enforces squash merge")
   - Version change: `X.Y.Z → A.B.C` (or "not installed → A.B.C")

2. Ask the user: **Install/Update / Skip**

3. If approved, run the relevant installer:
   ```bash
   cd "$TARGET_ROOT"
   "$TEMPLATES_ROOT/standards/hooks/git/install-hooks.sh"
   ```
   Or for versioning hooks:
   ```bash
   "$TEMPLATES_ROOT/standards/hooks/versioning/install-hooks.sh"
   ```

Only run installers for hooks the user has approved. Each installer is idempotent.

---

## Step 7 — Update settings.json (Interactive)

**If settings.json is missing entirely:**

1. Show the user the template's settings.json content
2. Ask: **Create settings.json from template / Skip**
3. If approved: copy the template settings.json to `.claude/settings.json`

**If settings.json exists but differs:**

1. Compute a merged version:
   - `permissions.allow`: union of template and user entries (keep all)
   - `permissions.deny`: union of template and user entries (keep all — safety rules are additive)
   - `hooks`: for each hook event (PreToolUse, PostToolUse):
     - Template hook entries are canonical — ensure they are present
     - User-added hook entries with different matchers are preserved
     - If a user has a hook with the same matcher but different command, present both and ask which to keep

2. Present the proposed merged settings.json to the user
3. Highlight what would change:
   - New entries being added (from template)
   - User entries being preserved
   - Any conflicts requiring a choice

4. Ask: **Apply merged settings / Keep current settings / Edit manually**

5. If approved: write the merged settings.json

---

## Step 8 — Update Other Template Files (Interactive)

Check for other template-specific files that may need updating.

### For engineering/product:

| File | Check |
|---|---|
| `package.json` | Compare `devDependencies` (Playwright version) |
| `playwright.config.js` | Compare against template version |

### For engineering/backend:

| File | Check |
|---|---|
| `package.json` | Compare `devDependencies` if present |

### For operator:

| File | Check |
|---|---|
| `.github/workflows/operator.yml` | Compare workflow structure (not data-specific values) |
| `.github/scripts/fetch-data.sh` | Check if it exists (don't overwrite — project-specific) |
| `state.json` | Check if it exists (don't overwrite — contains runtime state) |
| `guidelines.md` | Check if it exists (don't overwrite — project-specific) |

For each file that differs from the template:
1. Show what the template version contains vs what the project has
2. Ask: **Update / Keep existing / Show diff**
3. If "Update": replace the file
4. If "Keep existing": move on

**Never overwrite files that contain project-specific data** (state.json, guidelines.md, fetch-data.sh) unless the user explicitly requests it. For these files, only flag if they are missing entirely and offer to create from template.

---

## Step 9 — Register in consumers.json

Check if the project is registered:
```bash
REPO=$(git remote get-url origin | sed 's|.*github.com[:/]||;s|\.git$||')
jq --arg repo "$REPO" '.[] | select(.repo == $repo)' "$TEMPLATES_ROOT/consumers.json"
```

**If not registered:**

1. Ask: "Register this project in consumers.json for weekly drift detection?"
2. If approved, construct the entry:

   For engineering templates:
   ```json
   {
     "repo": "<owner/repo>",
     "template": "<template-type>",
     "claude_md_path": "CLAUDE.md",
     "description": "<ask user for one-line description>"
   }
   ```

   For operator templates:
   ```json
   {
     "repo": "<owner/repo>",
     "template": "operator",
     "description": "<ask user for one-line description>",
     "required_files": ["<list files from the operator's directory>"]
   }
   ```

3. Add to consumers.json, commit, and push:
   ```bash
   cd "$TEMPLATES_ROOT"
   # Edit consumers.json to add the new entry
   git add consumers.json
   git commit -m "chore: register <repo-slug> in consumers.json"
   git push
   cd "$TARGET_ROOT"
   ```

**If already registered:** Skip this step. Optionally verify the entry is still accurate.

---

## Step 10 — Verify and Report

Run verification checks:

```bash
# Check for unresolved tokens (should be none after applying)
grep -rn '{{' CLAUDE.md | grep -v '<!--' | grep -v 'example' || echo "No unresolved tokens"

# Verify standard version comments are present
grep '<!-- standard:.*version:' CLAUDE.md

# Check hook status
cd "$TARGET_ROOT"
"$TEMPLATES_ROOT/standards/hooks/check-hooks.sh" 2>/dev/null || echo "Hook check skipped"

# Validate settings.json
jq . .claude/settings.json > /dev/null 2>&1 && echo "settings.json: valid JSON" || echo "settings.json: invalid or missing"
```

Present a summary report:

```
Apply-Template Summary for <project-name>
==========================================
Template type: engineering/product

Standards:
  workflow        1.1.0 → 1.2.0    UPDATED
  git             1.2.0             current
  versioning      1.0.0 → 2.0.0    UPDATED
  wiki-writing    (new)   1.1.0     ADDED
  port-management (new)   1.1.1     SKIPPED (user choice)

Hooks:
  git/pre-bash.sh         1.0.0     UPDATED
  git/post-bash.sh        1.0.0     INSTALLED (new)
  versioning/pre-commit   1.0.0     current

Settings:
  .claude/settings.json              MERGED (2 deny rules added)

Other Files:
  package.json                       UPDATED (Playwright 1.48 → 1.50)
  playwright.config.js               current

Registration:
  consumers.json                     Already registered

Verification: All checks passed
```

---

## Error Handling

- **Template repo not found:** Guide user to clone: `gh repo clone bh679/claude-templates ~/Projects/Claude\ Templates`
- **Template repo out of date:** `git pull` was run in Pre-Check; if it fails, warn the user
- **No recognizable standard blocks in CLAUDE.md:** Treat as partial application; offer to rebuild standards section from template
- **Cannot determine standard block boundaries:** Show surrounding context, ask user to confirm before replacing
- **User declines all updates:** Report "No changes applied" and exit gracefully
- **settings.json merge conflict:** Present both versions side by side, let user choose
- **Git remote not set:** Ask user for the `owner/repo` slug manually
