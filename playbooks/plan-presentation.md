<!-- standard: plan-presentation | version: 1.0.0 -->
# Plan Presentation Standard

How to present anything the user approves in plan mode: the Gate 1 plan and the Gate 2, 3 and 4
reports. The user decides from what is on screen, so write for a fast, confident decision.

## Principles
- **Outcome first.** Open with what changes for the user, player or customer, not with mechanics.
- **Decision-ready.** Everything the user needs to approve is in the plan. Nothing important hides
  in a linked file or an earlier message.
- **Show, don't describe.** Use a table, diagram or mockup wherever prose would make the reader
  build the picture themselves.
- **Honest about uncertainty.** Say what you have verified and what you are assuming.
- **Short.** Cut anything that doesn't help the decision. Supporting detail goes after the
  decision-critical sections, never before.

## Gate 1 — Plan Structure
Use these sections, in this order. Drop a section only when it truly has nothing to say, and
write "None" rather than leave a heading empty.

1. **Summary** — one or two sentences: what will be built and what the user will notice.
2. **Why** — the problem or goal, and how we know it is real (bug report, log, request).
3. **Approach** — the chosen design in plain words. If you weighed alternatives, list each one in a
   line with the reason it lost.
4. **Files changed** — a table of path, change and why. Group by area if there are more than about 10.
5. **Risks & impact** — what could break, and the deployment-impact checklist from `gate-1-plan.md`
   plus any project-specific checks (for example the mod-impact check).
6. **Testing plan** — how Gate 2 will prove it works.
7. **Effort** — S / M / L with a rough time.
8. **Open questions** — decisions only the user can make, each with your recommendation.

## Gate 2 / 3 / 4 — Report Structure
1. **Verdict line** — one line: ready / not ready, and why.
2. **Evidence** — the results the gate asks for (tests, build, diff summary, PR link, standards
   checks), as tables or checklists.
3. **What failed or was skipped** — stated plainly, never buried or softened.
4. **What the user needs to do** — exact steps (for Gate 2, step-by-step testing instructions).
5. **Decision asked** — the one thing the user is approving.

## Style
- Headings and short bullets over paragraphs. A paragraph is at most 3 sentences.
- Tables for file lists, option comparisons, test results and checklists.
- UI or visual changes: include a mockup, screenshot or diagram. Never describe a UI in prose alone.
- Code blocks only for commands the user will run or short snippets that carry the point.
- Reference files as clickable relative links (`[Foo.java](src/.../Foo.java:42)`).
- Plain words: no unexplained jargon, internal codenames or abbreviations.
- Name concrete things — files, commands, numbers — instead of "various updates" or "some changes".
- No filler: no restating the request, no "Great question", no closing pleasantries.

## Length
- Aim for one screen. A Gate 1 plan for a typical change is about 40–80 lines.
- Big changes: keep the top sections short and move detail into a final **Details** section.
- If the plan needs more than about 150 lines, the change is probably too big. Propose splitting it.

## Anti-patterns
- A wall of prose with no structure.
- Listing every file read during exploration.
- Hiding a risk or open question at the bottom of a long section.
- Asking the user to choose between options without giving your recommendation.
- Presenting a plan that still says "TBD" in the approach.

## Project Overrides
A project's CLAUDE.md may add required sections (for example a mod-impact check) or change length
limits. Project rules win where they conflict with this standard.
