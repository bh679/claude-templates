[Home](Home) > [Features](Features) > Trigger Blog Skill

# Trigger Blog Skill

A session-scoped Claude skill that captures feature shipping context and queues it for the weekly blog agent.

## How It Works

Triggered by `/trigger-blog` or "blog this" after a Gate 3 merge. The skill:

1. **Collects context** — feature name, PR URL, merge timestamp, wiki URL, commit messages, screenshots, description, and framing
2. **Asks queue or post now** — user chooses to queue for Monday's blog or trigger immediately
3. **Queues the context** — appends to `pending-context.json` in the weekly-blog repo
4. **Optionally triggers** — runs the weekly-blog GitHub Action for same-day posting

### Context Captured

- Feature name and slug
- PR URL and number
- Merged timestamp
- Wiki URL (if created)
- Commit messages from the feature branch
- Screenshots from `./test-results/`
- Description and framing from the Gate 1 plan

## Technical Notes

- Writes to the `bh679/weekly-blog` repo's `pending-context.json`
- Schema defined in `skills/trigger-blog/references/blog-data-schema.md`
- The weekly-blog agent consumes this context on its next scheduled run

## Related

- [Skills](Skills)
- [Three-Gate Workflow](Three-Gate-Workflow)
