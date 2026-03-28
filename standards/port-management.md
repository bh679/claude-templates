<!-- standard: port-management | version: 1.1.1 -->
# Port Management Standard

> **Source of truth** for dev-server port allocation across all Claude-powered projects.

---

## Overview

Each development session claims a unique port to avoid conflicts when multiple features or services run simultaneously — **across all projects on the local machine**. Claims are stored in `~/.claude/ports/` so every project shares the same view of which ports are in use.

---

## Port Claiming

Each session writes a claim file to `~/.claude/ports/<session-id>.json`:

```bash
mkdir -p ~/.claude/ports
echo '{"port": <port>, "project": "<project-slug>", "session": "<session-id>", "feature": "<feature-slug>"}' > ~/.claude/ports/<session-id>.json
```

**Allocation algorithm:**
1. Start at the project's `BASE_PORT`
2. Check whether that port is already claimed:
   ```bash
   grep -l '"port": <port>' ~/.claude/ports/*.json 2>/dev/null
   ```
3. If any file matches, increment by 1 and repeat from step 2
4. Write the claim file with the first free port found

---

## Port Release

On session end, remove the claim file:

```bash
rm ~/.claude/ports/<session-id>.json
```

---

## Project Configuration

Each project defines its `BASE_PORT` in `.env` or the project's config:

```
BASE_PORT=3000
```

Templates use the `{{BASE_PORT}}` token, which is filled in at project bootstrap time.

---

## Stale Claims

Claim files left behind by crashed sessions are stale. Before incrementing past an occupied port, verify the owning process is still running:

```bash
# Check if a port is actually in use
lsof -i :<port> | grep LISTEN
```

If the port is not listening, the claim is stale and can be ignored (or deleted).

---

## Summary

| Step | Action |
|---|---|
| Session start | Find first free port from `BASE_PORT`, write `~/.claude/ports/<session-id>.json` |
| Dev server start | Use the claimed port |
| Session end | Delete `~/.claude/ports/<session-id>.json` |
| Stale detection | `lsof -i :<port>` — if not listening, claim is stale |
