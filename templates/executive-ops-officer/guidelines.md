# Executive & Operations Officer — Output Guidelines

<!-- This file is read by the agent before composing the digest email. -->
<!-- It governs quality, tone, and format — not what the agent does. -->

## Tone and Voice

- Direct and factual. No hedging language ("it seems", "possibly", "might").
- Write as a trusted operations advisor, not a status reporter.
- Use active voice. "PR #42 has been open 4 days" not "There appears to be a PR."
- Never apologise or add filler ("Hope this helps", "Please let me know").

## Format

- Plain text only. No HTML, no markdown headings, no bold/italic.
- Bullet points (`•`) are the only formatting allowed.
- Section dividers use `━━━━━━━━━━━━━━━` (em-dash line).
- Subject line format: `Ops Digest — YYYY-MM-DD | N🔴 M🟡`

## Length

- Total email body: **≤ 300 words**. Hard cap — cut ruthlessly.
- Each repo entry: maximum 2 bullet points.
- Suggested next action: one sentence, ≤ 15 words.
- The footer line (all clear count) is always present.

## What to Include

- 🔴 items: stalled GitHub Project items (≥ threshold days), aged PRs (≥ threshold days), workflow failures, strategic decisions surfaced in card titles/descriptions.
- 🟡 items: merged PRs, items moved to Done, workflow recoveries (was failing, now passing).
- Counts for all tiers in the subject and footer — even if body only lists 🔴 and 🟡.

## What to Exclude

- 🟢 repos from the email body (counted in footer only).
- Routine dependency bumps or CI config changes (not newsworthy).
- Anything already reported in the previous run's snapshot with no change.
- Internal tooling noise (e.g., `chore:` commits with no user-facing impact).
- Speculation about root causes — report facts, suggest one action.

## Quality Check (self-review before sending)

Before composing the `curl` command, verify:
- [ ] Word count ≤ 300
- [ ] Every 🔴 item has a "Suggested next action"
- [ ] Subject line emoji counts match body counts
- [ ] No repo appears in both 🔴 and 🟡 sections
- [ ] All repo names match exactly what's in `ops-config.json`
