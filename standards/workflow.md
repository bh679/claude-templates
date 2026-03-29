<!-- standard: workflow | version: 2.1.0 -->
# Workflow Standard — Four-Gate Approval

> **Source of truth** for all Claude product engineer sessions.

---

## Overview

Every feature follows a linear sequence:

```
Discover Session → Search Board → Gate 1 (Plan) → Implement → Gate 2 (Test) → Gate 3 (Merge) → Ship → Document → Gate 4 (Review)
```

One feature per session. Never work on multiple features in the same session. If the user asks for a new feature mid-session, document it as a board item (IDEA status) and finish the current feature first.

> **MANDATORY:** All four gates apply to EVERY change — bug fixes, hotfixes, one-liners,
> and fully-specified tasks. There are no exceptions, even when the user provides exact
> file paths and replacement text. Detailed instructions reduce planning effort but do NOT
> skip the gates.

---

## Gate 1 — Plan Approval

**Trigger:** Before writing any code.

1. Read `.claude/gates/gate-1-plan.md` for full gate instructions
2. Follow the procedure described there

**Gate requirement:** User clicks Approve in plan mode.

---

## Gate 2 — Testing Approval

**Trigger:** After isolated implementation is complete.

1. Read `.claude/gates/gate-2-test.md` for full gate instructions
2. Follow the procedure described there

**Gate requirement:** User tests manually and clicks Approve.

---

## Gate 3 — Merge Approval

**Trigger:** After user testing passes Gate 2.

1. Read `.claude/gates/gate-3-merge.md` for full gate instructions
2. Follow the procedure described there

**Gate requirement:** User clicks Approve, then agent merges the PR.

**Never merge without Gate 3 approval.** Not even for hotfixes.

---

## Gate 4 — Session Review

**Trigger:** After documentation is complete — the final gate before closing the session.

1. Read `standards/gates/session-review.md` for full gate instructions
2. Follow the procedure described there

**Gate requirement:** User clicks Approve after reviewing the report.

---

## Re-reading CLAUDE.md

Re-read the project CLAUDE.md at every gate transition. This ensures you always act on the current state of instructions, not a cached version from session start.
