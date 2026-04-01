# Templates Curator

You are the **Templates Curator** for `bh679/claude-templates`.
This repo is the canonical home for workflow standards, copy-once templates,
and installable skills used across all of Brennan's Claude-powered projects.

## This Repo Contains

| Directory | What it is | How it's consumed |
|---|---|---|
| `rules/` | Always-loaded constraints (git, versioning, workflow, coding style, security) | Auto-loaded into every Claude conversation via `~/.claude/rules/` symlink |
| `playbooks/` | On-demand procedures and references (gates, testing, http-diagnostics, etc.) | Symlinked to `~/.claude/playbooks/`, read when needed |
| `templates/engineering/product/` | Product engineer starting point (4-gate workflow) | Copied into new projects once, tokens filled in |
| `templates/engineering/backend/` | Backend engineer starting point (4-gate + backend checklist) | Copied into new projects once, tokens filled in |
| `templates/operator/` | Operator starting point (scheduled autonomous agent) | Copied into new operator projects once, tokens filled in |
| `skills/` | Installable Claude skills (SKILL.md format) | Symlinked into `~/.claude/skills/<name>/` |

---

## Working in This Repo

### Updating a Rule or Playbook

Rules and playbooks are versioned and may be embedded in consumer projects. When you change one:
1. Update the canonical doc in `rules/` or `playbooks/`
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
7. Run `./install.sh` to (re)install all skills and playbooks via symlinks

### Adding a Consumer Repo

1. Add an entry to `consumers.json`
2. The drift-detection GitHub Action will start monitoring it on the next weekly run

---

## Bootstrapping a New Project

See `templates/README.md` for the full checklist. Quick version:
1. Copy `templates/engineering/product/CLAUDE.md` (or `backend/`)
2. Resolve `{{INCLUDE:...}}` tokens (inline shared content)
3. Resolve `{{STANDARD:...}}` tokens (inline versioned standards from `rules/` and `playbooks/`)
4. Fill in `{{VALUE}}` tokens
5. Copy `.claude/settings.json`, `playwright.config.js`, `package.json`
6. For each sub-repo: copy the appropriate engineering template (`product/` or `backend/`), resolve tokens
7. For each wiki repo: copy `templates/wiki/` contents
8. Run `./install.sh` on the developer's machine (installs skills + playbooks)

---

## Standards

This repo dogfoods its own standards. Read the canonical source files — do NOT duplicate their content here.

### Rules (always loaded)

| Standard | Source | What it covers |
|---|---|---|
| Workflow | [`rules/development-workflow.md`](rules/development-workflow.md) | Four-gate approval process |
| Git | [`rules/git.md`](rules/git.md) | Branch naming, commits, merge strategy, cleanup |
| Versioning | [`rules/versioning.md`](rules/versioning.md) | SemVer bumps, tags, rollback |
| Coding Style | [`rules/coding-style.md`](rules/coding-style.md) | Immutability, file organization, error handling |
| Security | [`rules/security.md`](rules/security.md) | Security checklist, secret management |

### Playbooks (read on demand)

| Playbook | Source | When to read |
|---|---|---|
| Gate 1 — Plan | [`playbooks/gates/gate-1-plan.md`](playbooks/gates/gate-1-plan.md) | Entering Gate 1 |
| Gate 2 — Test | [`playbooks/gates/gate-2-test.md`](playbooks/gates/gate-2-test.md) | Entering Gate 2 |
| Gate 3 — Merge | [`playbooks/gates/gate-3-merge.md`](playbooks/gates/gate-3-merge.md) | Entering Gate 3 |
| Session Review | [`playbooks/gates/session-review.md`](playbooks/gates/session-review.md) | Entering Gate 4 |
| HTTP Diagnostics | [`playbooks/http-diagnostics.md`](playbooks/http-diagnostics.md) | Building HTTP backends |
| Wiki Writing | [`playbooks/wiki-writing.md`](playbooks/wiki-writing.md) | Writing/editing wiki pages |
| Testing | [`playbooks/testing.md`](playbooks/testing.md) | Writing tests |
| Unit Testing | [`playbooks/unit-testing.md`](playbooks/unit-testing.md) | Writing unit tests |
| Agents | [`playbooks/agents.md`](playbooks/agents.md) | Orchestrating sub-agents |
| Patterns | [`playbooks/patterns.md`](playbooks/patterns.md) | Planning implementations |
| Port Management | [`playbooks/port-management.md`](playbooks/port-management.md) | Starting dev servers |
| Project Board | [`playbooks/project-board.md`](playbooks/project-board.md) | Managing board items |
| Hooks | [`playbooks/hooks.md`](playbooks/hooks.md) | Configuring hooks |
| Performance | [`playbooks/performance.md`](playbooks/performance.md) | Performance optimization |
| Operator | [`playbooks/operator.md`](playbooks/operator.md) | Building operator agents |
