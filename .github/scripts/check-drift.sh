#!/bin/bash
# check-drift.sh
# Checks consumer repos for drift from their templates.
#
# - engineering/*: checks CLAUDE.md for required fingerprint strings + standard versions
# - operator: checks for required file existence via gh api + standard versions
#
# Opens a GitHub issue in the consumer repo if drift is detected.
#
# Usage: ./check-drift.sh <consumers.json path> <template dir>
# Requires: gh CLI authenticated, jq

set -e

CONSUMERS_FILE="${1:-consumers.json}"
TEMPLATE_DIR="${2:-templates/engineering/product}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSIONS_FILE="${SCRIPT_DIR}/standards-versions.json"
ISSUES_OPENED=0

# Fingerprint strings that must appear in any engineering template CLAUDE.md.
# If a consumer's CLAUDE.md is missing these, it has drifted from the template.
FINGERPRINTS=(
  "Gate 1"
  "Gate 2"
  "Gate 3"
  "Versioning Standard"
  "EnterPlanMode"
  "ExitPlanMode"
  "Product Engineer"
  "github.com/bh679/claude-templates"
)

# --- Load current standard versions ---
if [ ! -f "$VERSIONS_FILE" ]; then
  echo "WARNING: $VERSIONS_FILE not found — skipping version checks."
  echo "  Run: .github/scripts/build-versions-manifest.sh"
  VERSIONS_AVAILABLE=false
else
  VERSIONS_AVAILABLE=true
  echo "Loaded standard versions from $VERSIONS_FILE"
fi

# --- Helper: compare semver (returns 0 if $1 < $2) ---
version_lt() {
  local IFS=.
  local i v1=($1) v2=($2)
  for ((i=0; i<3; i++)); do
    local a=${v1[i]:-0} b=${v2[i]:-0}
    if ((a < b)); then return 0; fi
    if ((a > b)); then return 1; fi
  done
  return 1  # equal
}

