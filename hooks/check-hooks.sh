#!/usr/bin/env bash
# check-hooks.sh
#
# Checks whether installed hooks are up-to-date with the source in claude-templates.
# Run from the TARGET PROJECT'S root directory.
#
# Reads .claude/hook-versions.json (written by install scripts) and compares
# against the HOOK_VERSION in each source script.
#
# Usage:
#   ~/Projects/Claude\ Templates/standards/hooks/check-hooks.sh
#
# Exit codes:
#   0 — all hooks up-to-date
#   1 — one or more hooks outdated or missing

set -euo pipefail

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }

# --- Resolve paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
VERSIONS_FILE="${PROJECT_ROOT}/.claude/hook-versions.json"

OUTDATED=0
CHECKED=0

# --- Check if versions file exists ---
if [ ! -f "$VERSIONS_FILE" ]; then
  warn "No .claude/hook-versions.json found."
  dim "Run install-hooks.sh first to install and register hooks."
  exit 1
fi

echo ""
dim "Checking hooks against source in: ${SCRIPT_DIR}"
echo ""

# --- Walk all hook scripts in source ---
while IFS= read -r -d '' hook_file; do
  # Derive the hook key (e.g., "git/pre-bash.sh", "versioning/git-hook-pre-commit.sh")
  REL_PATH="${hook_file#"$SCRIPT_DIR"/}"
  # Skip non-hook files (install scripts, README, this script)
  case "$REL_PATH" in
    */install-hooks.sh|install-hooks.sh|README.md|check-hooks.sh) continue ;;
  esac

  SOURCE_VERSION=$(grep '^HOOK_VERSION=' "$hook_file" | head -1 | sed 's/HOOK_VERSION="//' | sed 's/"//')
  if [ -z "$SOURCE_VERSION" ]; then
    continue  # Not a versioned hook
  fi

  CHECKED=$((CHECKED + 1))

  # Look up installed version
  INSTALLED_VERSION=$(jq -r --arg hook "$REL_PATH" '.[$hook].version // "not installed"' "$VERSIONS_FILE")
  INSTALL_TYPE=$(jq -r --arg hook "$REL_PATH" '.[$hook].type // "unknown"' "$VERSIONS_FILE")

  if [ "$INSTALLED_VERSION" = "not installed" ]; then
    warn "  ✗  ${REL_PATH}  — not installed"
    dim "     Source version: ${SOURCE_VERSION}"
    OUTDATED=$((OUTDATED + 1))
  elif [ "$INSTALLED_VERSION" != "$SOURCE_VERSION" ]; then
    red "  ✗  ${REL_PATH}  — outdated"
    dim "     Installed: ${INSTALLED_VERSION}  →  Source: ${SOURCE_VERSION}  (${INSTALL_TYPE})"
    OUTDATED=$((OUTDATED + 1))
  else
    green "  ✓  ${REL_PATH}  — ${SOURCE_VERSION} (${INSTALL_TYPE})"
  fi

done < <(find "$SCRIPT_DIR" -name '*.sh' -print0 | sort -z)

echo ""

if [ "$CHECKED" -eq 0 ]; then
  warn "No versioned hooks found in source."
  exit 0
fi

if [ "$OUTDATED" -gt 0 ]; then
  echo ""
  warn "${OUTDATED} hook(s) out of date. Run the installer to update:"
  dim "  ${SCRIPT_DIR}/install-hooks.sh"
  exit 1
else
  green "All ${CHECKED} hook(s) up-to-date."
  exit 0
fi
