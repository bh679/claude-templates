# Plan: Runtime Diagnostics Standard + Backend Template Integration

## Context

Backend services need structured observability — health checks, error logs, usage events, and bug context snapshots. Without these, debugging deployed features requires manual investigation with no structured data.

This plan creates a **standalone standard** (`standards/runtime-diagnostics.md`) consumed by the backend engineer template via `{{STANDARD:runtime-diagnostics}}`.

---

## Completed Changes

### 1. `standards/runtime-diagnostics.md` (NEW — v1.0.0)

Standalone standard defining four capabilities for HTTP backend services:
- **Health endpoint** — `GET /health` returning status, version, uptime, timestamp
- **Error logging** — structured JSONL to `./diagnostics/errors.jsonl`
- **Usage tracking** — structured events to `./diagnostics/usage.jsonl`
- **Bug context snapshots** — full-context dumps to `./diagnostics/snapshots/`

Includes inline JSON schemas, filesystem conventions, log rotation (10MB, keep 3), and non-filesystem deployment guidance.

### 2. `templates/engineering/backend/CLAUDE.md` (MODIFIED)

- Added `{{STANDARD:runtime-diagnostics}}` token before Additional Key Rules
- Added health check verification step to Gate 2 (`curl -s http://localhost:<port>/health | jq .`)
- Added health check response JSON to Gate 2 Testing Report

---

## Not in scope

- Product engineer template (no runtime diagnostics needed)
- Operator template (no HTTP service)
- Unit testing (separate effort)

---

## Verification

1. Read `standards/runtime-diagnostics.md` — confirm version header, all 4 sections, inline schemas
2. Read `templates/engineering/backend/CLAUDE.md` — confirm STANDARD token and Gate 2 health check
3. Run drift check: `bash .github/scripts/check-drift.sh`