# --- Helper: check standard versions in consumer CLAUDE.md content ---
# Sets outdated_standards array with "name: consumer_ver → current_ver" entries
check_standard_versions() {
  local consumer_content="$1"
  outdated_standards=()

  if [ "$VERSIONS_AVAILABLE" != "true" ]; then
    return
  fi

  # Extract all standard version comments from consumer content
  # Format: <!-- standard: <name> | version: <ver> -->
  while IFS= read -r line; do
    if echo "$line" | grep -qE '<!-- standard: .+ \| version: .+ -->'; then
      local name version current_version
      name=$(echo "$line" | sed 's/.*standard: *\([^ |]*\).*/\1/')
      version=$(echo "$line" | sed 's/.*version: *\([^ ]*\) *-->.*/\1/')
      current_version=$(jq -r --arg name "$name" '.[$name] // empty' "$VERSIONS_FILE")

      if [ -n "$current_version" ] && [ "$version" != "$current_version" ]; then
        if version_lt "$version" "$current_version"; then
          outdated_standards+=("$name: v$version → v$current_version")
          echo "    ⚠ Standard '$name' is outdated: v$version → v$current_version"
        fi
      elif [ -n "$current_version" ]; then
        echo "    ✓ Standard '$name' is up to date (v$version)"
      fi
    fi
  done <<< "$consumer_content"
}

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

    # ── Operator: standard version checks ──────────────────────────────────
    claude_md_path=$(jq -r ".[$i].claude_md_path // \"CLAUDE.md\"" "$CONSUMERS_FILE")
    operator_claude_md=$(gh api "repos/$repo/contents/$claude_md_path" --jq '.content' 2>/dev/null | base64 --decode 2>/dev/null || echo "")
    outdated_standards=()
    if [ -n "$operator_claude_md" ]; then
      echo "  Checking standard versions..."
      check_standard_versions "$operator_claude_md"
    fi

    has_drift=false
    [ ${#missing_files[@]} -gt 0 ] && has_drift=true
    [ ${#outdated_standards[@]} -gt 0 ] && has_drift=true

    if [ "$has_drift" = false ]; then
      echo "  ✓ All required files present, standards up to date"
    else
      [ ${#missing_files[@]} -gt 0 ] && echo "  ⚠ Drift detected — missing files: ${missing_files[*]}"
      [ ${#outdated_standards[@]} -gt 0 ] && echo "  ⚠ Drift detected — outdated standards"

      # Check if a drift issue already exists (avoid duplicates)
      existing_issue=$(gh issue list --repo "$repo" --label "claude-template-drift" --state open --json number --jq '.[0].number' 2>/dev/null || echo "")

      if [ -n "$existing_issue" ]; then
        echo "  → Issue #$existing_issue already open, skipping"
        continue
      fi

      # Build issue body
      issue_body="## Operator Template Drift Detected

This repo uses the \`operator\` template from [bh679/claude-templates](https://github.com/bh679/claude-templates)."

      if [ ${#missing_files[@]} -gt 0 ]; then
        missing_list=$(printf '- `%s`\n' "${missing_files[@]}")
        issue_body+="

### Missing Files

$missing_list"
      fi

      if [ ${#outdated_standards[@]} -gt 0 ]; then
        outdated_list=$(printf '- `%s`\n' "${outdated_standards[@]}")
        issue_body+="

### Outdated Standards

$outdated_list

Update these standards by re-resolving the \`{{STANDARD:...}}\` tokens from the latest [standards/](https://github.com/bh679/claude-templates/tree/main/standards)."
      fi

      issue_body+="

### What to Do

1. Review the operator template: [\`templates/operator/\`](https://github.com/bh679/claude-templates/tree/main/templates/operator)
2. Review the operator standard: [\`standards/operator.md\`](https://github.com/bh679/claude-templates/blob/main/standards/operator.md)
3. Address the issues listed above
4. Re-run \`install-hooks.sh\` to update any copied git hooks
5. Close this issue once resolved

*Opened automatically by the claude-templates drift detection workflow.*"

      gh issue create \
        --repo "$repo" \
        --title "⚠️ Operator template drift detected" \
        --label "claude-template-drift" \
        --body "$issue_body"

      echo "  → Opened drift issue in $repo"
      ISSUES_OPENED=$((ISSUES_OPENED + 1))
    fi

  else
    # ── Engineering (default): CLAUDE.md fingerprint + version checks ─────
    claude_md_path=$(jq -r ".[$i].claude_md_path" "$CONSUMERS_FILE")

    echo "  Checking $claude_md_path for fingerprints..."

    # Fetch the consumer's CLAUDE.md
    consumer_claude_md=$(gh api "repos/$repo/contents/$claude_md_path" --jq '.content' | base64 --decode 2>/dev/null || echo "")

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

    # Check standard versions
    echo "  Checking standard versions..."
    check_standard_versions "$consumer_claude_md"

    has_drift=false
    [ ${#missing[@]} -gt 0 ] && has_drift=true
    [ ${#outdated_standards[@]} -gt 0 ] && has_drift=true

    if [ "$has_drift" = false ]; then
      echo "  ✓ No drift detected"
    else
      [ ${#missing[@]} -gt 0 ] && echo "  ⚠ Drift detected — missing fingerprints: ${missing[*]}"
      [ ${#outdated_standards[@]} -gt 0 ] && echo "  ⚠ Drift detected — outdated standards"

      # Check if a drift issue already exists (avoid duplicates)
      existing_issue=$(gh issue list --repo "$repo" --label "claude-template-drift" --state open --json number --jq '.[0].number' 2>/dev/null || echo "")

      if [ -n "$existing_issue" ]; then
        echo "  → Issue #$existing_issue already open, skipping"
        continue
      fi

      # Build issue body
      issue_body="## Claude Templates Drift Detected

The \`$claude_md_path\` in this repo appears to have drifted from the canonical \`$template\` template in [bh679/claude-templates](https://github.com/bh679/claude-templates)."

      if [ ${#missing[@]} -gt 0 ]; then
        missing_list=$(printf '- `%s`\n' "${missing[@]}")
        issue_body+="

### Missing Fingerprints

$missing_list"
      fi

      if [ ${#outdated_standards[@]} -gt 0 ]; then
        outdated_list=$(printf '- `%s`\n' "${outdated_standards[@]}")
        issue_body+="

### Outdated Standards

$outdated_list

Update these standards by re-resolving the \`{{STANDARD:...}}\` tokens from the latest [standards/](https://github.com/bh679/claude-templates/tree/main/standards)."
      fi

      issue_body+="

### What to Do

1. Review the latest template: [\`templates/$template/CLAUDE.md\`](https://github.com/bh679/claude-templates/blob/main/templates/$template/CLAUDE.md)
2. Review the relevant standards docs: [standards/](https://github.com/bh679/claude-templates/tree/main/standards)
3. Address the issues listed above
4. Re-run \`install-hooks.sh\` to update any copied git hooks
5. Close this issue once updated

*Opened automatically by the claude-templates drift detection workflow.*"

      gh issue create \
        --repo "$repo" \
        --title "⚠️ CLAUDE.md drift detected — standards outdated" \
        --label "claude-template-drift" \
        --body "$issue_body"

      echo "  → Opened drift issue in $repo"
      ISSUES_OPENED=$((ISSUES_OPENED + 1))
    fi
  fi
done

echo ""
echo "Drift check complete. Issues opened: $ISSUES_OPENED"
