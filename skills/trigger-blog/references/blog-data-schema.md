# Blog Data Schema — pending-context.json

This document defines the structure written to `pending-context.json` in the
`bh679/weekly-blog` repo when the `trigger-blog` skill queues a feature for the
Monday blog agent.

---

## Schema

```json
{
  "queued_at": "2025-03-10T14:22:00Z",
  "project": "Chess",
  "feature": {
    "name": "User Authentication",
    "slug": "user-authentication",
    "description": "Added JWT-based login and registration with email verification.",
    "pr_url": "https://github.com/bh679/chess-client/pull/42",
    "pr_number": 42,
    "merged_at": "2025-03-10T14:00:00Z",
    "wiki_url": "https://github.com/bh679/chess-client/wiki/User-Authentication"
  },
  "screenshots": [
    {
      "path": "test-results/gate2-user-authentication-2025-03.png",
      "description": "Login screen with validation errors shown"
    },
    {
      "path": "test-results/gate2-user-authentication-success-2025-03.png",
      "description": "Successful login and redirect to game board"
    }
  ],
  "commits": [
    "feat: add JWT authentication middleware",
    "feat: add registration and login endpoints",
    "feat: add email validation",
    "version: bump to V1.03.0000"
  ],
  "framing": "This feature unlocks persistent user accounts, which is the foundation for all leaderboard and social features planned for the next milestone."
}
```

---

## Field Descriptions

| Field | Required | Description |
|---|---|---|
| `queued_at` | Yes | ISO 8601 timestamp when the skill ran |
| `project` | Yes | Human-readable project name |
| `feature.name` | Yes | Human-readable feature name |
| `feature.slug` | Yes | Kebab-case identifier |
| `feature.description` | Yes | 1-2 sentence summary of what was built |
| `feature.pr_url` | Yes | Full GitHub PR URL |
| `feature.pr_number` | Yes | PR number (integer) |
| `feature.merged_at` | Yes | ISO 8601 merge timestamp |
| `feature.wiki_url` | No | Link to wiki documentation page if created |
| `screenshots` | No | Array of screenshot objects (path + description) |
| `commits` | Yes | Array of commit messages from the feature branch |
| `framing` | No | Your framing of why this feature matters — used by the blog agent to write with intent rather than just summarising commits |

---

## File Location

The `pending-context.json` file lives in the root of the `bh679/weekly-blog` repo.

- If the file doesn't exist: create it with an array containing the new entry
- If the file exists: read it, append the new entry to the array, write it back

```json
[
  { ... entry 1 ... },
  { ... entry 2 ... }
]
```

The Monday blog agent reads this file, incorporates the context into the blog post,
then deletes or clears the file after use.

---

## Immediate Trigger (Optional)

If the user requests an immediate post (not Monday's queue), the skill runs:

```bash
gh workflow run weekly-blog.yml --repo bh679/weekly-blog
```

This triggers the existing GitHub Action immediately. The pending-context.json
queued entry will still be present and picked up by the run.
