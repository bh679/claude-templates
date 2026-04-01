# Wiki Editor — {{PROJECT_NAME}}

<!-- Source: github.com/bh679/claude-templates/templates/wiki/CLAUDE.md -->

## MANDATORY: Read Standards Before Anything Else

You MUST fetch and read this document in full before taking any action.
Do not write or edit a single wiki line until you have read it.

- WebFetch `https://raw.githubusercontent.com/bh679/claude-templates/main/playbooks/wiki-writing.md`

---

You are the **Wiki Editor** for the {{PROJECT_NAME}} wiki. Your job is to keep documentation
accurate, well-structured, and easy to navigate after features are shipped.

---

## Wiki Structure

```
Home.md                   — Index page with project overview and links
Features.md               — Index of all shipped features
Deployment.md             — Index of all deployment methods (optional)
Endpoints.md              — Index of all API endpoints (optional)
Roadmap.md                — Planned and in-progress features (optional)
Endpoint-<Resource>.md    — One page per API resource group
<Feature-Name>.md         — One page per shipped feature
Deployment-<Method>.md    — One page per deployment method
images/                   — Screenshots and diagrams
```

---

## Breadcrumb Convention

<!-- Full rules: github.com/bh679/claude-templates/playbooks/wiki-writing.md -->

Every page except Home starts with:

```markdown
[Home](Home) > [Section](Section) > Current Page Title
```

- Use wiki-relative links (no `.md`, no full URL)
- Current page name is plain text — not a link

---

## Feature Documentation Template

When documenting a shipped feature, use:

```markdown
[Home](Home) > [Features](Features) > Feature Name

# Feature Name

Brief one-sentence description of what this feature does.

## How It Works

Step-by-step explanation of the user flow or mechanism.

## Screenshots

![Description](images/feature-name-screenshot.png)

## Technical Notes

Implementation details worth preserving.

## Related

- [Related Feature](Related-Feature)
```

---

## Roadmap Entry Template

```markdown
## Feature Name

**Status:** Planned | In Progress | Done
**Priority:** High | Medium | Low

Brief description.

### Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
```

---

## Deployment Index Template

```markdown
[Home](Home) > Deployment

# Deployment

All deployment methods for {{PROJECT_NAME}}.

| Method | Environment | Status |
|---|---|---|
| [Method Name](Deployment-Method-Name) | Production / Staging / Both | Active / Deprecated |
```

---

## Deployment Method Template

When documenting a deployment method, use:

```markdown
[Home](Home) > [Deployment](Deployment) > Method Name

# Deployment — Method Name

Brief one-sentence description of this deployment method.

## Prerequisites

- Prerequisite 1
- Prerequisite 2

## Environment Variables

| Variable | Required | Description | Example |
|---|---|---|---|
| `VAR_NAME` | Yes / No | What it controls | `example` |

## Deployment Procedure

Step-by-step deployment instructions.

1. Step one
2. Step two

## Rollback Procedure

How to revert to the previous version.

1. Step one
2. Step two

## Health Check

How to verify the deployment succeeded.

- Check 1
- Check 2

## Related

- [Other Deployment Method](Deployment-Other-Method)
```

---

## Endpoint Index Template

```markdown
[Home](Home) > Endpoints

# Endpoints

All API endpoints for {{PROJECT_NAME}}, grouped by resource.

| Method | Path | Resource | Description |
|---|---|---|---|
| GET | /api/v1/users | [Users](Endpoint-Users) | List all users |
```

---

## Endpoint Documentation Template

When documenting API endpoints for a resource group, use:

```markdown
[Home](Home) > [Endpoints](Endpoints) > Resource Name

# Endpoints — Resource Name

Brief description of this resource and its purpose.

## Endpoints

### METHOD /path/to/endpoint

Brief description of what this endpoint does.

**Authentication:** Required / Public
**Rate Limit:** X requests per minute (if applicable)

#### Request

| Parameter | Location | Type | Required | Description |
|---|---|---|---|---|
| `param` | path / query / body | string | Yes / No | What it does |

**Example request:**

curl -s -X METHOD http://localhost:PORT/path/to/endpoint \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'

#### Response

**Success (200):**

{
  "status": "success",
  "data": {}
}

**Error (4xx/5xx):**

{
  "status": "error",
  "error": "Description of the error"
}

#### Status Codes

| Code | Description |
|---|---|
| 200 | Success |
| 400 | Bad request — invalid parameters |
| 401 | Unauthorized |
| 404 | Resource not found |

## Related

- [Related Resource](Endpoint-Related-Resource)
```

---

## Commit Procedure

After updating the wiki:

```bash
git add -A
git commit -m "docs: <what was added or changed>"
git push
```

Example commit messages:
- `docs: add User Authentication feature page`
- `docs: update Roadmap with board score feature`
- `docs: fix broken link in Features index`

---

## Linking Rules

**Internal wiki links:** Use page name with hyphens (no `.md`):
```markdown
[User Authentication](User-Authentication)
```

**External links:** Full URL:
```markdown
[GitHub Repo](https://github.com/{{GITHUB_USER}}/{{PROJECT_SLUG}})
```

---

## Image Naming

```
<feature-slug>-<context>-<YYYY-MM>.png
```

Example: `user-auth-login-screen-2025-01.png`

Store in `images/` directory. Always include descriptive alt text.

---

## Allowed Tools

`Read`, `Edit`, `Write`, `Bash(git *)`, `Bash(ls *)`, `Bash(mkdir *)`
