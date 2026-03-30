<!-- standard: port-management | version: 1.2.0 -->
# Port Management Standard

Dev-server port allocation across all Claude-powered projects. Claims are stored in `~/.claude/ports/` so every project shares the same view.

## Configuration
Set `BASE_PORT` in `.env` (templates use `{{BASE_PORT}}` token, filled at bootstrap):

```
BASE_PORT=3000
```

## Lifecycle
| Step | Command |
|---|---|
| **Claim** — find first free port from `BASE_PORT` | `mkdir -p ~/.claude/ports && echo '{"port": <port>, "project": "<slug>", "session": "<id>", "feature": "<feature>"}' > ~/.claude/ports/<session-id>.json` |
| **Use** — start dev server on claimed port | (use the claimed port) |
| **Release** — on session end | `rm ~/.claude/ports/<session-id>.json` |

**Allocation:** Starting at `BASE_PORT`, scan `~/.claude/ports/*.json` for conflicts. Increment until a free port is found, then write the claim file.

**Stale claims:** If a claim file exists but `lsof -i :<port> | grep LISTEN` shows nothing, the claim is stale — ignore or delete it.
