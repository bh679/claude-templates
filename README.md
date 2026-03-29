# Claude Templates

A governance framework for Claude Code projects. It gives every new project a consistent development workflow, enforces standards across repos, and detects when projects drift out of sync — so you spend time building features, not reinventing process.

## New Projects Diverge Without Shared Process

Every new Claude Code project starts from scratch: ad-hoc git conventions, no review gates, inconsistent documentation, and no way to propagate process improvements back to existing projects. As the number of projects grows, so does the divergence.

## Standards, Templates, and Skills Keep Projects Consistent

**Claude Templates** provides three layers of consistency:

1. **Standards** — Versioned policy documents (git workflow, versioning, review gates, wiki writing) that serve as a single source of truth. Update a standard once, and drift detection tells you which projects need updating.

2. **Templates** — Copy-once scaffolding for new projects. Each template comes pre-wired with a three-gate approval workflow (Plan → Build → Merge), testing requirements, deployment checklists, and embedded standards with version tracking. Available for product engineers, backend engineers, and autonomous operator agents.

3. **Skills** — Installable Claude CLI extensions that automate common tasks like bootstrapping a new project or capturing shipped features for a weekly blog.

## Repository Structure

```
claude-templates (this repo)
├── standards/          ← Versioned source of truth
│   ├── workflow.md         Three-gate approval process
│   ├── git.md              Branch naming, commits, worktrees
│   ├── versioning.md       SemVer rules, bump triggers
│   └── wiki-writing.md     Documentation style guide
│
├── templates/          ← Copy-once project scaffolding
│   ├── engineering/
│   │   ├── product/        Full-stack / frontend projects
│   │   └── backend/        API / backend projects
│   ├── operator/           Autonomous scheduled agents
│   └── wiki/               GitHub Wiki structure
│
├── skills/             ← Installable CLI extensions
│   ├── new-project/        Bootstrap a project in one command
│   └── trigger-blog/       Capture feature context for blog automation
│
└── docs/               ← Governance automation docs
    ├── version-enforcement.md
    └── drift-detection.md
```

### Every Change Goes Through Three Human-Approved Gates

Every template ships with a structured review process:

| Gate | What happens | Why |
|------|-------------|-----|
| **Gate 1 — Plan** | Define scope, identify risks, get human approval before writing code | Prevents wasted effort on the wrong approach |
| **Gate 2 — Build & Test** | Implement with TDD, run tests, capture screenshots | Ensures quality before review |
| **Gate 3 — Merge** | Human reviews the PR, approves, and merges | Final quality check before main |

### Embedded Versions Let Automation Detect Outdated Projects

When a template is bootstrapped, standards are embedded with version comments:

```markdown
<!-- standard: git | version: 1.2.0 -->
```

Two automated systems maintain consistency:

- **Version enforcement** — CI blocks changes to standards that don't include a version bump
- **Drift detection** — A weekly GitHub Action compares every consumer project's embedded versions against the latest and opens issues when they fall behind

## Getting Started

### Bootstrap a New Project

```bash
# Install skills (one-time setup)
git clone https://github.com/bh679/claude-templates.git
cd claude-templates
./install-skills.sh
```

Then from any directory:

```
/new-project
```

The skill walks you through template selection, file copying, token resolution, GitHub repo creation, and verification.

### Install Skills Without Bootstrapping

```bash
cd claude-templates
./install-skills.sh
```

Skills are symlinked into `~/.claude/skills/`, so `git pull` in this repo automatically updates them.

## Skills Automate Project Lifecycle Tasks

| Skill | Scope | What it does |
|-------|-------|-------------|
| `/new-project` | Global | Bootstraps a fully configured project from a template — handles file copying, token resolution, GitHub setup, and consumer registration |
| `/trigger-blog` | Project session | Captures feature shipping context (PR URL, commits, wiki pages) and queues it for a weekly blog automation agent |

## Standards Define the Rules Every Project Follows

| Standard | Covers |
|----------|--------|
| [`workflow.md`](standards/workflow.md) | Three-gate approval process, plan mode, session management |
| [`git.md`](standards/git.md) | Branch naming, commit message format, worktree procedures |
| [`versioning.md`](standards/versioning.md) | SemVer conventions, auto-bump rules, tag and rollback procedures |
| [`wiki-writing.md`](standards/wiki-writing.md) | Prose style, breadcrumbs, link conventions, image naming |
| [`operator.md`](standards/operator.md) | Scheduled autonomous agent scaffolding and conventions |
| [`unit-testing.md`](standards/unit-testing.md) | Unit test requirements, 80% coverage, test quality rules |
| [`http-diagnostics.md`](standards/http-diagnostics.md) | Health endpoints, error logging, usage tracking for HTTP backends |

Current versions are tracked in [`.github/scripts/standards-versions.json`](.github/scripts/standards-versions.json).

## Templates Scaffold Projects for Different Roles

| Template | Use case | Includes |
|----------|----------|----------|
| **Product Engineer** | Full-stack / frontend projects | Three-gate workflow, Playwright E2E, screenshot capture, deployment checklist, wiki scaffolding |
| **Backend Engineer** | API / backend services | Three-gate workflow, HTTP diagnostics, endpoint documentation, database considerations |
| **Operator** | Autonomous scheduled agents | State management, skip guards, turn limits, human escalation via GitHub Issues |
| **Wiki** | GitHub Wiki structure | Home page, Features, Endpoints, Deployment templates |

See [`templates/README.md`](templates/README.md) for the full bootstrapping checklist and token reference.

## Projects Using These Templates

Projects using these templates and standards:
- [chess-project](https://github.com/bh679/chess-project)

See [`consumers.json`](consumers.json) for the full list monitored by drift detection.

## CI and Weekly Workflows Enforce Standards Automatically

| System | What it does | Docs |
|--------|-------------|------|
| **Version enforcement** | CI + pre-commit hook block standard changes without a version bump | [`docs/version-enforcement.md`](docs/version-enforcement.md) |
| **Drift detection** | Weekly workflow flags consumer projects with outdated embedded standards | [`docs/drift-detection.md`](docs/drift-detection.md) |
