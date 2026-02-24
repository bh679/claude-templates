# Operator Standard

An **Operator** is a Claude agent triggered on a schedule by GitHub Actions. It runs autonomously, gathering data and producing output (commits, issues, API calls) without a human in the loop. If something genuinely requires human attention, the Operator opens a GitHub issue and stops — it never blocks waiting for interactive input.

---

## Required Scaffolding Files

Every Operator project must contain:

| File | Purpose |
|---|---|
| `CLAUDE.md` | Agent instructions (role, data sources, output, tools, turn limit) |
| `.github/workflows/<agent-name>.yml` | Cron-triggered GitHub Actions workflow |
| `.github/scripts/fetch-data.sh` | Shell script that gathers input data before Claude runs |
| `guidelines.md` | Output quality rules (tone, format, what to include/exclude) |
| `state.json` | Cross-run memory (last run timestamp, snapshots for deduplication) |

---

## Scheduling Conventions

- Use a `cron` trigger in the workflow so runs happen on a predictable schedule.
- Always include `workflow_dispatch` alongside the cron trigger to allow manual runs.
- Store the schedule in a single place (the workflow file). The CLAUDE.md may reference it in human-readable form (`{{SCHEDULE}}`) for context.

```yaml
on:
  schedule:
    - cron: '0 10 * * 1'   # Every Monday at 10:00 UTC
  workflow_dispatch:
```

---

## State Management Pattern

The Operator uses `state.json` as its persistent memory across runs.

**At the start of a run:** Read `state.json` to understand what was processed last time (deduplication, comparison baseline).

**At the end of a run:** Update `state.json` with the new snapshot and commit it alongside any output. This ensures the next run starts from a clean baseline.

Minimum shape:
```json
{
  "last_run": "2025-01-27T10:00:00Z",
  "snapshot": {}
}
```

The `snapshot` field is agent-specific — use it for whatever the agent needs to deduplicate or compare (e.g. last-seen event IDs, post count, last-processed timestamp per source).

**Never let the agent skip the state commit.** If the state isn't committed, the next run will reprocess everything from scratch.

---

## Guidelines Doc Pattern

`guidelines.md` is a human-authored doc that the Operator reads at the start of each run before producing any output. It governs quality, not behaviour.

Use it for:
- Tone and voice (e.g. "write in first person, present tense")
- Format rules (e.g. "use H2 headings, bullet lists for steps")
- Length constraints (e.g. "aim for 400–600 words")
- What to include or exclude (e.g. "skip internal tooling changes")
- Output naming conventions (e.g. `YYYY-MM-DD.md`)

Guidelines are not instructions to Claude about *what to do* — those live in `CLAUDE.md`. Guidelines are instructions about *how to do it well*.

---

## Allowed Tools Convention

Operators use a **narrow tool list**. The principle: an Operator gathers data, thinks, and commits output. It does not edit existing source files.

**Allowed:**
- `Read` — read files in the repo (CLAUDE.md, guidelines.md, state.json, data files)
- `Bash` — limited to `git` and `gh` commands for committing/pushing output and opening issues
- `WebFetch` — read external URLs if needed for data gathering

**Not allowed:**
- `Edit` / `Write` — Operators write output via `git` commit, not by calling file-write tools
- `WebSearch` — use targeted `WebFetch` with known URLs instead
- Any destructive shell commands (`rm -rf`, `git reset --hard`, etc.)

Encode these restrictions in the workflow's `allowed_tools` parameter and in the agent's `CLAUDE.md`.

---

## Turn Limit Convention

Set a turn limit of **30 turns** for most Operators. This prevents runaway costs and enforces a focused, single-purpose run. If the task requires more turns, it likely needs to be split into multiple Operators or a more efficient data-gathering approach.

Set the turn limit in the workflow's Claude Code action parameters.

---

## Commit and Push Procedure

Operators commit and push directly to the default branch — there is no PR, no Gate workflow, no review step.

**Commit message format:** `<type>: <short description>` (same convention as the rest of the repo)

Common types for operators:
- `feat` — new output created (e.g. a new blog post)
- `chore` — state update with no meaningful new output
- `fix` — correction to previous output

**After every run that produces output:**
```bash
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"
git add -A
git commit -m "feat: <description of this run's output>"
git push
```

If nothing meaningful happened (skip guard triggered), do not commit. An empty commit is noise.

---

## Skip Guard

Every Operator must have a skip condition: if there is nothing to do, it should exit cleanly without creating empty output or committing noise.

Document the skip condition explicitly in `CLAUDE.md`. Example:

> If there are no new events, no pending items, and no changes since last run, write nothing and exit. Do not commit.

---

## Human Escalation

If the Operator encounters something it cannot handle autonomously (unexpected data shape, failed API, decision requiring judgement), it should:

1. Open a GitHub issue with a clear title and description of the problem
2. Stop the run (do not commit partial output)

It should **not** attempt to interact with a user via chat or block the workflow waiting for input.
