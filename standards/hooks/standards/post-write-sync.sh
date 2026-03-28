#!/usr/bin/env bash
# hook-version: 1.0.0
# standards/post-write-sync.sh
HOOK_VERSION="1.0.0"
#
# Claude Code PostToolUse hook — auto-syncs CLAUDE.md when a standard is edited.
#
# Trigger: PostToolUse on Write or Edit
# Condition: The edited file matches standards/*.md
# Action: Runs scripts/sync-standards.sh to update inlined standards in CLAUDE.md
#
# Input: JSON on stdin with shape { "tool_name": "Write"|"Edit", "tool_input": { "file_path": "..." } }

set -uo pipefail

# --- Helpers ---
green() { printf '\033[1;32m%s\033[0m\n' "$*" >&2; }
dim()   { printf '\033[2m%s\033[0m\n' "$*" >&2; }

# --- Parse input ---
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Only act on standards/*.md files
if ! echo "$FILE_PATH" | grep -q 'standards/[^/]*\.md$'; then
  exit 0
fi

# Find repo root (walk up from this script's location)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SYNC_SCRIPT="$REPO_ROOT/scripts/sync-standards.sh"

if [[ ! -x "$SYNC_SCRIPT" ]]; then
  dim "sync-standards.sh not found at $SYNC_SCRIPT — skipping auto-sync"
  exit 0
fi

# Run the sync
OUTPUT=$("$SYNC_SCRIPT" 2>&1)

if echo "$OUTPUT" | grep -q "updated"; then
  green "AUTO-SYNC: CLAUDE.md updated with latest standards."
  dim "A standard file was edited — CLAUDE.md inlined content has been refreshed."
else
  dim "Standards sync: CLAUDE.md already up to date."
fi

exit 0
