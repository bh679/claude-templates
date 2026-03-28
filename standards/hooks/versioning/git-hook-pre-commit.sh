#!/usr/bin/env bash
# pre-commit-version-check.sh
HOOK_VERSION="1.0.0"
#
# Pre-commit hook that enforces the V.MM.PPPP versioning standard.
# See standards/versioning.md for format details.
#
# Checks:
#   1. package.json version was bumped compared to the previous commit
#   2. Version matches V.MM.PPPP format (V integer, MM 2-digit zero-padded, PPPP 4-digit zero-padded)
#
# Usage: Copy or symlink into .git/hooks/pre-commit
#        or use install-hooks.sh to install automatically.

set -euo pipefail

# --- Configuration ---
PACKAGE_JSON="package.json"
# Regex: integer DOT 2-digit-zero-padded DOT 4-digit-zero-padded
VERSION_REGEX='^[0-9]+\.[0-9]{2}\.[0-9]{4}$'

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }

# --- Pre-flight ---
# Skip if package.json is not tracked or not being committed
if ! git diff --cached --name-only | grep -q "^${PACKAGE_JSON}$"; then
    # package.json isn't staged — check if it even exists in HEAD
    if git show HEAD:"${PACKAGE_JSON}" > /dev/null 2>&1; then
        red "ERROR: package.json was not modified in this commit."
        red "Every commit must bump the version (PPPP at minimum)."
        dim "Format: V.MM.PPPP — see standards/versioning.md"
        dim ""
        dim "  Current version: $(git show HEAD:${PACKAGE_JSON} | grep '"version"' | head -1 | sed 's/.*: *"//;s/".*//')"
        dim ""
        dim "Bump the patch number and stage package.json, then retry."
        exit 1
    else
        # No package.json in the repo yet — first commit, skip check
        exit 0
    fi
fi

# --- Extract versions ---
# Current (staged) version
CURRENT_VERSION=$(git show :"${PACKAGE_JSON}" | grep '"version"' | head -1 | sed 's/.*: *"//;s/".*//')

# Previous (HEAD) version — empty string if this is the first commit
if git rev-parse HEAD > /dev/null 2>&1; then
    PREVIOUS_VERSION=$(git show HEAD:"${PACKAGE_JSON}" 2>/dev/null | grep '"version"' | head -1 | sed 's/.*: *"//;s/".*//' || echo "")
else
    PREVIOUS_VERSION=""
fi

# --- Validate format ---
if ! echo "${CURRENT_VERSION}" | grep -qE "${VERSION_REGEX}"; then
    red "ERROR: Invalid version format in package.json."
    red "  Found:    \"${CURRENT_VERSION}\""
    red "  Expected: V.MM.PPPP (e.g. 1.02.0015)"
    dim ""
    dim "Rules:"
    dim "  V    = integer (no leading zeros unless V=0)"
    dim "  MM   = 2-digit zero-padded (01, 02, ..., 99)"
    dim "  PPPP = 4-digit zero-padded (0000, 0001, ..., 9999)"
    dim ""
    dim "See standards/versioning.md for details."
    exit 1
fi

# --- Compare versions ---
if [ -n "${PREVIOUS_VERSION}" ] && [ "${CURRENT_VERSION}" = "${PREVIOUS_VERSION}" ]; then
    red "ERROR: Version was not bumped."
    red "  Previous: ${PREVIOUS_VERSION}"
    red "  Current:  ${CURRENT_VERSION}"
    dim ""
    dim "Every commit must bump the version (PPPP at minimum)."
    dim "Format: V.MM.PPPP — see standards/versioning.md"
    dim ""
    dim "Example: ${PREVIOUS_VERSION} -> $(echo "${PREVIOUS_VERSION}" | awk -F. '{printf "%s.%s.%04d", $1, $2, $3+1}')"
    exit 1
fi

green "Version check passed: ${PREVIOUS_VERSION:-"(initial)"} -> ${CURRENT_VERSION}"
exit 0
