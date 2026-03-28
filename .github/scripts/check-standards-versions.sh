#!/usr/bin/env bash
# check-standards-versions.sh
#
# Compares standards versions between two git refs (or working tree vs ref).
# Fails if any standard's content changed without a version bump.
# Also verifies standards-versions.json is in sync.
#
# Usage:
#   .github/scripts/check-standards-versions.sh [base-ref]
#
# base-ref defaults to the merge base of HEAD and origin/main.

set -euo pipefail

BASE_REF="${1:-}"
STANDARDS_DIR="standards"
MANIFEST=".github/scripts/standards-versions.json"

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[1;32m%s\033[0m\n' "$*" >&2; }
dim()   { printf '\033[2m%s\033[0m\n' "$*" >&2; }

# --- Resolve base ref ---
if [ -z "$BASE_REF" ]; then
  BASE_REF=$(git merge-base HEAD origin/main 2>/dev/null || echo "HEAD~1")
fi

dim "Comparing standards against: $BASE_REF"

# --- Check each changed standard ---
errors=0

changed_standards=""
while IFS= read -r line; do
  changed_standards="${changed_standards}${changed_standards:+$'\n'}${line}"
done < <(git diff --name-only "$BASE_REF" -- "$STANDARDS_DIR"/*.md 2>/dev/null)

if [ -z "$changed_standards" ]; then
  green "No standards changed — skipping per-file version checks."
  # Fall through to manifest sync check
else

while IFS= read -r file; do
  [ -f "$file" ] || continue
  filename=$(basename "$file")
  dim "Checking $filename..."

  # Extract current version
  current_line=$(head -1 "$file")
  if ! echo "$current_line" | grep -qE '<!-- standard: .+ \| version: .+ -->'; then
    red "FAIL: $filename missing version comment on line 1"
    errors=$((errors + 1))
    continue
  fi
  current_version=$(echo "$current_line" | sed 's/.*version: *\([^ ]*\) *-->.*/\1/')

  # Extract base version
  base_line=$(git show "${BASE_REF}:${file}" 2>/dev/null | head -1 || echo "")
  if [ -z "$base_line" ]; then
    dim "  New file — skipping version check"
    continue
  fi
  # If base doesn't have a version comment, this is the first version-tracked commit
  if ! echo "$base_line" | grep -qE '<!-- standard: .+ \| version: .+ -->'; then
    dim "  First versioned commit — skipping comparison"
    continue
  fi
  base_version=$(echo "$base_line" | sed 's/.*version: *\([^ ]*\) *-->.*/\1/')

  # Compare content (excluding the version line itself)
  base_content=$(git show "${BASE_REF}:${file}" 2>/dev/null | tail -n +2)
  current_content=$(tail -n +2 "$file")

  if [ "$base_content" != "$current_content" ] && [ "$current_version" = "$base_version" ]; then
    red "FAIL: $filename content changed but version is still $current_version"
    red "  Bump the version in the <!-- standard: ... --> comment on line 1."
    dim "  Patch: clarification/typo | Minor: new section | Major: removed/changed rules"
    errors=$((errors + 1))
  elif [ "$base_content" != "$current_content" ]; then
    green "  OK: $filename version bumped $base_version → $current_version"
  else
    dim "  Only version comment changed (no content change)"
  fi
done <<< "$changed_standards"

fi  # end of changed_standards check

# --- Check manifest is in sync ---
dim ""
dim "Checking standards-versions.json is in sync..."

# Generate expected manifest to a temp file
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

bash "$(dirname "$0")/build-versions-manifest.sh" "$STANDARDS_DIR" "$TMPFILE" 2>/dev/null

if [ -f "$MANIFEST" ] && diff -q "$TMPFILE" "$MANIFEST" >/dev/null 2>&1; then
  green "standards-versions.json is up to date."
else
  red "FAIL: standards-versions.json is out of sync."
  red "  Run: .github/scripts/build-versions-manifest.sh"
  errors=$((errors + 1))
fi

# --- Result ---
echo ""
if [ "$errors" -gt 0 ]; then
  red "$errors check(s) failed."
  exit 1
else
  green "All standards version checks passed."
  exit 0
fi
