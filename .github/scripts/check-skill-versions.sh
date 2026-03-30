#!/usr/bin/env bash
# check-skill-versions.sh
#
# Compares installed skill versions (~/.claude/skills/*/SKILL.md) against the
# latest versions in the manifest (.github/scripts/skills-versions.json).
#
# Reports: up-to-date, outdated (old → new), or missing.
# Exit code 1 if any skills are outdated or missing.
#
# Usage:
#   .github/scripts/check-skill-versions.sh [manifest-path] [installed-dir]

set -euo pipefail

MANIFEST="${1:-.github/scripts/skills-versions.json}"
INSTALLED_DIR="${2:-$HOME/.claude/skills}"

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[1;32m%s\033[0m\n' "$*" >&2; }
yellow(){ printf '\033[1;33m%s\033[0m\n' "$*" >&2; }
dim()   { printf '\033[2m%s\033[0m\n' "$*" >&2; }

# --- SemVer comparison: returns 0 if $1 < $2 ---
version_lt() {
  local IFS='.'
  local -a v1=($1) v2=($2)
  for i in 0 1 2; do
    local a="${v1[$i]:-0}" b="${v2[$i]:-0}"
    if [ "$a" -lt "$b" ]; then return 0; fi
    if [ "$a" -gt "$b" ]; then return 1; fi
  done
  return 1  # equal
}

# --- Extract version from SKILL.md frontmatter ---
extract_version() {
  local file="$1"
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
  done < "$file"
}

# --- Validate inputs ---
if [ ! -f "$MANIFEST" ]; then
  red "ERROR: manifest not found: $MANIFEST"
  red "Run: .github/scripts/build-skills-manifest.sh"
  exit 1
fi

if [ ! -d "$INSTALLED_DIR" ]; then
  red "ERROR: installed skills directory not found: $INSTALLED_DIR"
  exit 1
fi

# --- Check each skill in the manifest ---
echo "Checking installed skills against $MANIFEST"
echo ""

outdated=0
missing=0
up_to_date=0

for skill_name in $(jq -r 'keys[]' "$MANIFEST"); do
  latest_version=$(jq -r --arg name "$skill_name" '.[$name]' "$MANIFEST")
  installed_file="$INSTALLED_DIR/$skill_name/SKILL.md"

  if [ ! -f "$installed_file" ]; then
    yellow "  ✗  $skill_name — not installed (latest: v$latest_version)"
    missing=$((missing + 1))
    continue
  fi

  installed_version=$(extract_version "$installed_file")

  if [ -z "$installed_version" ]; then
    yellow "  ?  $skill_name — installed but no version in frontmatter"
    outdated=$((outdated + 1))
    continue
  fi

  if [ "$installed_version" = "$latest_version" ]; then
    green "  ✓  $skill_name v$installed_version (up to date)"
    up_to_date=$((up_to_date + 1))
  elif version_lt "$installed_version" "$latest_version"; then
    red "  ↻  $skill_name v$installed_version → v$latest_version (outdated)"
    outdated=$((outdated + 1))
  else
    dim "  ⚠  $skill_name v$installed_version > v$latest_version (ahead of manifest)"
    up_to_date=$((up_to_date + 1))
  fi
done

# --- Summary ---
echo ""
echo "Summary: $up_to_date up to date, $outdated outdated, $missing missing"

if [ "$outdated" -gt 0 ] || [ "$missing" -gt 0 ]; then
  echo ""
  echo "To update, run:"
  echo "  cd ~/Projects/Claude\\ Templates && git pull && ./install-skills.sh"
  exit 1
fi

exit 0
