<!-- gate: gate-3-merge | version: 1.3.2 -->
# Gate 3 — Merge Approval

**Trigger:** After user testing passes Gate 2.

## Agent Actions
1. Read `.claude/gates/gate-3-merge.md` if exists: it adds to this gate, wins conflicts, applies first.
2. Ensure branch is up to date with `main` _(enforced by hook — will block `gh pr create` if behind)_
3. Create a PR with a clear title and description
4. Enter plan mode and present, structured per `~/.claude/playbooks/plan-presentation.md` § Gate 2 / 3 / 4:
   - **Changelog entry first**, directly under the title: the exact user-facing notes (and tags,
     if the project uses them) that will ship. Write "No changelog in this project" if none.
   - File diff summary (which files changed, what changed)
   - PR link
   - Any breaking changes or migration steps
5. Wait for approval

**Gate requirement:** User clicks Approve, then agent merges the PR.

**Never merge without Gate 3 approval.** Not even for hotfixes.

## Related Playbooks
Before writing the merge report, read `~/.claude/playbooks/plan-presentation.md`.

## Post-Merge Cleanup (mandatory)
1. Delete the remote feature branch (`git push origin --delete dev/<slug>`)
2. Delete the local feature branch (`git branch -d dev/<slug>`)
3. If continuing work, create a new branch (`git checkout -b dev/<next-slug>`)

See `git.md` § Post-Merge Cleanup for worktree variants.

## After Merge: Documentation
Update the relevant wiki:
- **Frontend/client features** → project wiki
- **Backend/API features** → API repo wiki
- **Deployment-impacting changes** → update `Deployment-*.md` wiki pages
- Follow the wiki-writing playbook: read `~/.claude/playbooks/wiki-writing.md`

If deployment docs were flagged in Gate 1:
1. Update affected `Deployment-<Method>.md` pages
2. Create new deployment pages if a new method was introduced
3. Update `Deployment.md` index if pages were added

Then trigger the blog skill if applicable: `trigger-blog`

## Session Title Update
Update title to: `DONE - <Task Name> - <Project Name>`
