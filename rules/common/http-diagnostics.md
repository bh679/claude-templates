<!-- standard: http-diagnostics | version: 1.0.0 -->
# HTTP Diagnostics Standard

## Overview
Every HTTP backend service must expose four diagnostics capabilities:

1. **Health endpoint** — verify the service is running
2. **Error logging** — structured error capture to disk
3. **Usage tracking** — structured event logging
4. **Bug context snapshots** — full-context dumps on unhandled errors

These use the local filesystem by default (`./diagnostics/`). For non-filesystem
deployments (serverless, containers), redirect output to stdout or a logging service.

## 1. Health Endpoint
Expose `GET /health` — unauthenticated, fast (<100ms), no external service calls.

**Response schema:**
```json
{
  "status": "ok",
  "version": "1.2.3",
  "uptime": 3600,
  "timestamp": "2026-03-28T10:00:00.000Z"
}
```

| Field | Type | Description |
|---|---|---|
| `status` | string | `"ok"` when healthy, `"degraded"` or `"error"` otherwise |
| `version` | string | Application version (from package.json, env var, or build) |
| `uptime` | number | Seconds since process start |
| `timestamp` | string | ISO 8601 UTC timestamp of this response |

**Rules:**
- Must return HTTP 200 when healthy, 503 when degraded/error
- Must not require authentication
- Must not call databases, caches, or external APIs
- Gate 2 verification: `curl -s http://localhost:<port>/health | jq .`

## 2. Error Logging
Write structured errors to `./diagnostics/errors.jsonl` — one JSON object per line, append-only.

**Entry schema:**
```json
{
  "timestamp": "2026-03-28T10:00:00.000Z",
  "level": "error",
  "message": "Failed to parse request body",
  "stack": "Error: Failed to parse request body\n    at parse (/app/src/parser.js:42:11)\n    ...",
  "context": {
    "env": "development",
    "version": "1.2.3",
    "gitSha": "a1b2c3d",
    "runtime": "node 20.11.0",
    "requestId": "req-abc-123"
  }
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `timestamp` | string | yes | ISO 8601 UTC |
| `level` | string | yes | `"error"` or `"warn"` |
| `message` | string | yes | Human-readable error description |
| `stack` | string | no | Stack trace if available |
| `context.env` | string | yes | Runtime environment (development, staging, production) |
| `context.version` | string | yes | Application version |
| `context.gitSha` | string | no | Git commit SHA if available |
| `context.runtime` | string | yes | Language and version (e.g. `"node 20.11.0"`, `"python 3.12.1"`) |
| `context.requestId` | string | no | Request correlation ID if applicable |

**Rules:**
- Append-only — never overwrite or truncate the file mid-run
- One JSON object per line (JSONL format) — no pretty-printing
- Log all unhandled exceptions and explicitly caught errors worth tracking
- Never log sensitive data (passwords, tokens, PII) in message or context


## 3. Usage Tracking
Write structured events to `./diagnostics/usage.jsonl` — one JSON object per line.

**Entry schema:**
```json
{
  "event": "user.login",
  "timestamp": "2026-03-28T10:00:00.000Z",
  "metadata": {
    "method": "oauth",
    "provider": "github",
    "durationMs": 342
  }
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `event` | string | yes | Dot-separated event name (e.g. `"user.login"`, `"api.request"`) |
| `timestamp` | string | yes | ISO 8601 UTC |
| `metadata` | object | no | Flexible key-value pairs relevant to this event |

**Rules:**
- Track meaningful actions (logins, API calls, feature usage), not every request
- Use dot-separated naming: `<domain>.<action>` (e.g. `user.signup`, `order.created`)
- Never include PII in metadata
- The implementing engineer decides which events are worth tracking during implementation

---

## 4. Bug Context Snapshots

On unhandled errors, write a full-context dump to `./diagnostics/snapshots/<timestamp>-<hash>.json`.

**Snapshot schema:**

```json
{
  "id": "2026-03-28T10-00-00-000Z-a1b2c3d4",
  "capturedAt": "2026-03-28T10:00:00.000Z",
  "error": {
    "name": "TypeError",
    "message": "Cannot read properties of undefined (reading 'id')",
    "stack": "TypeError: Cannot read properties of undefined...",
    "code": "ERR_UNDEFINED_ACCESS"
  },
  "environment": {
    "env": "development",
    "version": "1.2.3",
    "gitSha": "a1b2c3d",
    "runtime": "node 20.11.0",
    "platform": "linux x64",
    "uptime": 3600
  },
  "dependencies": {
    "express": "4.18.2",
    "pg": "8.11.3"
  },
  "recentEvents": [
    { "event": "api.request", "timestamp": "2026-03-28T09:59:58.000Z" },
    { "event": "db.query", "timestamp": "2026-03-28T09:59:59.000Z" }
  ],
  "system": {
    "memoryUsageMb": 128,
    "cpuPercent": 12.5,
    "diskFreeMb": 4096
  }
}
```

| Section | Description |
|---|---|
| `error` | The error that triggered the snapshot — name, message, stack, code |
| `environment` | Runtime context — env, version, git SHA, platform, uptime |
| `dependencies` | Installed package versions (from lockfile or runtime) |
| `recentEvents` | Last 10 usage events from the usage log |
| `system` | Memory, CPU, and disk at time of capture |

**Filename format:** `<ISO-timestamp>-<first-8-chars-of-error-hash>.json`
- Timestamp uses dashes instead of colons for filesystem safety
- Hash is SHA-256 of `error.name + error.message + error.stack`

**Rules:**
- One snapshot per unhandled error — deduplicate by hash within a 5-minute window
- Include dependency versions so bugs can be correlated with package updates
- Recent events provide the sequence of actions leading to the crash


## Filesystem Conventions

```
./diagnostics/
├── .gitkeep
├── errors.jsonl
├── usage.jsonl
└── snapshots/
    ├── 2026-03-28T10-00-00-000Z-a1b2c3d4.json
    └── ...
```

**Setup:**
1. Create `./diagnostics/` with a `.gitkeep` file
2. Add to `.gitignore`:
   ```
   diagnostics/*.jsonl
   diagnostics/snapshots/
   ```

**Log rotation:**
- Rotate each `.jsonl` file at **10 MB**
- Keep **3 rotated files** (e.g. `errors.jsonl`, `errors.1.jsonl`, `errors.2.jsonl`)
- Oldest file is deleted when a new rotation occurs
- Snapshots: delete files older than 30 days

**Non-filesystem deployments:**
- Serverless / containers without persistent disk: write to stdout as structured JSON
- If a logging service is available (CloudWatch, Datadog, etc.), send there instead
- The schema and field requirements remain the same regardless of output destination
