[Home](Home) > [Features](Features) > HTTP Diagnostics Standard

# HTTP Diagnostics Standard

Observability requirements for HTTP backend services, covering health checks, error logging, usage tracking, and bug context snapshots.

## How It Works

Every HTTP backend exposes four capabilities:

### 1. Health Endpoint

`GET /health` — unauthenticated, fast (<100ms), no external calls. Returns status, version, uptime, and timestamp. HTTP 200 when healthy, 503 when degraded.

### 2. Error Logging

Structured errors written to `./diagnostics/errors.jsonl` in append-only JSONL format. Each entry includes timestamp, level, message, stack trace, and context (env, version, runtime, request ID).

### 3. Usage Tracking

Structured events written to `./diagnostics/usage.jsonl`. Tracks meaningful actions (logins, API calls, feature usage) with dot-separated event names.

### 4. Bug Context Snapshots

Full-context dumps on unhandled errors, written to `./diagnostics/snapshots/`. Each snapshot captures the error, environment, dependency versions, recent events, and system metrics. Deduplicated by hash within a 5-minute window.

## Technical Notes

- Current version: 1.0.0
- Log rotation: 10 MB per file, 3 rotated files retained
- Snapshots: delete files older than 30 days
- Non-filesystem deployments: write to stdout or logging service
- Gate 2 verification: `curl -s http://localhost:<port>/health | jq .`

## Related

- [Engineering Backend Template](Engineering-Backend-Template)
- [Standards](Standards)
