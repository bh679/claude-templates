#!/bin/bash
# Install claude-templates skills by symlinking into ~/.claude/skills/
# Run from the claude-templates repo root.
# Symlinks mean updates to this repo automatically update your installed skills.

set -e

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)/skills"

# --- Helper: extract version from SKILL.md frontmatter ---
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

if [ ! -d "$SKILLS_DIR" ]; then
  mkdir -p "$SKILLS_DIR"
  echo "Created $SKILLS_DIR"
fi

echo "Installing skills from $REPO_DIR → $SKILLS_DIR"
echo ""

for skill_path in "$REPO_DIR"/*/; do
  skill_name="$(basename "$skill_path")"
  target="$SKILLS_DIR/$skill_name"
  skill_file="$skill_path/SKILL.md"

  # Get new version
  new_version=""
  if [ -f "$skill_file" ]; then
    new_version=$(extract_version "$skill_file")
  fi
  version_label="${new_version:+v$new_version}"

  if [ -L "$target" ]; then
    # Get old version before replacing
    old_version=""
    old_skill_file="$target/SKILL.md"
    if [ -f "$old_skill_file" ]; then
      old_version=$(extract_version "$old_skill_file")
    fi

    rm "$target"
    ln -sf "$skill_path" "$target"

    if [ -n "$old_version" ] && [ -n "$new_version" ] && [ "$old_version" != "$new_version" ]; then
      echo "  ↻  $skill_name v$old_version → v$new_version (updated)"
    else
      echo "  ↻  $skill_name ${version_label:+$version_label }(symlink refreshed)"
    fi
  elif [ -d "$target" ]; then
    echo "  ⚠  $skill_name already exists as a directory (skipping — remove manually to replace)"
    continue
  else
    ln -sf "$skill_path" "$target"
    echo "  ✓  $skill_name ${version_label:+$version_label }(new)"
  fi
done

echo ""
echo "Done. Installed skills:"
for skill_path in "$SKILLS_DIR"/*/; do
  [ -d "$skill_path" ] || continue
  skill_name="$(basename "$skill_path")"
  skill_file="$skill_path/SKILL.md"
  version=""
  if [ -f "$skill_file" ]; then
    version=$(extract_version "$skill_file")
  fi
  echo "  $skill_name${version:+ v$version}"
done
