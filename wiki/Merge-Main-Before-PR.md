[Home](Home) > [Features](Features) > Merge-Main-Before-PR Enforcement

# Merge-Main-Before-PR Enforcement

Hook-based enforcement that blocks PR creation when the feature branch is behind main.

## How It Works

The `pre-bash.sh` Claude Code hook intercepts `gh pr create` commands and checks whether the current branch includes all commits from main. If the branch is behind, it blocks the PR creation and instructs the agent to merge main first.

This prevents merge conflicts from appearing after PR creation and ensures all PRs are based on the latest main.

## Technical Notes

- Enforced via the git standard's pre-bash hook
- Part of the Gate 3 workflow: ensure branch is up to date before creating PR
- The hook provides a clear error message with the remediation command

## Related

- [Git Standards](Git-Standards)
- [Enforceable Hooks](Enforceable-Hooks)
- [Three-Gate Workflow](Three-Gate-Workflow)
