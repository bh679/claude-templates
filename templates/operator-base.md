<!-- Operator base — github.com/bh679/claude-templates/templates/operator-base.md -->
<!-- Included at copy time via an INCLUDE directive pointing at operator-base.md.
     Never write that token literally in this file — it is inlined into itself, so a
     literal token would make recursive include resolution loop forever. -->

## State Management

At the start of each run, read `state.json` to understand what was processed last time. Use it to avoid duplicating output across runs.

At the end of each run, update `state.json` with the current run timestamp and any snapshot data needed for deduplication next run.

Commit and push:

```bash
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add -A
git commit -m "<type>: <short description>"
git push
```

If you skip writing output (skip guard triggered), do not commit.

---

## Skip Guard

If there is nothing meaningful to do — no new data, no changes since last run, nothing to report — exit cleanly without writing output or committing. An empty commit is noise.

---

## Turn Limit

Complete your work in **30 turns or fewer**. If you need more, the task scope is too large — break it up or improve data pre-processing in the fetch script.

---

## Human Escalation

If you encounter an unrecoverable error or a decision requiring human judgement:
1. Open a GitHub issue: `gh issue create --title "..." --body "..."`
2. Stop. Do not commit partial output.
