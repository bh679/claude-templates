# Claude Templates Wiki

Welcome to the Claude Templates documentation — the canonical home for workflow standards, project templates, and installable skills used across Brennan's Claude-powered projects.

## Quick Links

- [Features](Features) — All shipped features
- [Standards](Standards) — Versioned policy documents
- [Templates](Templates) — Copy-once project starting points
- [Skills](Skills) — Installable Claude skills
- [Deployment](Deployment) — Installation and CI/CD
- [Roadmap](Roadmap) — Planned and in-progress work

## About

Claude Templates provides a reusable infrastructure layer for bootstrapping and maintaining Claude-powered development projects. It enforces consistent workflows, git conventions, versioning, and documentation across all consumer projects.

**Repo:** [GitHub](https://github.com/bh679/claude-templates)

## Architecture

```
claude-templates/
├── standards/          — Versioned policy docs (source of truth)
├── templates/          — Copy-once starting points for new projects
├── skills/             — Installable Claude skills (symlinked)
├── consumers.json      — Registry of projects using these templates
└── install-skills.sh   — Global skill installer
```

## Consumer Projects

Projects currently using these templates and standards:

| Project | Template | Description |
|---|---|---|
| chess-project | engineering/product | Chess game platform orchestrator |
| Claude-Management-Dashboard | engineering/product | Claude Management Dashboard |
| house-sitting-agent | engineering/product | Autonomous house-sitting listing monitor |
| weekly-blog | operator | Weekly development blog writer |
| Claude-Max-Usage-Analytics | engineering/product | Personal usage dashboard |
| ideas | operator | Executive PA — idea capture and routing |
| coo-agent | operator | Cross-project momentum tracker |
| Claude-Code-Session-Monitor | engineering/product | Real-time session tracking |
| claude-oauth-distributor | engineering/product | Token generator and distributor |
| the-epstein-files | engineering/product | Top-down pixel art game |
| discord-image-dashboard | engineering/product | Bot + web dashboard for server images |
| CarkedIt | engineering/product | Multiplayer card game web app |
| fill-in-the-blank | engineering/product | Party card game |
| carkedit-online | engineering/product | Card game vanilla rewrite |

## Recent Updates

| Date | Feature | Notes |
|---|---|---|
| 2026-03-28 | [Port Management Standard](Port-Management-Standard) | System-wide dev-server port allocation |
| 2026-03-28 | [Project Board Standard](Project-Board-Standard) | GitHub Projects board interaction standard |
| 2026-03-05 | [Unit Testing Standard](Unit-Testing-Standard) | Added standard for unit test requirements |
| 2026-03-05 | [HTTP Diagnostics Standard](HTTP-Diagnostics-Standard) | Added observability standard for HTTP backends |
| 2026-03-05 | [Hook Versioning](Hook-Versioning) | Version detection for outdated local hook copies |
| 2026-03-05 | [Merge-Main-Before-PR Enforcement](Merge-Main-Before-PR) | Hook-based enforcement of up-to-date branches |
| 2026-03-05 | [Deployment Documentation](Deployment-Documentation) | Gate 1 deployment impact assessment |
