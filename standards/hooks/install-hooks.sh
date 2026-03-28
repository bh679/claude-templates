#!/usr/bin/env bash
# install-hooks.sh
#
# Composite installer — installs hooks for ALL standards.
# Run from the TARGET PROJECT'S root directory.
#
# To install hooks for a specific standard only, run its installer directly:
#   ~/Projects/Claude\ Templates/standards/hooks/git/install-hooks.sh
#   ~/Projects/Claude\ Templates/standards/hooks/versioning/install-hooks.sh
#
# Usage:
#   ~/Projects/Claude\ Templates/standards/hooks/install-hooks.sh

set -euo pipefail

# --- Helpers ---
blue()  { printf '\033[1;34m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"

blue "Installing all hooks into: ${PROJECT_ROOT}"
echo ""

# --- Run each standard's installer ---
for installer in "$SCRIPT_DIR"/*/install-hooks.sh; do
  standard="$(basename "$(dirname "$installer")")"
  dim "── ${standard} ─────────────────────────────────────────────────"
  bash "$installer"
  echo ""
done

green "All hooks installed."
dim "Claude Code hooks are symlinked — updates to claude-templates propagate automatically."
dim "Git hooks are copied — re-run this script to pick up future changes."
