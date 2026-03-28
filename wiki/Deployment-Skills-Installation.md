[Home](Home) > [Deployment](Deployment) > Skills Installation

# Deployment — Skills Installation

Install Claude skills globally on a developer machine by symlinking from the claude-templates repo.

## Prerequisites

- Git installed
- Claude Code CLI installed
- Clone of the claude-templates repo at `~/Projects/Claude Templates/`

## Deployment Procedure

1. Clone the repo (if not already done):
   ```bash
   git clone https://github.com/bh679/claude-templates.git ~/Projects/Claude\ Templates
   ```

2. Run the installer:
   ```bash
   cd ~/Projects/Claude\ Templates
   ./install-skills.sh
   ```

3. Verify skills appear in Claude:
   - `/new-project` should be available
   - `/trigger-blog` should be available

## How It Works

The `install-skills.sh` script symlinks each skill directory from `skills/<name>/` to `~/.claude/skills/<name>/`. Because they are symlinks, pulling updates to the repo automatically updates the installed skills.

## Rollback Procedure

1. Remove the symlinks:
   ```bash
   rm ~/.claude/skills/new-project
   rm ~/.claude/skills/trigger-blog
   ```

2. Re-run the installer if you want to restore them.

## Health Check

- Verify symlinks exist: `ls -la ~/.claude/skills/`
- Verify skills load: start a Claude session and check skill list

## Related

- [Deployment-Hooks-Installation](Deployment-Hooks-Installation)
- [Skills](Skills)
