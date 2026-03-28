[Home](Home) > [Features](Features) > Operator Standard

# Operator Standard

Defines the scaffolding and conventions for scheduled autonomous Claude agents that run via GitHub Actions.

## How It Works

An Operator is a Claude agent triggered on a cron schedule. It gathers data, produces output (commits, issues, API calls), and manages its own state — all without human interaction.

### Required Files

| File | Purpose |
|---|---|
| `CLAUDE.md` | Agent instructions |
| `.github/workflows/<agent>.yml` | Cron-triggered workflow |
| `.github/scripts/fetch-data.sh` | Data gathering script |
| `guidelines.md` | Output quality rules |
| `state.json` | Cross-run persistent memory |

### State Management

The agent reads `state.json` at the start of each run for deduplication and comparison, then updates and commits it at the end.

### Key Conventions

- 30-turn limit per run
- Narrow tool list (Read, Bash for git/gh, WebFetch)
- Skip guard: exit cleanly when nothing to do
- Human escalation: open a GitHub issue and stop
- Direct push to default branch (no PR workflow)

## Technical Notes

- Current version: 1.0.0
- Always include `workflow_dispatch` alongside cron triggers
- Guidelines govern quality (tone, format), not behaviour

## Related

- [Operator Template](Operator-Template)
- [Templates](Templates)
