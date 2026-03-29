#!/usr/bin/env bash
# sync-standards.sh — Sync inlined standards in CLAUDE.md from standards/ source files.
#
# Finds <!-- BEGIN STANDARD: name --> ... <!-- END STANDARD: name --> blocks in CLAUDE.md
# and replaces the content between markers with the current standards/<name>.md file.
#
# Usage: ./scripts/sync-standards.sh [--check]
#   --check  Exit with code 1 if CLAUDE.md is out of sync (no modifications made)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_MD="$REPO_ROOT/CLAUDE.md"
STANDARDS_DIR="$REPO_ROOT/standards"
CHECK_ONLY=false

if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
fi

if [[ ! -f "$CLAUDE_MD" ]]; then
  echo "ERROR: CLAUDE.md not found at $CLAUDE_MD" >&2
  exit 1
fi

# Extract standard names from BEGIN markers
STANDARDS=$(sed -n 's/^<!-- BEGIN STANDARD: \([a-zA-Z0-9_-]*\) -->/\1/p' "$CLAUDE_MD" || true)

if [[ -z "$STANDARDS" ]]; then
  echo "No <!-- BEGIN STANDARD: name --> markers found in CLAUDE.md" >&2
  exit 0
fi

# Build the updated file
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

IN_STANDARD=false
CURRENT_STANDARD=""

while IFS= read -r line || [[ -n "$line" ]]; do
  # Check for BEGIN marker
  if [[ "$line" =~ ^'<!-- BEGIN STANDARD: '([a-zA-Z0-9_-]+)' -->'$ ]]; then
    CURRENT_STANDARD="${BASH_REMATCH[1]}"
    STANDARD_FILE="$STANDARDS_DIR/${CURRENT_STANDARD}.md"

    if [[ ! -f "$STANDARD_FILE" ]]; then
      echo "WARNING: Standard file not found: $STANDARD_FILE — skipping" >&2
      echo "$line" >> "$TMPFILE"
      IN_STANDARD=true
      continue
    fi

    # Write the BEGIN marker
    echo "$line" >> "$TMPFILE"
    # Write the standard content
    cat "$STANDARD_FILE" >> "$TMPFILE"
    IN_STANDARD=true
    continue
  fi

  # Check for END marker
  if [[ "$line" =~ ^'<!-- END STANDARD: '([a-zA-Z0-9_-]+)' -->'$ ]]; then
    echo "$line" >> "$TMPFILE"
    IN_STANDARD=false
    CURRENT_STANDARD=""
    continue
  fi

  # Skip lines inside a standard block (they get replaced)
  if $IN_STANDARD; then
    continue
  fi

  # Pass through all other lines
  echo "$line" >> "$TMPFILE"
done < "$CLAUDE_MD"

# Sync gate files: standards/gates/ → .claude/gates/
GATES_SRC="$STANDARDS_DIR/gates"
GATES_DST="$REPO_ROOT/.claude/gates"
GATES_CHANGED=false

if [[ -d "$GATES_SRC" ]]; then
  mkdir -p "$GATES_DST"
  for gate_file in "$GATES_SRC"/*.md; do
    [[ -f "$gate_file" ]] || continue
    dst_file="$GATES_DST/$(basename "$gate_file")"
    if ! diff -q "$gate_file" "$dst_file" > /dev/null 2>&1; then
      GATES_CHANGED=true
      if ! $CHECK_ONLY; then
        cp "$gate_file" "$dst_file"
      fi
    fi
  done
fi

# Compare
CLAUDE_CHANGED=true
if diff -q "$CLAUDE_MD" "$TMPFILE" > /dev/null 2>&1; then
  CLAUDE_CHANGED=false
fi

if ! $CLAUDE_CHANGED && ! $GATES_CHANGED; then
  echo "CLAUDE.md and gate files are up to date — no changes needed."
  exit 0
fi

if $CHECK_ONLY; then
  if $CLAUDE_CHANGED; then
    echo "CLAUDE.md is OUT OF SYNC with standards/. Run: ./scripts/sync-standards.sh" >&2
    diff --unified "$CLAUDE_MD" "$TMPFILE" || true
  fi
  if $GATES_CHANGED; then
    echo "Gate files are OUT OF SYNC. Run: ./scripts/sync-standards.sh" >&2
  fi
  exit 1
fi

# Apply updates
if $CLAUDE_CHANGED; then
  cp "$TMPFILE" "$CLAUDE_MD"
  echo "CLAUDE.md updated with latest standards."
fi
if $GATES_CHANGED; then
  echo "Gate files synced to .claude/gates/."
fi
