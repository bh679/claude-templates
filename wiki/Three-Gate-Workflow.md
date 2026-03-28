[Home](Home) > [Features](Features) > Three-Gate Workflow

# Three-Gate Workflow

The three-gate approval workflow governs all changes across Claude-powered projects. Every feature follows a linear sequence: Plan, Test, Merge — with no exceptions.

## How It Works

```
Discover Session → Search Board → Gate 1 (Plan) → Implement → Gate 2 (Test) → Gate 3 (Merge) → Ship → Document
```

### Gate 1 — Plan Approval

Before writing any code, the agent enters plan mode, explores the codebase, and presents a plan covering what will be built, which files change, estimated complexity, risks, and deployment impact. The user must approve before implementation begins.

### Gate 2 — Testing Approval

After implementation, the agent runs unit tests (80%+ coverage required), integration/e2e tests, captures screenshots, and presents a testing report. The user tests manually and approves.

### Gate 3 — Merge Approval

The agent ensures the branch is up to date with main, creates a PR, and presents a diff summary. The user approves, then the agent merges via squash merge.

## Technical Notes

- All three gates apply to every change — bug fixes, hotfixes, one-liners included
- One feature per session, enforced by the session identification system
- Session titles follow the format: `<STATUS> - <Task Name> - <Project Name>`
- Status codes: IDEA, PLAN, DEV, TEST, DONE
- CLAUDE.md is re-read at every gate transition
- Gate 1 includes a deployment impact checklist (10 categories)

## Related

- [Git Standards](Git-Standards)
- [Deployment Documentation](Deployment-Documentation)
- [Unit Testing Standard](Unit-Testing-Standard)
