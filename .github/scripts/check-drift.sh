#!/bin/bash
# check-drift.sh
# Checks consumer repos for drift from their templates.
#
# - engineering/*: checks CLAUDE.md for required fingerprint strings
# - operator: checks for required file existence via gh api
#
# Opens a GitHub issue in the consumer repo if drift is detected.
#
# Usage: ./check-drift.sh <consumers.json path> <template dir>
# Requires: gh CLI authenticated, jq

set -e

CONSUMERS_FILE="${1:-consumers.json}"
TEMPLATE_DIR="${2:-templates/engineering/product}"
ISSUES_OPENED=0

# Fingerprint strings that must appear in any engineering template CLAUDE.md.
# If a consumer's CLAUDE.md is missing these, it has drifted from the template.
FINGERPRINTS=(
  "Gate 1"
  "Gate 2"
  "Gate 3"
  "V.MM.PPPP"
  "EnterPlanMode"
  "ExitPlanMode"
  "Product Engineer"
  "github.com/bh679/claude-templates"
)

echo "Checking drift for consumers in $CONSUMERS_FILE"
echo ""

consumer_count=$(jq '. | length' "$CONSUMERS_FILE")

for i in $(seq 0 $((consumer_count - 1))); do
  repo=$(jq -r ".[$i].repo" "$CONSUMERS_FILE")
  template=$(jq -r ".[$i].template" "$CONSUMERS_FILE")

  echo "Checking $repo (template: $template)..."

  if [ "$template" = "operator" ]; then
    # ── Operator: file-existence checks ──────────────────────────────────────
    required_files=$(jq -r ".[$i].required_files[]" "$CONSUMERS_FILE" 2>/dev/null || echo "")

    if [ -z "$required_files" ]; then
      echo "  ⚠ No required_files defined for operator $repo — skipping"
      continue
    fi

    missing_files=()
    while IFS= read -r f; do
      if ! gh api "repos/$repo/contents/$f" >/dev/null 2>&1; then
        missing_files+=("$f")
      fi
    done <<< "$required_files"

    if [ ${#missing_files[@]} -eq 0 ]; then
      echo "  ✓ All required files present"
    else
      echo "  ⚠ Drift detected — missing files: ${missing_files[*]}"

      # Check if a drift issue already exists (avoid duplicates)
      existing_issue=$(gh issue list --repo "$repo" --label "claude-template-drift" --state open --json number --jq '.[0].number' 2>/dev/null || echo "")

      if [ -n "$existing_issue" ]; then
        echo "  → Issue #$existing_issue already open, skipping"
        continue
      fi

      missing_list=$(printf '- `%s`\n' "${missing_files[@]}")
      gh issue create \
        --repo "$repo" \
        --title "⚠️ Operator scaffolding drift detected" \
        --label "claude-template-drift" \
        --body "## Operator Template Drift Detected

This repo uses the \`operator\` template from [bh679/claude-templates](https://github.com/bh679/claude-templates) but is missing required files.

### Missing Files

$missing_list

### What to Do

1. Review the operator template: [\`templates/operator/\`](https://github.com/bh679/claude-templates/tree/main/templates/operator)
2. Review the operator standard: [\`standards/operator.md\`](https://github.com/bh679/claude-templates/blob/main/standards/operator.md)
3. Add the missing files to this repo
4. Close this issue once resolved

*Opened automatically by the claude-templates drift detection workflow.*"

      echo "  → Opened drift issue in $repo"
      ISSUES_OPENED=$((ISSUES_OPENED + 1))
    fi

  else
    # ── Engineering (default): CLAUDE.md fingerprint checks ─────────────
    claude_md_path=$(jq -r ".[$i].claude_md_path" "$CONSUMERS_FILE")

    echo "  Checking $claude_md_path for fingerprints..."

    # Fetch the consumer's CLAUDE.md
    consumer_claude_md=$(gh api "repos/$repo/contents/$claude_md_path" --jq '.content' | base64 -d 2>/dev/null || echo "")

    if [ -z "$consumer_claude_md" ]; then
      echo "  ⚠ Could not fetch $claude_md_path from $repo — skipping"
      continue
    fi

    # Check each fingerprint
    missing=()
    for fingerprint in "${FINGERPRINTS[@]}"; do
      if ! echo "$consumer_claude_md" | grep -qF "$fingerprint"; then
        missing+=("$fingerprint")
      fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
      echo "  ✓ No drift detected"
    else
      echo "  ⚠ Drift detected — missing fingerprints: ${missing[*]}"

      # Check if a drift issue already exists (avoid duplicates)
      existing_issue=$(gh issue list --repo "$repo" --label "claude-template-drift" --state open --json number --jq '.[0].number' 2>/dev/null || echo "")

      if [ -n "$existing_issue" ]; then
        echo "  → Issue #$existing_issue already open, skipping"
        continue
      fi

      # Open an issue in the consumer repo
      missing_list=$(printf '- `%s`\n' "${missing[@]}")
      gh issue create \
        --repo "$repo" \
        --title "⚠️ CLAUDE.md drift detected — templates updated" \
        --label "claude-template-drift" \
        --body "## Claude Templates Drift Detected

The \`$claude_md_path\` in this repo appears to have drifted from the canonical \`$template\` template in [bh679/claude-templates](https://github.com/bh679/claude-templates).

### Missing Fingerprints

$missing_list

### What to Do

1. Review the latest template: [\`templates/$template/CLAUDE.md\`](https://github.com/bh679/claude-templates/blob/main/templates/$template/CLAUDE.md)
2. Review the relevant standards docs: [standards/](https://github.com/bh679/claude-templates/tree/main/standards)
3. Manually propagate any relevant changes to this repo's \`$claude_md_path\`
4. Close this issue once updated

*Opened automatically by the claude-templates drift detection workflow.*"

      echo "  → Opened drift issue in $repo"
      ISSUES_OPENED=$((ISSUES_OPENED + 1))
    fi
  fi
done

echo ""
echo "Drift check complete. Issues opened: $ISSUES_OPENED"
