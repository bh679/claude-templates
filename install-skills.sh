#!/bin/bash
# Install claude-templates skills by symlinking into ~/.claude/skills/
# Run from the claude-templates repo root.
# Symlinks mean updates to this repo automatically update your installed skills.

set -e

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  mkdir -p "$SKILLS_DIR"
  echo "Created $SKILLS_DIR"
fi

echo "Installing skills from $REPO_DIR → $SKILLS_DIR"
echo ""

for skill_path in "$REPO_DIR"/*/; do
  skill_name="$(basename "$skill_path")"
  target="$SKILLS_DIR/$skill_name"

  if [ -L "$target" ]; then
    echo "  ↻  $skill_name (updating symlink)"
    rm "$target"
  elif [ -d "$target" ]; then
    echo "  ⚠  $skill_name already exists as a directory (skipping — remove manually to replace)"
    continue
  else
    echo "  ✓  $skill_name (new)"
  fi

  ln -sf "$skill_path" "$target"
done

echo ""
echo "Done. Installed skills:"
ls "$SKILLS_DIR"
