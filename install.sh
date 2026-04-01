#!/bin/bash
# Install claude-templates skills and playbooks by symlinking into ~/.claude/
# Run from the claude-templates repo root.
# Symlinks mean updates to this repo automatically update your installed skills and playbooks.

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
SKILLS_SOURCE="$REPO_ROOT/skills"
PLAYBOOKS_TARGET="$HOME/.claude/playbooks"
PLAYBOOKS_SOURCE="$REPO_ROOT/playbooks"

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

# --- Install Skills ---

if [ ! -d "$SKILLS_DIR" ]; then
  mkdir -p "$SKILLS_DIR"
  echo "Created $SKILLS_DIR"
fi

echo "Installing skills from $SKILLS_SOURCE → $SKILLS_DIR"
echo ""

for skill_path in "$SKILLS_SOURCE"/*/; do
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
echo "Installed skills:"
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

# --- Install Playbooks ---

echo ""
echo "Installing playbooks from $PLAYBOOKS_SOURCE → $PLAYBOOKS_TARGET"

if [ -L "$PLAYBOOKS_TARGET" ]; then
  rm "$PLAYBOOKS_TARGET"
  ln -sf "$PLAYBOOKS_SOURCE" "$PLAYBOOKS_TARGET"
  echo "  ↻  playbooks (symlink refreshed)"
elif [ -d "$PLAYBOOKS_TARGET" ]; then
  echo "  ⚠  playbooks already exists as a directory (skipping — remove manually to replace)"
else
  ln -sf "$PLAYBOOKS_SOURCE" "$PLAYBOOKS_TARGET"
  echo "  ✓  playbooks (new)"
fi

echo ""
echo "Done."
