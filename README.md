# Claude Templates

A governance framework for Claude Code projects. It gives every new project a consistent development workflow, enforces standards across repos, and detects when projects drift out of sync — so you spend time building features, not reinventing process.

## New Projects Diverge Without Shared Process

Every new Claude Code project starts from scratch: ad-hoc git conventions, no review gates, inconsistent documentation, and no way to propagate process improvements back to existing projects. As the number of projects grows, so does the divergence.

## Standards, Templates, and Skills Keep Projects Consistent

**Claude Templates** provides three layers of consistency:

1. **Rules & Playbooks** — Versioned policy documents (git workflow, versioning, review gates, testing, wiki writing) that serve as a single source of truth. Rules auto-load into every session; playbooks are read on demand when doing specific work. Update once, and drift detection tells you which projects need updating.

2. **Templates** — Copy-once scaffolding for new projects. Each template comes pre-wired with a four-gate approval workflow (Plan → Build → Test → Merge), testing requirements, deployment checklists, and embedded standards with version tracking. Available for product engineers, backend engineers, and autonomous operator agents.

3. **Skills** — Installable Claude CLI extensions that automate common tasks like bootstrapping a new project or capturing shipped features for a weekly blog.

## Repository Structure

```
claude-templates (this repo)
├── rules/             ← Always-loaded constraints (auto-loaded via ~/.claude/rules/)
│   ├── development-workflow.md   Four-gate approval process
│   ├── git.md                    Branch naming, commits, merge strategy
│   ├── versioning.md             SemVer rules, bump triggers
│   ├── coding-style.md           Immutability, file organization
│   └── security.md               Security checklist
│
├── playbooks/         ← On-demand procedures (symlinked to ~/.claude/playbooks/)
│   ├── gates/
│   │   ├── gate-1-plan.md        Gate 1 procedure
│   │   ├── gate-2-test.md        Gate 2 procedure
│   │   ├── gate-3-merge.md       Gate 3 procedure
│   │   └── session-review.md     Gate 4 procedure
│   ├── http-diagnostics.md       Health endpoints, error logging
│   ├── wiki-writing.md           Documentation style guide
│   ├── testing.md                Test types and TDD workflow
│   ├── unit-testing.md           Unit test requirements
│   └── ...
│
├── templates/         ← Copy-once project scaffolding
│   ├── engineering/
│   │   ├── product/              Full-stack / frontend projects
│   │   └── backend/              API / backend projects
│   ├── operator/                 Autonomous scheduled agents
│   └── wiki/                     GitHub Wiki structure
│
├── skills/            ← Installable CLI extensions
│   ├── new-project/              Bootstrap a project in one command
│   └── trigger-blog/             Capture feature context for blog automation
│
└── docs/              ← Governance automation docs
    ├── version-enforcement.md
    └── drift-detection.md
```

### Every Change Goes Through Four Human-Approved Gates

Every template ships with a structured review process:

| Gate | What happens | Why |
|------|-------------|-----|
| **Gate 1 — Plan** | Define scope, identify risks, get human approval before writing code | Prevents wasted effort on the wrong approach |
| **Gate 2 — Test** | Run tests, capture screenshots, human verifies | Ensures quality before review |
| **Gate 3 — Merge** | Human reviews the PR, approves, and merges | Final quality check before main |
| **Gate 4 — Review** | Standards compliance check against all embedded rules | Catches deviations before closing |

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
# Install skills and playbooks (one-time setup)
git clone https://github.com/bh679/claude-templates.git
cd claude-templates
./install.sh
```

Then from any directory:

```
/new-project
```

The skill walks you through template selection, file copying, token resolution, GitHub repo creation, and verification.

### Install Skills and Playbooks Without Bootstrapping

```bash
cd claude-templates
./install.sh
```

Skills are symlinked into `~/.claude/skills/` and playbooks into `~/.claude/playbooks/`, so `git pull` in this repo automatically updates them.

## Skills Automate Project Lifecycle Tasks

| Skill | Scope | What it does |
|-------|-------|-------------|
| `/new-project` | Global | Bootstraps a fully configured project from a template — handles file copying, token resolution, GitHub setup, and consumer registration |
| `/trigger-blog` | Project session | Captures feature shipping context (PR URL, commits, wiki pages) and queues it for a weekly blog automation agent |

## Rules and Playbooks Define What Every Project Follows

### Rules (always loaded)

| Standard | Covers |
|----------|--------|
| [`development-workflow.md`](rules/development-workflow.md) | Four-gate approval process, plan mode, session management |
| [`git.md`](rules/git.md) | Branch naming, commit message format, merge strategy |
| [`versioning.md`](rules/versioning.md) | SemVer conventions, auto-bump rules, tag and rollback procedures |
| [`coding-style.md`](rules/coding-style.md) | Immutability, file organization, error handling |
| [`security.md`](rules/security.md) | Security checklist, secret management |

### Playbooks (read on demand)

| Playbook | Covers |
|----------|--------|
| [`gates/gate-1-plan.md`](playbooks/gates/gate-1-plan.md) | Gate 1 planning procedure |
| [`gates/gate-2-test.md`](playbooks/gates/gate-2-test.md) | Gate 2 testing procedure |
| [`gates/gate-3-merge.md`](playbooks/gates/gate-3-merge.md) | Gate 3 merge procedure |
| [`gates/session-review.md`](playbooks/gates/session-review.md) | Gate 4 session review |
| [`wiki-writing.md`](playbooks/wiki-writing.md) | Prose style, breadcrumbs, link conventions, image naming |
| [`operator.md`](playbooks/operator.md) | Scheduled autonomous agent scaffolding and conventions |
| [`unit-testing.md`](playbooks/unit-testing.md) | Unit test requirements, 80% coverage, test quality rules |
| [`http-diagnostics.md`](playbooks/http-diagnostics.md) | Health endpoints, error logging, usage tracking for HTTP backends |

Current versions are tracked in [`.github/scripts/standards-versions.json`](.github/scripts/standards-versions.json).

## Templates Scaffold Projects for Different Roles

| Template | Use case | Includes |
|----------|----------|----------|
| **Product Engineer** | Full-stack / frontend projects | Four-gate workflow, Playwright E2E, screenshot capture, deployment checklist, wiki scaffolding |
| **Backend Engineer** | API / backend services | Four-gate workflow, HTTP diagnostics, endpoint documentation, database considerations |
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
