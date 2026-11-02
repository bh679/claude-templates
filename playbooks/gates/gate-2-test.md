<!-- gate: gate-2-test | version: 1.8.0 -->
# Gate 2 — Testing Approval

**Trigger:** After isolated implementation is complete.

## Agent Actions
1. Read `.claude/gates/gate-2-test.md` in the project, if it exists. Its steps add to this list and win
   where they conflict; apply both before starting step 2.
2. Run unit tests: read `~/.claude/playbooks/unit-testing.md` and follow it (80%+ line coverage, the
   test-script contract). The project's add-on may change the target.
3. Run integration/e2e tests, run the app, and exercise the feature the way a user would
4. **UI or visual change?** Read `~/.claude/playbooks/ui-prototype.md` and follow its Gate 2 steps:
   screenshots rendered in chat before the report.
5. Enter plan mode and present a **Gate 2 Testing Report**, structured per `~/.claude/playbooks/plan-presentation.md` § Gate 2 / 3 / 4, containing:
   - How to run it (command, URL or build path)
   - Unit test summary: total, passed, failed, skipped, coverage %
   - Screenshots: confirm they were shown in chat; save key shots in the feature's folder outside the
     worktree (see Screenshots) & list its path (for blogging)
   - Step-by-step user testing instructions
   - Integration/e2e test results summary
   - What passed / what failed

**Gate requirement:** User tests manually and clicks Approve.

## Screenshots
One folder per feature, outside every repo: never committed, kept after the worktree is deleted,
and read by `trigger-blog`.

```bash
PROJECT=$(basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")")
SHOTS="$HOME/Projects/Screenshots/$PROJECT/<feature-slug>"
mkdir -p "$SHOTS"
```

Name each `<NN>-<what-it-shows>.png` (`01-login-error.png`, `02-login-success.png`).

## Session Title Update
Update title to: `TEST - <Task Name> - <Project Name>`
