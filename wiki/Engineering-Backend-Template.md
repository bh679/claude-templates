[Home](Home) > [Features](Features) > Engineering Backend Template

# Engineering Backend Template

Backend API development template with the three-gate workflow, HTTP diagnostics, and endpoint documentation support.

## How It Works

Extends the product template with backend-specific additions:

- Optional HTTP diagnostics standard (health endpoint, error logging, usage tracking, bug snapshots)
- Endpoint documentation templates for the wiki
- Additional tokens for API base path, database type, and test commands

### Files Included

```
templates/engineering/backend/
├── CLAUDE.md              — Main instructions (product base + backend extensions)
├── .claude/settings.json  — Tool permissions (shared with product)
```

### Additional Tokens

| Token | Example | Description |
|---|---|---|
| `{{API_BASE_PATH}}` | /api/v1 | Base path prefix for all endpoints |
| `{{DB_TYPE}}` | PostgreSQL | Database technology |
| `{{TEST_COMMAND}}` | npm test | Automated test command |

## Related

- [Engineering Product Template](Engineering-Product-Template)
- [HTTP Diagnostics Standard](HTTP-Diagnostics-Standard)
- [Token System](Token-System)
