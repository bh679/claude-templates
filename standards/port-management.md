<!-- standard: port-management | version: 1.2.0 -->
# Port Management Standard

> **Source of truth** for dev-server port allocation across all Claude-powered projects.

## How It Works

Each session claims a unique port starting from the project's `BASE_PORT` (set in `.env` or via the `{{BASE_PORT}}` template token). Claims are stored in `~/.claude/ports/` so all projects share the same view.

**Claim a port** (session start):
```bash
mkdir -p ~/.claude/ports
# Find first free port: start at BASE_PORT, increment until no claim file matches
grep -l '"port": <port>' ~/.claude/ports/*.json 2>/dev/null
# Write claim
echo '{"port": <port>, "project": "<slug>", "session": "<id>", "feature": "<feature>"}' \
  > ~/.claude/ports/<session-id>.json
```

**Release a port** (session end):
```bash
rm ~/.claude/ports/<session-id>.json
```

## Stale Claims

If a port is claimed but nothing is listening, the claim is stale — ignore or delete it:
```bash
lsof -i :<port> | grep LISTEN
```
