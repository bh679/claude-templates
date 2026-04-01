[Home](Home) > [Deployment](Deployment) > Hooks Installation

# Deployment — Hooks Installation

Install enforcement hooks into a consumer project. Run once per project after bootstrapping.

## Prerequisites

- Consumer project bootstrapped from a claude-templates template
- Clone of claude-templates at `~/Projects/Claude Templates/`

## Deployment Procedure

1. Navigate to the consumer project root:
   ```bash
   cd <project-root>
   ```

2. Install per-standard hooks:
   ```bash
   ~/Projects/Claude\ Templates/hooks/git/install-hooks.sh
   ~/Projects/Claude\ Templates/hooks/versioning/install-hooks.sh
   ```

   Or install all at once:
   ```bash
   ~/Projects/Claude\ Templates/hooks/install-hooks.sh
   ```

3. Add Claude Code hook config to `.claude/settings.json` (see hooks README for the JSON snippet)

## How It Works

- **Claude Code hooks** (git standard) are symlinked to `.claude/hooks/` — updates propagate automatically
- **Git hooks** (versioning standard) are copied to `.git/hooks/` — re-run installer to pick up updates
- Installed versions are tracked in `.claude/hook-versions.json`

## Health Check

- Verify Claude Code hooks: `ls -la .claude/hooks/git/`
- Verify git hooks: `ls -la .git/hooks/pre-commit`
- Check for updates: `~/Projects/Claude\ Templates/hooks/check-hooks.sh`

## Related

- [Deployment-Skills-Installation](Deployment-Skills-Installation)
- [Enforceable Hooks](Enforceable-Hooks)
- [Hook Versioning](Hook-Versioning)
