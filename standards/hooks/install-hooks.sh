#!/usr/bin/env bash
# install-hooks.sh
#
# Installs hooks from claude-templates/standards/hooks/ into a consumer project.
# Run from the TARGET PROJECT'S root directory.
#
# Installs two types of hooks:
#   1. Git hooks     → .git/hooks/          (triggered by git events)
#   2. Claude hooks  → .claude/hooks/       (triggered by Claude Code tool use)
#
# Claude hook subdirectories are symlinked so updates to claude-templates
# automatically propagate without re-running this script.
# Git hooks are copied (not symlinked) since .git/ is not committed.
#
# Usage:
#   ~/Projects/Claude\ Templates/standards/hooks/install-hooks.sh
#
# Or with a custom claude-templates path:
#   TEMPLATES_DIR=/path/to/claude-templates \
#     ~/Projects/Claude\ Templates/standards/hooks/install-hooks.sh

set -euo pipefail

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
blue()  { printf '\033[1;34m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"

# Verify we're in a git repo
GIT_DIR="$(git rev-parse --git-dir 2>/dev/null)" || {
  red "ERROR: Not inside a git repository."
  red "Run this script from your project's root directory."
  exit 1
}

echo ""
blue "Installing hooks from: $SCRIPT_DIR"
blue "Into project:          $PROJECT_ROOT"
echo ""

# ════════════════════════════════════════════════════════════════════
# 1. GIT HOOKS — copied into .git/hooks/
#    Each standard's folder may contain a git-hook-*.sh file.
#    The filename suffix maps to the git hook name:
#      git-hook-pre-commit.sh  →  .git/hooks/pre-commit
# ════════════════════════════════════════════════════════════════════
echo "── Git hooks ──────────────────────────────────────────────────"

HOOKS_DIR="${GIT_DIR}/hooks"
mkdir -p "$HOOKS_DIR"
INSTALLED_GIT=0

for standard_dir in "$SCRIPT_DIR"/*/; do
  standard_name="$(basename "$standard_dir")"
  for hook_script in "$standard_dir"git-hook-*.sh; do
    [ -f "$hook_script" ] || continue
    # Extract hook name from filename: git-hook-pre-commit.sh → pre-commit
    hook_name="$(basename "$hook_script" .sh | sed 's/^git-hook-//')"
    target="${HOOKS_DIR}/${hook_name}"

    if [ -f "$target" ]; then
      dim "  Backing up existing ${hook_name} → ${hook_name}.bak"
      cp "$target" "${target}.bak"
    fi

    cp "$hook_script" "$target"
    chmod +x "$target"
    green "  ✓  $standard_name/$hook_name"
    INSTALLED_GIT=$((INSTALLED_GIT + 1))
  done
done

[ "$INSTALLED_GIT" -eq 0 ] && dim "  (none found)"

# ════════════════════════════════════════════════════════════════════
# 2. CLAUDE CODE HOOKS — symlinked into .claude/hooks/<standard>/
#    Each standard's folder is symlinked so updates propagate live.
#    Claude hook scripts are named pre-bash.sh, post-bash.sh, etc.
# ════════════════════════════════════════════════════════════════════
echo ""
echo "── Claude Code hooks ──────────────────────────────────────────"

CLAUDE_HOOKS_DIR="${PROJECT_ROOT}/.claude/hooks"
mkdir -p "$CLAUDE_HOOKS_DIR"
INSTALLED_CLAUDE=0

for standard_dir in "$SCRIPT_DIR"/*/; do
  standard_name="$(basename "$standard_dir")"

  # Only symlink if the folder contains Claude hook scripts (pre-bash.sh, post-bash.sh, etc.)
  has_claude_hooks=false
  for f in "$standard_dir"pre-*.sh "$standard_dir"post-*.sh; do
    [ -f "$f" ] && has_claude_hooks=true && break
  done
  $has_claude_hooks || continue

  target="${CLAUDE_HOOKS_DIR}/${standard_name}"

  if [ -L "$target" ]; then
    dim "  ↻  $standard_name (updating symlink)"
    rm "$target"
  elif [ -d "$target" ]; then
    dim "  ⚠  $standard_name already exists as a directory (skipping — remove manually to replace)"
    continue
  fi

  ln -sf "$standard_dir" "$target"
  chmod +x "$standard_dir"*.sh 2>/dev/null || true
  green "  ✓  $standard_name → $standard_dir"
  INSTALLED_CLAUDE=$((INSTALLED_CLAUDE + 1))
done

[ "$INSTALLED_CLAUDE" -eq 0 ] && dim "  (none found)"

# ════════════════════════════════════════════════════════════════════
# 3. Summary
# ════════════════════════════════════════════════════════════════════
echo ""
green "Done."
dim "  Git hooks installed to:          ${HOOKS_DIR}/"
dim "  Claude Code hooks symlinked to:  ${CLAUDE_HOOKS_DIR}/"
echo ""
dim "Next step: ensure .claude/settings.json references the Claude hooks."
dim "See standards/hooks/README.md for the settings.json snippet."
