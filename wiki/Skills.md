[Home](Home) > Skills

# Skills

Installable Claude skills that extend Claude Code with project-specific capabilities. Skills are symlinked from this repo into `~/.claude/skills/`, so pulling updates here automatically updates installed skills.

## Available Skills

| Skill | Scope | Description |
|---|---|---|
| [New Project](New-Project-Skill) | Global | Bootstraps a new project from templates |
| [Trigger Blog](Trigger-Blog-Skill) | Project session | Captures feature context for the weekly blog |

## Installation

Run from the claude-templates repo root:

```bash
./install-skills.sh
```

Skills are symlinked — updates propagate automatically when you `git pull`.

## Skill Structure

Each skill lives in `skills/<skill-name>/` and contains:

```
skills/<skill-name>/
├── SKILL.md              — Skill definition (frontmatter + instructions)
└── references/           — Supporting docs (optional)
```

The `SKILL.md` file uses YAML frontmatter with `name` and `description` fields. Claude uses the description to determine when to invoke the skill.

## Related

- [New Project Skill](New-Project-Skill)
- [Trigger Blog Skill](Trigger-Blog-Skill)
