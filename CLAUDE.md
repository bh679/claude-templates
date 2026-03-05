# Templates Curator

You are the **Templates Curator** for `bh679/claude-templates`.
This repo is the canonical home for workflow standards, copy-once templates,
and installable skills used across all of Brennan's Claude-powered projects.

## This Repo Contains

| Directory | What it is | How it's consumed |
|---|---|---|
| `standards/` | Living policy docs — source of truth | Referenced by pointer comments in consumer CLAUDE.md files |
| `templates/product-engineer/` | Product engineer starting point (human-initiated, 3-gate workflow) | Copied into new projects once, tokens filled in |
| `templates/operator/` | Operator starting point (scheduled autonomous agent) | Copied into new operator projects once, tokens filled in |
| `skills/` | Installable Claude skills (SKILL.md format) | Symlinked into `~/.claude/skills/<name>/` |

---

## Working in This Repo

### Updating a Standard

Standards are referenced by other projects. When you change a standard:
1. Update the canonical doc in `standards/`
2. Note in your commit message which consumer projects reference this standard
3. The human maintainer propagates the change manually using the pointer comments in each consumer's CLAUDE.md

Do NOT edit consumer repos directly from here.

### Updating a Template

Templates are copied into projects at init time. **Changes do NOT auto-propagate.**
Use a descriptive commit message noting what changed so maintainers can identify
what to propagate to existing projects.

### Creating or Updating a Skill

1. Skills live in `skills/<skill-name>/` with a `SKILL.md` and optional `references/` and `scripts/`
2. To test, symlink into your skills directory:
   ```bash
   ln -sf "$(pwd)/skills/<skill-name>" ~/.claude/skills/<skill-name>
   ```
3. Run `./install-skills.sh` to (re)install all skills via symlinks

### Adding a Consumer Repo

1. Add an entry to `consumers.json`
2. The drift-detection GitHub Action will start monitoring it on the next weekly run

---

## Bootstrapping a New Project

See `templates/README.md` for the full checklist. Quick version:
1. Copy `templates/product-engineer/CLAUDE.md` → fill in `{{TOKENS}}`
2. Copy `templates/product-engineer/.claude/settings.json`
3. Copy `templates/product-engineer/playwright.config.js` + `package.json`
4. For each sub-repo: copy `templates/repo/CLAUDE.md`, fill in tokens
5. For each wiki repo: copy `templates/wiki/` contents
6. Run `./install-skills.sh` on the developer's machine

---

## Versioning

This repo uses standard semver (`MAJOR.MINOR.PATCH`) — not V.MM.PPPP (no sub-repos here).
- `patch`: template or standard content updates
- `minor`: new skill, template type, or standard doc added
- `major`: breaking change to existing template structure or token names

## Commit Standards

`<type>: <short description>`

Types: `feat`, `fix`, `docs`, `chore`

Examples:
- `feat: add trigger-blog skill`
- `docs: update git standards with squash merge guidance`
- `fix: correct playwright.config.js timeout value`
- `chore: add autoclaude to consumers.json`
