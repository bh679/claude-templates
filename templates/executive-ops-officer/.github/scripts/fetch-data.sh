#!/bin/bash
# fetch-data.sh
# Gathers input data for the Executive & Operations Officer before Claude runs.
# Called by the GitHub Actions workflow; runs with GITHUB_TOKEN in environment.
#
# Usage: bash .github/scripts/fetch-data.sh
# Requires: gh CLI (authenticated via GH_TOKEN), jq
#
# Outputs written to /tmp/:
#   projects-data.json   — GitHub Projects V2 cards + status per repo
#   pr-data.json         — Open PRs with age in days per repo
#   workflow-data.json   — GitHub Actions run results (last 24 h) per repo

set -e

REPOS=$(jq -r '.repos[]' ops-config.json)
STALE_ITEM_DAYS=$(jq -r '.thresholds.stale_item_days // 5' ops-config.json)
STALE_PR_DAYS=$(jq -r '.thresholds.stale_pr_days // 3' ops-config.json)
NOW=$(date -u +%s)

echo "Fetching data for Executive & Operations Officer..."
echo "Repos: $(echo "$REPOS" | tr '\n' ' ')"
echo "Thresholds: stale_item=${STALE_ITEM_DAYS}d, stale_pr=${STALE_PR_DAYS}d"

# ── Projects V2 ──────────────────────────────────────────────────────────────
echo "[]" > /tmp/projects-data.json

for REPO in $REPOS; do
  OWNER=$(echo "$REPO" | cut -d'/' -f1)
  REPO_NAME=$(echo "$REPO" | cut -d'/' -f2)

  echo "  Fetching Projects V2 for $REPO..."

  # Get project IDs linked to this repo
  PROJECT_IDS=$(gh api graphql -f query='
    query($owner: String!, $repo: String!) {
      repository(owner: $owner, name: $repo) {
        projectsV2(first: 10) {
          nodes { id number title }
        }
      }
    }
  ' -f owner="$OWNER" -f repo="$REPO_NAME" \
    --jq '.data.repository.projectsV2.nodes[] | {id, number, title}' 2>/dev/null || echo "")

  if [ -z "$PROJECT_IDS" ]; then
    echo "    No Projects V2 found for $REPO"
    continue
  fi

  # For each project, fetch items (In Progress / Todo status only)
  while IFS= read -r PROJECT; do
    PROJECT_ID=$(echo "$PROJECT" | jq -r '.id')
    PROJECT_TITLE=$(echo "$PROJECT" | jq -r '.title')

    ITEMS=$(gh api graphql -f query='
      query($projectId: ID!) {
        node(id: $projectId) {
          ... on ProjectV2 {
            items(first: 50) {
              nodes {
                id
                updatedAt
                fieldValues(first: 10) {
                  nodes {
                    ... on ProjectV2ItemFieldSingleSelectValue {
                      name
                      field { ... on ProjectV2SingleSelectField { name } }
                    }
                    ... on ProjectV2ItemFieldTextValue {
                      text
                      field { ... on ProjectV2Field { name } }
                    }
                  }
                }
                content {
                  ... on Issue { title number url }
                  ... on PullRequest { title number url }
                  ... on DraftIssue { title }
                }
              }
            }
          }
        }
      }
    ' -f projectId="$PROJECT_ID" \
      --jq "[.data.node.items.nodes[] | {
        id,
        updatedAt,
        title: (.content.title // \"(no title)\"),
        number: (.content.number // null),
        url: (.content.url // null),
        status: (.fieldValues.nodes[] | select(.field.name == \"Status\") | .name) // \"Unknown\",
        repo: \"$REPO\",
        project: \"$PROJECT_TITLE\"
      }]" 2>/dev/null || echo "[]")

    # Calculate staleness for each item
    ANNOTATED=$(echo "$ITEMS" | jq --arg now="$NOW" --arg threshold="$STALE_ITEM_DAYS" '
      map(. + {
        age_days: ((($now | tonumber) - (.updatedAt | fromdateiso8601)) / 86400 | floor),
        is_stale: ((($now | tonumber) - (.updatedAt | fromdateiso8601)) / 86400 | floor) >= ($threshold | tonumber)
      })
    ')

    # Merge into projects-data.json
    jq --argjson new "$ANNOTATED" '. + $new' /tmp/projects-data.json > /tmp/projects-data.tmp.json
    mv /tmp/projects-data.tmp.json /tmp/projects-data.json

  done < <(echo "$PROJECT_IDS")
done

echo "  Wrote $(jq length /tmp/projects-data.json) project items"

# ── Open PRs ─────────────────────────────────────────────────────────────────
echo "[]" > /tmp/pr-data.json

for REPO in $REPOS; do
  echo "  Fetching open PRs for $REPO..."

  PRS=$(gh pr list --repo "$REPO" --state open --json number,title,url,createdAt,author \
    --jq "[.[] | {
      number,
      title,
      url,
      createdAt,
      author: .author.login,
      repo: \"$REPO\",
      age_days: (($NOW - (.createdAt | fromdateiso8601)) / 86400 | floor)
    }]" 2>/dev/null || echo "[]")

  ANNOTATED=$(echo "$PRS" | jq --arg threshold="$STALE_PR_DAYS" '
    map(. + { is_stale: (.age_days >= ($threshold | tonumber)) })
  ')

  jq --argjson new "$ANNOTATED" '. + $new' /tmp/pr-data.json > /tmp/pr-data.tmp.json
  mv /tmp/pr-data.tmp.json /tmp/pr-data.json
done

echo "  Wrote $(jq length /tmp/pr-data.json) open PRs"

# ── Workflow runs (last 24 h) ─────────────────────────────────────────────────
echo "[]" > /tmp/workflow-data.json
CUTOFF=$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
  || date -u -v-24H +%Y-%m-%dT%H:%M:%SZ)  # macOS fallback

for REPO in $REPOS; do
  echo "  Fetching workflow runs for $REPO..."

  RUNS=$(gh run list --repo "$REPO" --limit 20 --json name,status,conclusion,createdAt,url \
    --jq "[.[] | select(.createdAt >= \"$CUTOFF\") | {
      name,
      status,
      conclusion,
      createdAt,
      url,
      repo: \"$REPO\",
      failed: (.conclusion == \"failure\" or .conclusion == \"timed_out\")
    }]" 2>/dev/null || echo "[]")

  jq --argjson new "$RUNS" '. + $new' /tmp/workflow-data.json > /tmp/workflow-data.tmp.json
  mv /tmp/workflow-data.tmp.json /tmp/workflow-data.json
done

echo "  Wrote $(jq length /tmp/workflow-data.json) workflow runs"

echo "Done."
