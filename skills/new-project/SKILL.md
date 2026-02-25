---
name: new-project
description: >
  Bootstrap a new project using claude-templates standards and templates.
  Use when the user says "set up a new project", "create a new repo",
  "start a new project", "bootstrap a project", "new project",
  "new git repo", "new GitHub repo", or wants to initialise a project
  from a template.
---

# New Project Setup

This skill bootstraps a new project by reading and following the canonical
setup manual. It does NOT contain the setup steps itself — the source of
truth is `standards/new-project-setup.md`.

## When to Use

- When the user wants to create a new project, repo, or GitHub repository
- When the user asks to bootstrap or initialise a project from a template
- At the very start of a new project before any code has been written

## Pre-Checks

Before starting, verify:

1. **claude-templates repo is available:**
   ```bash
   ls ~/Projects/Claude\ Templates/standards/new-project-setup.md
   ```
   If not found, tell the user to clone `bh679/claude-templates` to `~/Projects/Claude Templates/`.

2. **Skills are installed:**
   ```bash
   ls ~/.claude/skills/new-project/SKILL.md
   ```
   If this skill is running, skills are already installed. But if other skills
   (like `trigger-blog`) are missing, suggest running:
   ```bash
   cd ~/Projects/Claude\ Templates && ./install-skills.sh
   ```

## Steps

1. **Read the setup manual:**
   ```
   Read ~/Projects/Claude Templates/standards/new-project-setup.md
   ```

2. **Follow it step by step**, starting from Step 1 (Choose a Template Type).

   If the user has not already specified a template type, ask which applies:
   - **Product Engineer** — multi-repo project (client, API, wiki)
   - **Operator** — scheduled/automated agent
   - **Repo** — individual sub-repo within an existing project
   - **None** — plain repo, no template

3. **Continue through all steps** in the manual sequentially, collecting token
   values, copying files, setting up GitHub, registering the consumer, and
   running verification.

## Error Handling

- **Template type not specified:** Ask the user before proceeding
- **Token value unknown:** Ask the user — do not guess or use placeholder values
- **`gh` CLI not authenticated:** Run `gh auth status` and guide the user through login
- **Template file missing:** Verify the claude-templates repo is up to date (`git pull`)
- **`npm install` fails:** Show the error and let the user resolve dependency issues

## Output Format

After completing all steps, report a summary:

```
New project setup complete

Project: {{PROJECT_NAME}}
Template: Product Engineer | Operator | Repo | None
Repos created: {{list}}
Consumer registered: Yes / No
Skills installed: Yes / No
Verification: All checks passed / Issues found (list)
```
