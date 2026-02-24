#!/bin/bash
# check-drift.sh
# Compares consumer repo CLAUDE.md files against key template fingerprints.
# Opens a GitHub issue in the consumer repo if drift is detected.
#
# Usage: ./check-drift.sh <consumers.json path> <template dir>
# Requires: gh CLI authenticated, jq

set -e

CONSUMERS_FILE="${1:-consumers.json}"
TEMPLATE_DIR="${2:-templates/product-engineer}"
ISSUES_OPENED=0

# Fingerprint strings that must appear in any product-engineer CLAUDE.md.
# If a consumer's CLAUDE.md is missing these, it has drifted from the template.
FINGERPRINTS=(
  "Gate 1"
  "Gate 2"
  "Gate 3"
  "V.MM.PPPP"
  "EnterPlanMode"
  "ExitPlanMode"
  "Product Engineer"
)

echo "Checking drift for consumers in $CONSUMERS_FILE"
echo ""

consumer_count=$(jq '. | length' "$CONSUMERS_FILE")

for i in $(seq 0 $((consumer_count - 1))); do
  repo=$(jq -r ".[$i].repo" "$CONSUMERS_FILE")
  claude_md_path=$(jq -r ".[$i].claude_md_path" "$CONSUMERS_FILE")
  template=$(jq -r ".[$i].template" "$CONSUMERS_FILE")

  echo "Checking $repo ($claude_md_path)..."

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
    missing_list=""
    for item in "${missing[@]}"; do
      missing_list="${missing_list}- \`${item}\`\n"
    done
    missing_list=$(printf "%b" "$missing_list")
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
done

echo ""
echo "Drift check complete. Issues opened: $ISSUES_OPENED"
