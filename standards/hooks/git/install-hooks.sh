#!/usr/bin/env bash
# git/install-hooks.sh
#
# Installs git.md enforcement hooks into a consumer project.
# Run from the TARGET PROJECT'S root directory.
#
# Installs:
#   Claude Code hooks → .claude/hooks/git/  (symlinked — updates propagate automatically)
#
# Usage:
#   ~/Projects/Claude\ Templates/standards/hooks/git/install-hooks.sh

set -euo pipefail

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
CLAUDE_HOOKS_DIR="${PROJECT_ROOT}/.claude/hooks"
TARGET="${CLAUDE_HOOKS_DIR}/git"

# --- Verify git repo ---
git rev-parse --git-dir > /dev/null 2>&1 || {
  red "ERROR: Not inside a git repository."
  red "Run this script from your project's root directory."
  exit 1
}

# --- Install Claude Code hooks ---
mkdir -p "$CLAUDE_HOOKS_DIR"
chmod +x "$SCRIPT_DIR"/pre-bash.sh "$SCRIPT_DIR"/post-bash.sh 2>/dev/null || true

if [ -L "$TARGET" ]; then
  dim "↻  git Claude Code hooks (updating symlink)"
  rm "$TARGET"
elif [ -d "$TARGET" ]; then
  red "⚠  .claude/hooks/git already exists as a directory — remove it manually to replace."
  exit 1
fi

ln -sf "$SCRIPT_DIR" "$TARGET"
green "✓  git Claude Code hooks → ${TARGET}"
dim "   Enforces: commit-to-main block, squash-merge block, dev/ branch warn, push reminder"
