# Claude Templates

Canonical home for workflow standards, project templates, and installable Claude skills used across Brennan's Claude-powered development projects.

## What's Here

| Directory | Purpose |
|---|---|
| [`standards/`](standards/) | Living policy docs — source of truth for git, versioning, workflow, and wiki conventions |
| [`templates/`](templates/) | Copy-once starting points for new projects (product engineer, sub-repos, wikis) |
| [`skills/`](skills/) | Installable Claude skills — symlink into `~/.claude/skills/` |

## Quick Start: Bootstrap a New Project

Use the `/new-project` skill, or see [`standards/new-project-setup.md`](standards/new-project-setup.md) for the full manual.

## Install Skills

```bash
git clone https://github.com/bh679/claude-templates.git
cd claude-templates
./install-skills.sh
```

Skills are symlinked from this repo into `~/.claude/skills/`, so pulling updates here automatically updates your installed skills.

## Available Skills

| Skill | Scope | Description |
|---|---|---|
| `new-project` | Global | Bootstraps a new project from claude-templates — template selection, file copying, GitHub setup, and verification |
| `trigger-blog` | Project session | Auto-captures feature context when you ship and queues it for the weekly-blog agent |

All skills install to `~/.claude/skills/` and are globally available. The **Scope** column indicates when each skill is typically useful:

- **Global** — useful from any context, including outside of any project
- **Project session** — useful during an active project session

## Standards Docs

| Doc | Covers |
|---|---|
| [`standards/workflow.md`](standards/workflow.md) | 3-gate approval workflow, plan mode, session management |
| [`standards/git.md`](standards/git.md) | Branch naming, commit messages, worktree procedure |
| [`standards/versioning.md`](standards/versioning.md) | V.MM.PPPP scheme, bump rules, tag conventions |
| [`standards/wiki-writing.md`](standards/wiki-writing.md) | Prose style, link rules, image naming for wikis |
| [`standards/new-project-setup.md`](standards/new-project-setup.md) | Full project bootstrapping manual (used by the `new-project` skill) |

## Consumer Projects

Projects using these templates and standards:
- [chess-project](https://github.com/bh679/chess-project)

(See [`consumers.json`](consumers.json) for the full list monitored by drift detection.)
