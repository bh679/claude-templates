<!-- standard: plan-presentation | version: 1.2.0 -->
# Plan Presentation Standard

How to present anything the user approves in plan mode: the Gate 1 plan and the Gate 2, 3 and 4
reports. The user decides from what is on screen, so write for a fast, confident decision.

## Principles
- **Everything in the first sentence.** The first sentence states the problem and the solution in
  as few plain words as possible. A user who reads only that sentence should know what they are
  approving.
- **Decision-ready.** Everything the user needs to approve is in the plan. Nothing important hides
  in a linked file or an earlier message.
- **Show, don't describe.** Use a table, diagram or mockup wherever prose would make the reader
  build the picture themselves.
- **Honest about uncertainty.** Say what you have verified and what you are assuming.
- **Fewest words, everywhere.** Every line, in every section (collapsed ones included), says its
  point in as few plain words as possible. Cut anything that doesn't help the decision.

## Gate 1 — Plan Structure
Two parts: what the user reads, then reference detail they open only when they need specifics.

### Read (always visible)
1. **Summary sentence** — the plan's title line and first sentence: problem → solution, as short
   as possible (aim for under 20 words). No mechanics, no file names.
   - Good: "Mobs ambush players unseen; add lanterns that flicker red when a mob is near."
   - Bad: "This plan introduces a new block entity that performs periodic AABB scans…"
2. **Open questions** — decisions only the user can make, each with your recommendation. Write
   "None" if there are none.
3. **Risks** — what could break, the deployment-impact checklist from `gate-1-plan.md`, and any
   project-specific checks (for example the mod-impact check). One line each; flag the main risk.

### Reference (collapsed)
Put each of these in its own collapsible block so the user can skip them:

```markdown
<details><summary><b>Approach</b> — one-line gist</summary>

…detail…

</details>
```

4. **Approach** — the chosen design in plain words, and any rejected alternatives with the
   reason each lost.
5. **Files changed** — a table of path, change and why. Group by area if there are more than about 10.
6. **Testing plan** — how Gate 2 will prove it works.
7. **Effort** — S / M / L with a rough time.

Give each `<summary>` a one-line gist (for example "Effort — S, about 2 hours") so the collapsed
view is still informative. Leave a blank line after `<summary>` and before `</details>` so the
markdown inside renders.

## Gate 2 / 3 / 4 — Report Structure
1. **Verdict sentence** — the first sentence: ready / not ready, and why, in as few words as possible.
2. **What failed or was skipped** — stated plainly, never buried or softened.
3. **What the user needs to do** — exact steps (for Gate 2, step-by-step testing instructions).
4. **Decision asked** — the one thing the user is approving.
5. **Evidence** (collapsed, as above) — the results the gate asks for (tests, build, diff summary,
   PR link, standards checks), as tables or checklists.

## Style
- Short bullets, not paragraphs. One idea per bullet, ideally under 12 words.
- Fragments are fine: "Recommend 8; 12 reaches next carriage" beats a full sentence.
- Drop filler words ("in order to", "basically", "this will", "we need to").
- Table cells: a few words, never sentences.
- One reason per recommendation or rejected option, not a paragraph of justification.
- Tables for file lists, option comparisons, test results and checklists.
- UI or visual changes: include a mockup, screenshot or diagram. Never describe a UI in prose alone.
- Code blocks only for commands the user will run or short snippets that carry the point.
- Reference files as clickable relative links (`[Foo.java](src/.../Foo.java:42)`).
- Plain words: no unexplained jargon, internal codenames or abbreviations.
- Name concrete things — files, commands, numbers — instead of "various updates" or "some changes".
- No filler: no restating the request, no "Great question", no closing pleasantries.

## Length
- The visible part fits on one screen: summary sentence, open questions and risks. Detail lives
  in the collapsed blocks.
- Big changes: keep the visible part just as short and let the collapsed blocks grow.
- If the plan needs more than about 150 lines, the change is probably too big. Propose splitting it.

## Anti-patterns
- A wall of prose with no structure.
- A first sentence that needs a second sentence to make sense.
- A bullet that could lose half its words and keep its meaning.
- Putting approach, files, testing or effort detail in the visible part.
- Listing every file read during exploration.
- Hiding a risk or open question at the bottom of a long section.
- Asking the user to choose between options without giving your recommendation.
- Presenting a plan that still says "TBD" in the approach.

## Project Overrides
A project's CLAUDE.md may add required sections (for example a mod-impact check) or change length
limits. Project rules win where they conflict with this standard.
