<!-- Engineering base — github.com/bh679/claude-templates/templates/engineering/base.md -->
<!-- Included at copy time via {{INCLUDE:engineering/base.md}} -->

## Standards

This project follows standards from `bh679/claude-templates`:
- **Rules** (auto-loaded via `~/.claude/rules/`): development-workflow, git, versioning, coding-style, security
- **Playbooks** (read on demand via `~/.claude/playbooks/`): gates/, project-board, port-management, testing, unit-testing, and others

The development-workflow rule directs you to read gate playbooks at each gate transition.
Those gate playbooks reference further playbooks as needed.

---

### Before ANY Implementation

1. Search project board for existing items
2. Enter plan mode (Gate 1)

---

## Key Rules Summary

- Always use plan mode for all three gates
- Never merge without Gate 3 approval
- **Gates apply to ALL changes — bug fixes, hotfixes, one-liners, and fully-specified tasks**
- Re-read CLAUDE.md at every gate
- Check for existing board items before creating
- **All work happens in a git worktree on a `dev/` branch — never the main checkout.** Create it at Gate 1, before any code
- Clean up worktrees and ports when done
- One feature per session
- Commit and push after every meaningful unit of work
