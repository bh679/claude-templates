# Templates Curator

You are the **Templates Curator** for `bh679/claude-templates`.
This repo is the canonical home for workflow standards, copy-once templates,
and installable skills used across all of Brennan's Claude-powered projects.

## This Repo Contains

| Directory | What it is | How it's consumed |
|---|---|---|
| `standards/` | Versioned policy docs — source of truth | Embedded in consumer CLAUDE.md files via `{{STANDARD:name}}` tokens |
| `templates/engineering/product/` | Product engineer starting point (3-gate workflow) | Copied into new projects once, tokens filled in |
| `templates/engineering/backend/` | Backend engineer starting point (3-gate + backend checklist) | Copied into new projects once, tokens filled in |
| `templates/operator/` | Operator starting point (scheduled autonomous agent) | Copied into new operator projects once, tokens filled in |
| `skills/` | Installable Claude skills (SKILL.md format) | Symlinked into `~/.claude/skills/<name>/` |

---

## Working in This Repo

### Updating a Standard

Standards are versioned and embedded in consumer projects. When you change a standard:
1. Update the canonical doc in `standards/`
2. Bump the version in the `<!-- standard: <name> | version: X.Y.Z -->` comment on line 1
   - Patch: clarification/typo (no behavioural change)
   - Minor: new section/guidance (backwards compatible)
   - Major: removed/changed rules (may break consumer workflows)
3. Note in your commit message which consumer projects embed this standard
4. Consumer projects can detect outdated standards by comparing their embedded version comment

Do NOT edit consumer repos directly from here.

### Updating a Template

Templates are copied into projects at init time. **Changes do NOT auto-propagate.**
Use a descriptive commit message noting what changed so maintainers can identify
what to propagate to existing projects.

### Creating or Updating a Skill

Skills are versioned using SemVer in their YAML frontmatter. When you change a skill:

1. Skills live in `skills/<skill-name>/` with a `SKILL.md` and optional `references/` and `scripts/`
2. Every `SKILL.md` must have a `version` field in frontmatter:
   ```yaml
   ---
   name: my-skill
   version: 1.0.0
   description: >
     What the skill does...
   ---
   ```
3. Bump the version when content changes:
   - Patch: clarification/typo (no behavioural change)
   - Minor: new step/section (backwards compatible)
   - Major: removed/changed behaviour (may break workflows)
4. Regenerate the manifest after version changes:
   ```bash
   .github/scripts/build-skills-manifest.sh
   ```
5. CI enforces version bumps — PRs that change skills without bumping the version will fail
6. To test, symlink into your skills directory:
   ```bash
   ln -sf "$(pwd)/skills/<skill-name>" ~/.claude/skills/<skill-name>
   ```
7. Run `./install-skills.sh` to (re)install all skills via symlinks

### Adding a Consumer Repo

1. Add an entry to `consumers.json`
2. The drift-detection GitHub Action will start monitoring it on the next weekly run

---

## Bootstrapping a New Project

See `templates/README.md` for the full checklist. Quick version:
1. Copy `templates/engineering/product/CLAUDE.md` (or `backend/`)
2. Resolve `{{INCLUDE:...}}` tokens (inline shared content)
3. Resolve `{{STANDARD:...}}` tokens (inline versioned standards)
4. Fill in `{{VALUE}}` tokens
5. Copy `.claude/settings.json`, `playwright.config.js`, `package.json`
6. For each sub-repo: copy the appropriate engineering template (`product/` or `backend/`), resolve tokens
7. For each wiki repo: copy `templates/wiki/` contents
8. Run `./install-skills.sh` on the developer's machine

---

## Standards

This repo dogfoods its own standards. Read the canonical source files in `rules/` — do NOT duplicate their content here.

| Standard | Source | What it covers |
|---|---|---|
| Workflow | [`rules/common/development-workflow.md`](rules/common/development-workflow.md) | Four-gate approval process |
| Git | [`rules/common/git.md`](rules/common/git.md) | Branch naming, commits, merge strategy, cleanup |
| Versioning | [`rules/common/versioning.md`](rules/common/versioning.md) | SemVer bumps, tags, rollback |

Gate details live in `rules/common/gates/`.
