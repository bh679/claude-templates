<!-- gate: gate-2-test | version: 1.9.0 -->
# Gate 2 — Testing Approval

**Trigger:** After isolated implementation is complete.

## Agent Actions
1. Read `.claude/gates/gate-2-test.md` if exists: it adds to this gate, wins conflicts, applies first.
2. Set session title: `TEST - <Task Name> - <Project Name>`
3. Run unit tests — verify 80%+ line coverage (see `~/.claude/playbooks/unit-testing.md`)
4. Run integration/e2e tests, run the app, and exercise the feature as a user
5. **UI or visual change?** Read `~/.claude/playbooks/ui-prototype.md`, follow its Gate 2 steps
6. Enter plan mode and present a **Gate 2 Testing Report**, structured per `~/.claude/playbooks/plan-presentation.md` § Gate 2 / 3 / 4, containing:
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
