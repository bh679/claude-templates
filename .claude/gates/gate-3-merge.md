<!-- gate: gate-3-merge | version: 1.1.0 -->
# Gate 3 — Merge Approval

**Trigger:** After user testing passes Gate 2.

## Agent Actions

1. Ensure branch is up to date with `main` _(enforced by hook — will block `gh pr create` if behind)_
2. Create a PR with a clear title and description
3. Enter plan mode and present:
   - File diff summary (which files changed, what changed)
   - PR link
   - Any breaking changes or migration steps
4. Wait for approval

**Gate requirement:** User clicks Approve, then agent merges the PR.

**Never merge without Gate 3 approval.** Not even for hotfixes.

---

## Post-Merge Cleanup (mandatory)

1. Delete the remote feature branch (`git push origin --delete dev/<slug>`)
2. Delete the local feature branch (`git branch -d dev/<slug>`)
3. If continuing work, create a new branch (`git checkout -b dev/<next-slug>`)

See `git.md` § Post-Merge Cleanup for worktree variants.

---

## After Merge: Documentation

Update the relevant wiki:
- **Frontend/client features** → project wiki
- **Backend/API features** → API repo wiki
- **Deployment-impacting changes** → update `Deployment-*.md` wiki pages
- Follow the wiki-writing standard for structure:

<!-- standard: wiki-writing | version: 1.1.0 -->
# Wiki Writing Standard

> **Source of truth** for documentation style across all project wikis.

---

## Breadcrumbs

Every wiki page (except Home) starts with a breadcrumb trail:

```markdown
[Home](Home) > [Features](Features) > Current Page Title
```

Rules:
- Use wiki-relative links (no `.md` extension, no full URL)
- The current page name is plain text — not a link
- Breadcrumbs go on the very first line, before the `#` heading

---

## Page Structure

```markdown
[Home](Home) > [Section](Section) > Page Title

# Page Title

Brief one-sentence description of what this page covers.

## Overview
...

## Details
...

## Related
- [Related Page](Related-Page)
```

---

## Heading Levels

- `#` — Page title (one per page)
- `##` — Major sections
- `###` — Subsections
- Never skip levels (no jumping from `#` to `###`)
- Headings must be self-explanatory — a reader scanning only headings should understand the page's content without reading body text

---

## Links

### Wiki-Internal Links

Use wiki link syntax — page name with hyphens replacing spaces, no `.md` extension:

```markdown
[User Authentication](User-Authentication)
[API Reference](API-Reference)
```

### External Links

Full URLs in standard markdown:

```markdown
[GitHub Repo](https://github.com/bh679/chess-project)
```

### Never use

- Relative file paths (`./features/auth.md`)
- Full GitHub wiki URLs for internal links (breaks portability)

---

## Images

### Screenshot Naming

```
<feature-slug>-<context>-<date>.png
```

Examples:
- `user-auth-login-screen-2025-01.png`
- `board-score-calculation-2025-03.png`

### Embedding Images

```markdown
![Alt text describing the image](images/feature-slug-context-date.png)
```

Always include descriptive alt text.

### Image Storage

Store images in the wiki repo's `images/` directory (create if absent).

---

## Feature Documentation Template

Use this structure when documenting a shipped feature:

```markdown
[Home](Home) > [Features](Features) > Feature Name

# Feature Name

Brief description of what the feature does and why it exists.

## How It Works

Step-by-step explanation of the user flow or technical mechanism.

## Screenshots

![Description](images/feature-name-screenshot.png)

## Technical Notes

Any implementation details worth preserving (API endpoints, data structures, etc.)

## Related

- [Related Feature](Related-Feature)
- [API Docs](API-Reference)
```

---

## Roadmap Feature Template

Use this structure for planned (not yet shipped) features:

```markdown
## Feature Name

**Status:** Planned / In Progress / Done
**Priority:** High / Medium / Low

Brief description of the planned feature.

### Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

### Notes

Any design decisions or open questions.
```

---

## Deployment Documentation Template

### Deployment Index Page

Use this structure for the deployment index page (`Deployment.md`):

```markdown
[Home](Home) > Deployment

# Deployment

All deployment methods for {{PROJECT_NAME}}.

| Method | Environment | Status |
|---|---|---|
| [Method Name](Deployment-Method-Name) | Production / Staging / Both | Active / Deprecated |
```

### Deployment Method Page

Use this structure for each deployment method (`Deployment-<Method>.md`):

```markdown
[Home](Home) > [Deployment](Deployment) > Method Name

# Deployment — Method Name

Brief one-sentence description of this deployment method and when to use it.

## Prerequisites

- Prerequisite 1 (e.g., AWS CLI configured, Docker installed)
- Prerequisite 2

## Environment Variables

| Variable | Required | Description | Example |
|---|---|---|---|
| `ENV_VAR` | Yes / No | What it controls | `example-value` |

## Deployment Procedure

Step-by-step instructions to deploy.

1. Step one
2. Step two
3. Step three

## Rollback Procedure

How to revert to the previous version if something goes wrong.

1. Step one
2. Step two

## Health Check

How to verify the deployment succeeded.

- Check 1 (e.g., `curl https://your-live-url.example.com/health`)
- Check 2

## Related

- [Other Deployment Method](Deployment-Other-Method)
- [Feature That Uses This](Feature-Name)
```

---

## Tone and Style

- Write in present tense ("The system validates..." not "The system will validate...")
- Use second person for user instructions ("Click the button" not "The user clicks")
- Avoid jargon unless it's defined elsewhere in the wiki
- Keep sentences short — one idea per sentence
- Use bullet lists for steps and options; prose for explanations

---

## Commit Messages for Wiki Changes

```
docs: add User Authentication feature page
docs: update Roadmap with board score feature
docs: fix broken link on Features index
```

If deployment docs were flagged in Gate 1:
1. Update affected `Deployment-<Method>.md` pages
2. Create new deployment pages if a new method was introduced
3. Update `Deployment.md` index if pages were added

Then trigger the blog skill if applicable: `trigger-blog`

---

## Session Title Update

Update title to: `DONE - <Task Name> - <Project Name>`
