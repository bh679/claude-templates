#!/usr/bin/env bash
# install-hooks.sh
#
# Installs pre-commit hooks into a project's .git/hooks/ directory.
# Run this from the target project's root, passing the path to the
# claude-templates standards/hooks directory.
#
# Usage:
#   /path/to/claude-templates/standards/hooks/install-hooks.sh
#
# Or from a project root:
#   ~/Projects/Claude\ Templates/standards/hooks/install-hooks.sh

set -euo pipefail

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_SOURCE="${SCRIPT_DIR}/pre-commit-version-check.sh"

# Find the .git/hooks directory — supports worktrees
GIT_DIR="$(git rev-parse --git-dir 2>/dev/null)" || {
    red "ERROR: Not inside a git repository."
    red "Run this script from your project's root directory."
    exit 1
}

HOOKS_DIR="${GIT_DIR}/hooks"
HOOK_TARGET="${HOOKS_DIR}/pre-commit"

# --- Validate source ---
if [ ! -f "${HOOK_SOURCE}" ]; then
    red "ERROR: Hook source not found at ${HOOK_SOURCE}"
    exit 1
fi

# --- Check for existing hook ---
if [ -f "${HOOK_TARGET}" ]; then
    dim "Existing pre-commit hook found at ${HOOK_TARGET}"
    dim "Contents will be backed up to ${HOOK_TARGET}.bak"
    cp "${HOOK_TARGET}" "${HOOK_TARGET}.bak"
fi

# --- Install ---
mkdir -p "${HOOKS_DIR}"
cp "${HOOK_SOURCE}" "${HOOK_TARGET}"
chmod +x "${HOOK_TARGET}"

green "Installed pre-commit hook to ${HOOK_TARGET}"
dim "The hook enforces V.MM.PPPP version bumping on every commit."
dim "See standards/versioning.md for format details."
