---
name: update-skills
version: 1.0.0
description: >
  Check for skill updates and install the latest versions from claude-templates.
  Use when the user says "update skills", "check for skill updates",
  "are my skills up to date", "refresh skills", or "install latest skills".
---

# Update Skills

This skill checks installed Claude skills against the latest versions in the
claude-templates repo and updates them if needed.

## When to Use

- When the user asks to update or refresh their skills
- When the user wants to check if skills are up to date
- After pulling the latest claude-templates changes

## Pre-Check

Verify the claude-templates repo exists locally:
```bash
ls ~/Projects/Claude\ Templates/skills/ 2>/dev/null
```
If not found, ask the user for the path to their claude-templates repo.

---

## Step 1 — Pull Latest from claude-templates

```bash
cd ~/Projects/Claude\ Templates && git pull origin main
```

If there are local changes, warn the user and ask whether to stash or skip the pull.

---

## Step 2 — Check Installed Versions

Run the version check script:
```bash
cd ~/Projects/Claude\ Templates && .github/scripts/check-skill-versions.sh
```

This compares installed skill versions (`~/.claude/skills/*/SKILL.md`) against
the latest manifest (`.github/scripts/skills-versions.json`).

Report the output to the user. If everything is up to date, stop here.

---

## Step 3 — Install Updates

If any skills are outdated or missing, run the installer:
```bash
cd ~/Projects/Claude\ Templates && ./install-skills.sh
```

This refreshes symlinks for all skills (existing symlinks are replaced,
new skills get new symlinks).

---

## Step 4 — Verify

Run the version check again to confirm all skills are current:
```bash
cd ~/Projects/Claude\ Templates && .github/scripts/check-skill-versions.sh
```

---

## Error Handling

- **claude-templates repo not found:** Ask the user for the correct path
- **git pull fails (merge conflicts):** Show the error, ask the user to resolve manually
- **Permission denied on symlink:** Check if `~/.claude/skills/` exists and is writable
- **Skill directory exists (not a symlink):** Warn the user — they must remove the directory manually before the symlink can replace it

## Output Format

```
Skills update complete

Updated: new-project v1.0.0 → v1.1.0, trigger-blog v1.0.0 → v1.2.0
Already current: update-skills v1.0.0
New: example-skill v1.0.0

All 4 skills up to date.
```
