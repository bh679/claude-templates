#!/usr/bin/env bash
# hook-version: 1.1.0
# git/pre-bash.sh
HOOK_VERSION="1.1.0"
#
# Claude Code PreToolUse hook — enforces git.md standards before Bash tool executes.
#
# Rules enforced:
#   1. Block commits directly to main/master       (hard block — exit 1)
#   2. Block commits outside a git worktree        (hard block — exit 1)
#   3. Warn if new branch missing dev/ prefix      (soft warn — exit 0)
#   4. Block gh pr create if branch is behind main (hard block — exit 1)
#   5. Block gh pr merge without --squash          (hard block — exit 1)
#
# Rule 2 opt-outs: a `.claude/no-worktree` marker at the repo root exempts the whole
#       repo; CLAUDE_ALLOW_NON_WORKTREE=1 exempts a single command.
#
# Note: force push, reset --hard, and rm -rf are blocked via settings.json
#       deny permissions — no hook needed for those.
#
# Input: JSON on stdin with shape { "tool_name": "Bash", "tool_input": { "command": "..." } }

set -uo pipefail

# --- Helpers ---
red()  { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
warn() { printf '\033[1;33m%s\033[0m\n' "$*" >&2; }
dim()  { printf '\033[2m%s\033[0m\n' "$*" >&2; }

# --- Parse input ---
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# ── 1. Block commits directly to main ──────────────────────────────────────
if echo "$CMD" | grep -qE "^git commit"; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    red "BLOCKED: You are on '$BRANCH'."
    red "Direct commits to main are not allowed per git.md standards."
    dim ""
    dim "Create a feature worktree first:"
    dim "  git worktree add .claude/worktrees/<feature-slug> -b dev/<feature-slug>"
    exit 1
  fi
fi

# ── 2. Block commits outside a git worktree ────────────────────────────────
# git.md § Git Worktrees: all development happens in a worktree, never the main checkout.
# Detection: in a linked worktree, --git-dir points at .git/worktrees/<name> while
# --git-common-dir points at the shared .git. In a normal checkout the two are equal.
if echo "$CMD" | grep -qE "^git commit"; then
  GIT_DIR=$(git rev-parse --git-dir 2>/dev/null || echo "")
  if [ -n "$GIT_DIR" ]; then          # skip silently when not in a git repo
    COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null || echo "")
    TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    if [ "$GIT_DIR" = "$COMMON_DIR" ] \
       && [ "${CLAUDE_ALLOW_NON_WORKTREE:-0}" != "1" ] \
       && [ ! -f "${TOPLEVEL}/.claude/no-worktree" ]; then
      red "BLOCKED: You are committing from the main checkout, not a worktree."
      red "All development happens in a git worktree per git.md standards."
      dim ""
      dim "Create one and move your work there:"
      dim "  git worktree add .claude/worktrees/<feature-slug> -b dev/<feature-slug>"
      dim "  cd .claude/worktrees/<feature-slug>"
      dim ""
      dim "Opt out: touch .claude/no-worktree (whole repo)"
      dim "         CLAUDE_ALLOW_NON_WORKTREE=1 (this command only)"
      exit 1
    fi
  fi
fi

# ── 3. Warn if new branch doesn't use dev/ prefix ──────────────────────────
if echo "$CMD" | grep -qE "git (checkout|switch) -b "; then
  # Portable extraction — BSD grep (macOS) has no -P, so avoid lookbehind.
  BRANCH=$(echo "$CMD" | sed -n 's/.*-b  *\([^ ][^ ]*\).*/\1/p' | head -1)
  if [ -n "$BRANCH" ] && ! echo "$BRANCH" | grep -q "^dev/"; then
    warn "WARNING: Branch '$BRANCH' does not follow the dev/<feature-slug> naming convention."
    warn "Rename to: dev/$BRANCH"
    dim "See git.md — Branch Naming section."
    # Soft warn: exit 0 so Claude sees the warning but can still proceed
  fi
fi

# ── 4. Block PR creation if branch is behind main ────────────────────────
if echo "$CMD" | grep -q "gh pr create"; then
  # Fetch latest main silently
  git fetch origin main --quiet 2>/dev/null || true
  BEHIND=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
  if [ "$BEHIND" -gt 0 ]; then
    red "BLOCKED: Your branch is $BEHIND commit(s) behind origin/main."
    red "Merge main into your branch before creating a PR."
    dim ""
    dim "Run:"
    dim "  git fetch origin"
    dim "  git merge origin/main"
    dim "  # Resolve any conflicts, then push"
    exit 1
  fi
fi

# ── 5. Block PR merge without --squash ─────────────────────────────────────
if echo "$CMD" | grep -q "gh pr merge"; then
  if ! echo "$CMD" | grep -q -- "--squash"; then
    red "BLOCKED: PRs must be squash merged per git.md standards."
    red "Add --squash to your command."
    dim ""
    dim "Correct form:"
    dim "  gh pr merge <number> --squash --delete-branch"
    exit 1
  fi
fi

exit 0
