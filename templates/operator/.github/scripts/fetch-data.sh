#!/bin/bash
# fetch-data.sh
# Gathers input data for {{AGENT_NAME}} before Claude runs.
# Called by the GitHub Actions workflow; runs with GITHUB_TOKEN in environment.
#
# Usage: bash .github/scripts/fetch-data.sh
# Requires: gh CLI (authenticated via GITHUB_TOKEN), jq
#
# Output: write data files to the working directory so Claude can read them.
# Example: gh api /repos/... > /tmp/data.json

set -e

echo "Fetching data for {{AGENT_NAME}}..."

# TODO: replace with real data fetching
# Example:
#   gh api /repos/bh679/my-repo/events > /tmp/github-events.json
#   echo "Fetched $(jq length /tmp/github-events.json) events"

echo "Done."
