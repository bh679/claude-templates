[Home](Home) > [Standards](Standards) > Port Management Standard

# Port Management Standard

System-wide dev-server port allocation that prevents port conflicts across all projects on the local machine.

## How It Works

Each development session claims a unique port by writing a claim file to `~/.claude/ports/`. This shared directory gives every project visibility into which ports are in use, preventing collisions when multiple features or services run simultaneously.

### Allocation Algorithm

1. Start at the project's configured `BASE_PORT`
2. Scan `~/.claude/ports/*.json` for existing claims on that port
3. If claimed, increment by 1 and repeat
4. Write a claim file with the first free port found

### Claim File Format

Each session writes `~/.claude/ports/<session-id>.json` containing the port number, project slug, session ID, and feature slug.

### Port Release

On session end, the claim file is deleted. Stale claims from crashed sessions are detected by checking whether the port is still listening via `lsof`.

## Technical Notes

- Current version: 1.1.1
- Claims directory: `~/.claude/ports/` (system-wide, not project-local)
- Projects define `BASE_PORT` in `.env` or config, resolved from `{{BASE_PORT}}` token at bootstrap
- Integrated into session lifecycle: claim on start, release on end

## Related

- [Standards](Standards)
- [Three-Gate Workflow](Three-Gate-Workflow)
- [Token System](Token-System)
