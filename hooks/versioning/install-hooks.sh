#!/usr/bin/env bash
# versioning/install-hooks.sh
#
# Installs versioning.md enforcement hooks into a consumer project.
# Run from the TARGET PROJECT'S root directory.
#
# Installs:
#   Git hook → .git/hooks/pre-commit  (copied — git hooks are not committed)
#
# Usage:
#   ~/Projects/Claude\ Templates/standards/hooks/versioning/install-hooks.sh

set -euo pipefail

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"

# --- Verify git repo (supports worktrees) ---
GIT_DIR="$(git rev-parse --git-dir 2>/dev/null)" || {
  red "ERROR: Not inside a git repository."
  red "Run this script from your project's root directory."
  exit 1
}

HOOKS_DIR="${GIT_DIR}/hooks"
TARGET="${HOOKS_DIR}/pre-commit"
SOURCE="${SCRIPT_DIR}/git-hook-pre-commit.sh"

# --- Install git pre-commit hook ---
mkdir -p "$HOOKS_DIR"

if [ -f "$TARGET" ] && [ ! -L "$TARGET" ]; then
  dim "Backing up existing pre-commit → pre-commit.bak"
  cp "$TARGET" "${TARGET}.bak"
fi

cp "$SOURCE" "$TARGET"
chmod +x "$TARGET"

# --- Record installed version ---
INSTALLED_VERSION=$(grep '^HOOK_VERSION=' "$SOURCE" | head -1 | sed 's/HOOK_VERSION="//' | sed 's/"//')
VERSIONS_FILE="${PROJECT_ROOT}/.claude/hook-versions.json"
mkdir -p "$(dirname "$VERSIONS_FILE")"
if [ -f "$VERSIONS_FILE" ]; then
  # Update existing entry
  TEMP=$(mktemp)
  jq --arg hook "versioning/git-hook-pre-commit.sh" \
     --arg ver "$INSTALLED_VERSION" \
     --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     '.[$hook] = {"version": $ver, "installedAt": $ts, "type": "copied"}' \
     "$VERSIONS_FILE" > "$TEMP" && mv "$TEMP" "$VERSIONS_FILE"
else
  # Create new file
  jq -n --arg hook "versioning/git-hook-pre-commit.sh" \
        --arg ver "$INSTALLED_VERSION" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{($hook): {"version": $ver, "installedAt": $ts, "type": "copied"}}' \
        > "$VERSIONS_FILE"
fi

green "✓  versioning pre-commit hook → ${TARGET}"
dim "   Enforces: V.MM.PPPP format, version bumped on every commit"
dim "   Version:  ${INSTALLED_VERSION}"
