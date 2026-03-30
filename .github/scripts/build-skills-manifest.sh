#!/usr/bin/env bash
# build-skills-manifest.sh
#
# Reads version fields from all skills/*/SKILL.md frontmatter and generates
# a JSON manifest mapping skill names to their current versions.
#
# Output: .github/scripts/skills-versions.json
#
# Usage:
#   .github/scripts/build-skills-manifest.sh [skills-dir] [output-file]

set -euo pipefail

SKILLS_DIR="${1:-skills}"
OUTPUT_FILE="${2:-.github/scripts/skills-versions.json}"

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[1;32m%s\033[0m\n' "$*" >&2; }

# --- Validate skills dir ---
if [ ! -d "$SKILLS_DIR" ]; then
  red "ERROR: skills directory not found: $SKILLS_DIR"
  exit 1
fi

# --- Build manifest using jq for safe JSON construction ---
manifest="{}"

for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_file="$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue

  skill_name="$(basename "$skill_dir")"

  # Extract version from YAML frontmatter (between --- delimiters)
  version=""
  in_frontmatter=false
  while IFS= read -r line; do
    if [ "$line" = "---" ]; then
      if [ "$in_frontmatter" = true ]; then
        break  # End of frontmatter
      else
        in_frontmatter=true
        continue
      fi
    fi
    if [ "$in_frontmatter" = true ]; then
      if echo "$line" | grep -qE '^version:'; then
        version=$(echo "$line" | sed 's/^version: *//; s/ *$//')
        break
      fi
    fi
  done < "$skill_file"

  if [ -z "$version" ]; then
    red "WARNING: $skill_file missing version field in frontmatter"
    continue
  fi

  manifest=$(echo "$manifest" | jq -S --arg name "$skill_name" --arg version "$version" '. + {($name): $version}')
done

echo "$manifest" > "$OUTPUT_FILE"

green "Generated $OUTPUT_FILE"
cat "$OUTPUT_FILE" >&2
