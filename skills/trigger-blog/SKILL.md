---
name: trigger-blog
version: 1.0.0
description: >
  Capture feature shipping details and send them to the weekly-blog agent.
  Use when the user ships a feature and says "blog this", "trigger the blog",
  "log this for the blog", "add this to the weekly blog", or when a Gate 3
  merge completes and the user wants to document it for the blog.
---

# Trigger Blog

This skill captures rich context about a just-shipped feature and queues it
for the weekly-blog agent — so Monday's post reflects your intent and framing,
not just raw commit messages.

## When to Use

- After a Gate 3 merge completes
- When the user says "blog this", "trigger the blog", or similar
- At the end of a feature session before closing

## Step 1: Collect Feature Context

Gather the following from the current session:

1. **Feature name and slug** — from the session title or last PR
2. **PR URL and number** — from the last `gh pr create` or `gh pr list` output
3. **Merged timestamp** — from `gh pr view <number> --json mergedAt`
4. **Wiki URL** — check if a wiki page was created this session
5. **Commit messages** — from `git log dev/<feature-slug> --oneline --no-merges`
6. **Screenshots** — list any `.png` files in `./test-results/` from this session
7. **Description** — summarise what was built in 1-2 sentences (use the Gate 1 plan and PR description)
8. **Framing** — the "why it matters" context (derive from the Gate 1 plan and user's original request)

```bash
# Get PR details
gh pr view --json number,url,mergedAt,title

# Get commit messages from the feature branch
git log origin/main..HEAD --oneline --no-merges

# List screenshots from this session
ls ./test-results/*.png 2>/dev/null
```

## Step 2: Ask Whether to Queue or Post Now

Present the collected context to the user and ask:

> "I've captured the context for **{{feature name}}**. Should I:
> - **Queue for Monday** — add to the weekly-blog's pending queue for the next scheduled post
> - **Post now** — trigger the weekly-blog GitHub Action immediately for a same-day post"

Wait for the user's choice before proceeding.

## Step 3a: Queue for Monday

1. Clone or access the weekly-blog repo:
   ```bash
   # If not already cloned locally:
   gh repo clone bh679/weekly-blog /tmp/weekly-blog-queue 2>/dev/null || true
   cd /tmp/weekly-blog-queue && git pull
   ```

2. Read existing `pending-context.json` (create empty array if absent):
   ```bash
   cat pending-context.json 2>/dev/null || echo '[]'
   ```

3. Append the new entry following the schema in
   `~/.claude/skills/trigger-blog/references/blog-data-schema.md`

4. Write back and commit:
   ```bash
   git add pending-context.json
   git commit -m "chore: queue {{feature-slug}} for weekly blog"
   git push
   ```

5. Report back: "✓ Queued **{{feature name}}** for Monday's blog post."

## Step 3b: Post Now

1. First queue the context (Step 3a above)
2. Then trigger the workflow:
   ```bash
   gh workflow run weekly-blog.yml --repo bh679/weekly-blog
   ```
3. Report back: "✓ Queued context and triggered the weekly-blog workflow. Check https://github.com/bh679/weekly-blog/actions for status."

## Error Handling

- **No PR found:** Ask the user for the PR URL manually
- **No screenshots:** Proceed without them (screenshots field is optional)
- **weekly-blog repo not accessible:** Check `gh auth status` and ensure PAT has repo access
- **pending-context.json is malformed:** Show the user the existing content and ask how to proceed

## Output Format

After completion, report a brief summary:

```
✓ Trigger blog complete

Feature: User Authentication
Queued: Yes (Monday's post)
Screenshots: 2 captured
Wiki: https://github.com/bh679/chess-client/wiki/User-Authentication
```
