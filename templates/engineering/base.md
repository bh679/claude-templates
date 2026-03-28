<!-- Engineering base — github.com/bh679/claude-templates/templates/engineering/base.md -->
<!-- Included at copy time via {{INCLUDE:engineering/base.md}} -->

## Standards

The following standards are embedded from `bh679/claude-templates`. To check for updates,
compare the `standard-version` comments below against the current versions in the standards repo.

{{STANDARD:workflow}}

---

{{STANDARD:git}}

---

{{STANDARD:versioning}}

---


### Before ANY Implementation

1. Search project board for existing items
2. Enter plan mode (Gate 1)

---

{{STANDARD:project-board}}

---

## Git & Development Environment

**Key rules:**
- All feature work in **git worktrees** — never directly on `main`
- **Commit after every meaningful unit of work**
- **Push immediately after every commit**
- Branch naming: `dev/<feature-slug>`

### Worktree Setup (after Gate 1 approval)

```bash
# In the sub-repo that needs changes
git worktree add ../worktrees/{{PROJECT_SLUG}}-<feature-slug> -b dev/<feature-slug>
cd ../worktrees/{{PROJECT_SLUG}}-<feature-slug>
npm install
```

### Worktree Teardown (after Gate 3 merge)

```bash
git worktree remove ../worktrees/{{PROJECT_SLUG}}-<feature-slug>
git branch -d dev/<feature-slug>
```

### Port Management

Each session claims a unique port to avoid conflicts:

```bash
# Claim a port
echo '{"port": {{BASE_PORT}}, "session": "<session-id>", "feature": "<feature-slug>"}' > ./ports/<session-id>.json

# Release port after session ends
rm ./ports/<session-id>.json
```

Base port: `{{BASE_PORT}}`. If occupied, increment by 1 until a free port is found.



---

## Documentation

{{STANDARD:wiki-writing}}

---


## Key Rules Summary

- Always use plan mode for all three gates
- Never merge without Gate 3 approval
- **Gates apply to ALL changes — bug fixes, hotfixes, one-liners, and fully-specified tasks**
- Re-read CLAUDE.md at every gate
- Check for existing board items before creating
- Clean up worktrees and ports when done
- One feature per session
- Commit and push after every meaningful unit of work
