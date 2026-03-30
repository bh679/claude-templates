#!/usr/bin/env bash
# check-skill-versions-ci.sh
#
# CI script: compares skill versions between two git refs.
# Fails if any skill's content changed without a version bump.
# Also verifies skills-versions.json is in sync.
#
# Usage:
#   .github/scripts/check-skill-versions-ci.sh [base-ref]
#
# base-ref defaults to the merge base of HEAD and origin/main.

set -euo pipefail

BASE_REF="${1:-}"
SKILLS_DIR="skills"
MANIFEST=".github/scripts/skills-versions.json"

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[1;32m%s\033[0m\n' "$*" >&2; }
dim()   { printf '\033[2m%s\033[0m\n' "$*" >&2; }

# --- Extract version from SKILL.md frontmatter ---
extract_version_from_content() {
  local in_frontmatter=false
  while IFS= read -r line; do
    if [ "$line" = "---" ]; then
      if [ "$in_frontmatter" = true ]; then break; fi
      in_frontmatter=true
      continue
    fi
    if [ "$in_frontmatter" = true ]; then
      if echo "$line" | grep -qE '^version:'; then
        echo "$line" | sed 's/^version: *//; s/ *$//'
        return
      fi
    fi
  done
}

# --- Resolve base ref ---
if [ -z "$BASE_REF" ]; then
  BASE_REF=$(git merge-base HEAD origin/main 2>/dev/null || echo "HEAD~1")
fi

dim "Comparing skills against: $BASE_REF"

# --- Check each changed skill ---
errors=0

# Find changed SKILL.md files
changed_skills=""
while IFS= read -r line; do
  [ -n "$line" ] && changed_skills="${changed_skills}${changed_skills:+$'\n'}${line}"
done < <(git diff --name-only "$BASE_REF" -- "$SKILLS_DIR"/*/SKILL.md 2>/dev/null)

if [ -z "$changed_skills" ]; then
  green "No skills changed — skipping per-file version checks."
else

while IFS= read -r file; do
  [ -f "$file" ] || continue
  skill_name=$(echo "$file" | sed "s|$SKILLS_DIR/||; s|/SKILL.md||")
  dim "Checking $skill_name..."

  # Extract current version
  current_version=$(extract_version_from_content < "$file")
  if [ -z "$current_version" ]; then
    red "FAIL: $file missing version field in frontmatter"
    errors=$((errors + 1))
    continue
  fi

  # Extract base version
  base_content=$(git show "${BASE_REF}:${file}" 2>/dev/null || echo "")
  if [ -z "$base_content" ]; then
    dim "  New skill — skipping version check"
    continue
  fi
  base_version=$(echo "$base_content" | extract_version_from_content)
  if [ -z "$base_version" ]; then
    dim "  First versioned commit — skipping comparison"
    continue
  fi

  # Compare content (excluding the version line)
  base_body=$(git show "${BASE_REF}:${file}" 2>/dev/null | grep -v '^version:')
  current_body=$(grep -v '^version:' "$file")

  if [ "$base_body" != "$current_body" ] && [ "$current_version" = "$base_version" ]; then
    red "FAIL: $skill_name content changed but version is still $current_version"
    red "  Bump the version: field in $file frontmatter."
    dim "  Patch: clarification/typo | Minor: new section | Major: removed/changed behaviour"
    errors=$((errors + 1))
  elif [ "$base_body" != "$current_body" ]; then
    green "  OK: $skill_name version bumped $base_version → $current_version"
  else
    dim "  Only version field changed (no content change)"
  fi
done <<< "$changed_skills"

fi

# --- Check manifest is in sync ---
dim ""
dim "Checking skills-versions.json is in sync..."

TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

bash "$(dirname "$0")/build-skills-manifest.sh" "$SKILLS_DIR" "$TMPFILE" 2>/dev/null

if [ -f "$MANIFEST" ] && diff -q "$TMPFILE" "$MANIFEST" >/dev/null 2>&1; then
  green "skills-versions.json is up to date."
else
  red "FAIL: skills-versions.json is out of sync."
  red "  Run: .github/scripts/build-skills-manifest.sh"
  errors=$((errors + 1))
fi

# --- Result ---
echo ""
if [ "$errors" -gt 0 ]; then
  red "$errors check(s) failed."
  exit 1
else
  green "All skill version checks passed."
  exit 0
fi
