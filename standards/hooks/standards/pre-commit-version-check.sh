#!/usr/bin/env bash
# standards/pre-commit-version-check.sh
#
# Pre-commit hook that blocks commits changing standards/*.md files
# without bumping the version in the <!-- standard: ... --> comment.
#
# For use in the claude-templates repo only.
# Consumer projects use different hooks (versioning, git).
#
# Usage: Copy or symlink into .git/hooks/pre-commit
#        or use install-hooks.sh to install automatically.

set -euo pipefail

STANDARDS_DIR="standards"

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }

# --- Find staged standards ---
staged_standards=""
while IFS= read -r line; do
  staged_standards="${staged_standards}${staged_standards:+$'\n'}${line}"
done < <(git diff --cached --name-only -- "$STANDARDS_DIR"/*.md 2>/dev/null)

if [ -z "$staged_standards" ]; then
  exit 0
fi

errors=0

while IFS= read -r file; do
  [ -f "$file" ] || continue
  filename=$(basename "$file")

  # Extract staged version
  staged_line=$(git show :"$file" | head -1)
  if ! echo "$staged_line" | grep -qE '<!-- standard: .+ \| version: .+ -->'; then
    red "BLOCKED: $filename missing version comment on line 1"
    red "  Expected: <!-- standard: <name> | version: X.Y.Z -->"
    errors=$((errors + 1))
    continue
  fi
  staged_version=$(echo "$staged_line" | sed 's/.*version: *\([^ ]*\) *-->.*/\1/')

  # Extract committed (HEAD) version — skip if new file
  if ! git show HEAD:"$file" >/dev/null 2>&1; then
    dim "New standard: $filename — skipping version check"
    continue
  fi

  committed_line=$(git show HEAD:"$file" | head -1)
  # If committed version has no version comment, this is first version-tracked commit
  if ! echo "$committed_line" | grep -qE '<!-- standard: .+ \| version: .+ -->'; then
    dim "First versioned commit for $filename — skipping comparison"
    continue
  fi
  committed_version=$(echo "$committed_line" | sed 's/.*version: *\([^ ]*\) *-->.*/\1/')

  # Compare content (excluding version line)
  committed_content=$(git show HEAD:"$file" | tail -n +2)
  staged_content=$(git show :"$file" | tail -n +2)

  if [ "$committed_content" != "$staged_content" ] && [ "$staged_version" = "$committed_version" ]; then
    red "BLOCKED: $filename content changed but version is still $staged_version"
    red "  Bump the version in the <!-- standard: ... --> comment on line 1."
    dim "  Patch: clarification/typo | Minor: new section | Major: removed/changed rules"
    errors=$((errors + 1))
  fi
done <<< "$staged_standards"

if [ "$errors" -gt 0 ]; then
  echo ""
  red "$errors standard(s) need a version bump."
  exit 1
fi

green "Standards version check passed."
exit 0
