#!/usr/bin/env bash
# build-versions-manifest.sh
#
# Reads version comments from all standards/*.md files and generates
# a JSON manifest mapping standard names to their current versions.
#
# Output: .github/scripts/standards-versions.json
#
# Usage:
#   .github/scripts/build-versions-manifest.sh [standards-dir] [output-file]

set -euo pipefail

STANDARDS_DIR="${1:-standards}"
OUTPUT_FILE="${2:-.github/scripts/standards-versions.json}"

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[1;32m%s\033[0m\n' "$*" >&2; }

# --- Validate standards dir ---
if [ ! -d "$STANDARDS_DIR" ]; then
  red "ERROR: standards directory not found: $STANDARDS_DIR"
  exit 1
fi

# --- Build manifest using jq for safe JSON construction ---
manifest="{}"

for file in "$STANDARDS_DIR"/*.md; do
  [ -f "$file" ] || continue

  # Extract version comment: <!-- standard: <name> | version: <ver> -->
  version_line=$(head -1 "$file")
  if echo "$version_line" | grep -qE '<!-- standard: .+ \| version: .+ -->'; then
    name=$(echo "$version_line" | sed 's/.*standard: *\([^ |]*\).*/\1/')
    version=$(echo "$version_line" | sed 's/.*version: *\([^ ]*\) *-->.*/\1/')

    # Use jq --arg to safely construct JSON (handles special chars in name/version)
    manifest=$(echo "$manifest" | jq -S --arg name "$name" --arg version "$version" '. + {($name): $version}')
  else
    red "WARNING: $file missing version comment on line 1"
  fi
done

echo "$manifest" > "$OUTPUT_FILE"

green "Generated $OUTPUT_FILE"
cat "$OUTPUT_FILE" >&2
