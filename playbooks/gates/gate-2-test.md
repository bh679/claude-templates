<!-- gate: gate-2-test | version: 1.2.0 -->
# Gate 2 — Testing Approval

**Trigger:** After isolated implementation is complete.

**Project-specific steps:** check the project for `.claude/gates/gate-2-test.md`. If it exists, read it
and follow it as well: it adds to this playbook, and wins where the two conflict.

## Agent Actions
1. Run unit tests — verify 80%+ line coverage (see unit-testing standard)
2. Run integration/e2e tests (curl for APIs, Playwright MCP for UI)
3. Take screenshots with the project's capture method (web UI: `browser_take_screenshot`; other apps:
   the project's Gate 2 add-on says how)
4. Web UI: use `browser_snapshot` for accessibility tree analysis
5. **UI changes: show the screenshots in chat as rendered images**, before the report — send each
   one with the host's file-sending tool (for example `SendUserFile` with `display: "render"`),
   one caption line each. A path or link alone does not count.
6. Enter plan mode and present a **Gate 2 Testing Report**, structured per `~/.claude/playbooks/plan-presentation.md` § Gate 2 / 3 / 4, containing:
   - Clickable local URL with port (web projects)
   - Unit test summary: total, passed, failed, skipped, coverage %
   - Screenshots: confirm they were shown in chat; list paths (for blogging)
   - Step-by-step user testing instructions
   - Integration/e2e test results summary
   - What passed / what failed

**Gate requirement:** User tests manually and clicks Approve.

## Screenshot Naming
```
gate2-<feature-slug>-<timestamp>.png
```

Save in `./test-results/`.

## Related Playbooks
- Before writing the report, read `~/.claude/playbooks/plan-presentation.md`.
- Before starting dev servers, read `~/.claude/playbooks/port-management.md`.

## Session Title Update
Update title to: `TEST - <Task Name> - <Project Name>`
