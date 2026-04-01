#!/usr/bin/env bash
# hook-version: 1.1.0
# pre-commit-version-check.sh
HOOK_VERSION="1.1.0"
#
# Pre-commit hook that enforces the V.MM.PPPP versioning standard
# and auto-bumps skill versions when SKILL.md content changes.
#
# Checks:
#   1. Auto-bumps skill SKILL.md patch versions when content changes (if skills/ exists)
#   2. package.json version was bumped compared to the previous commit
#   3. Version matches V.MM.PPPP format (V integer, MM 2-digit zero-padded, PPPP 4-digit zero-padded)
#
# Usage: Copy or symlink into .git/hooks/pre-commit
#        or use install-hooks.sh to install automatically.

set -euo pipefail

# --- Helpers ---
red()   { printf '\033[1;31m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
dim()   { printf '\033[2m%s\033[0m\n' "$*"; }

# --- Skill version auto-bump ---
# Only runs if skills/ directory exists (i.e. in the claude-templates repo)
if [ -d "skills" ] && git rev-parse HEAD > /dev/null 2>&1; then
    SKILLS_BUMPED=0
    MANIFEST_SCRIPT=".github/scripts/build-skills-manifest.sh"

    # Extract version from SKILL.md YAML frontmatter
    _skill_version() {
        local in_fm=false
        while IFS= read -r line; do
            if [ "$line" = "---" ]; then
                if [ "$in_fm" = true ]; then break; fi
                in_fm=true; continue
            fi
            if [ "$in_fm" = true ] && echo "$line" | grep -qE '^version:'; then
                echo "$line" | sed 's/^version: *//; s/ *$//'
                return
            fi
        done
    }

    # Bump patch component of a SemVer string (e.g. 1.2.3 → 1.2.4)
    _bump_patch() {
        local v="$1"
        local major minor patch
        major="${v%%.*}"
        local rest="${v#*.}"
        minor="${rest%%.*}"
        patch="${rest#*.}"
        echo "${major}.${minor}.$((patch + 1))"
    }

    while IFS= read -r skill_file; do
        [ -n "$skill_file" ] || continue
        [ -f "$skill_file" ] || continue
        skill_name=$(echo "$skill_file" | sed 's|skills/||; s|/SKILL.md||')

        # Get staged version
        current_ver=$(git show :"$skill_file" 2>/dev/null | _skill_version)
        [ -n "$current_ver" ] || continue

        # Get HEAD version
        head_ver=$(git show HEAD:"$skill_file" 2>/dev/null | _skill_version)
        [ -n "$head_ver" ] || continue  # new skill — skip

        # Already bumped manually? Skip.
        [ "$current_ver" = "$head_ver" ] || continue

        # Check if content changed beyond the version line
        # Use diff on filtered content via process substitution
        if diff -q \
            <(git show HEAD:"$skill_file" 2>/dev/null | sed '/^version:/d') \
            <(git show :"$skill_file" 2>/dev/null | sed '/^version:/d') \
            >/dev/null 2>&1; then
            continue  # no content change
        fi

        # Content changed, version not bumped — auto-bump patch
        new_ver=$(_bump_patch "$current_ver")
        sed -i.bak "s/^version: *${current_ver}/version: ${new_ver}/" "$skill_file"
        rm -f "${skill_file}.bak"
        git add "$skill_file"
        SKILLS_BUMPED=$((SKILLS_BUMPED + 1))
        green "Auto-bumped $skill_name: $current_ver → $new_ver"
    done < <(git diff --cached --name-only -- 'skills/*/SKILL.md' 2>/dev/null)

    # Regenerate manifest if any skills were bumped
    if [ "$SKILLS_BUMPED" -gt 0 ] && [ -x "$MANIFEST_SCRIPT" ]; then
        bash "$MANIFEST_SCRIPT" skills .github/scripts/skills-versions.json 2>/dev/null
        git add .github/scripts/skills-versions.json
        green "Regenerated skills-versions.json ($SKILLS_BUMPED skill(s) bumped)"
    fi
fi

# --- Configuration ---
PACKAGE_JSON="package.json"
# Regex: integer DOT 2-digit-zero-padded DOT 4-digit-zero-padded
VERSION_REGEX='^[0-9]+\.[0-9]{2}\.[0-9]{4}$'

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
