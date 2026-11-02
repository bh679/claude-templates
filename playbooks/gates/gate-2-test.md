<!-- gate: gate-2-test | version: 1.4.0 -->
# Gate 2 — Testing Approval

**Trigger:** After isolated implementation is complete.

**Project-specific steps:** check the project for `.claude/gates/gate-2-test.md`. If it exists, read it
and follow it as well: it adds to this playbook, and wins where the two conflict.

## Agent Actions
1. Run unit tests — verify 80%+ line coverage (see unit-testing standard)
2. Run integration/e2e tests, run the app, and exercise the feature the way a user would
3. **UI or visual change?** Read `~/.claude/playbooks/ui-prototype.md` and follow its Gate 2 steps:
   screenshots rendered in chat before the report.
4. Enter plan mode and present a **Gate 2 Testing Report**, structured per `~/.claude/playbooks/plan-presentation.md` § Gate 2 / 3 / 4, containing:
   - How to run it (command, URL or build path)
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

## Session Title Update
Update title to: `TEST - <Task Name> - <Project Name>`
