[Home](Home) > [Features](Features) > Operator Template

# Operator Template

Scheduled autonomous Claude agent template with GitHub Actions workflow, state management, and human escalation.

## How It Works

The template provides everything needed for a cron-triggered Claude agent:

### Files Included

```
templates/operator/
├── CLAUDE.md                           — Agent instructions
├── guidelines.md                       — Output quality rules
├── state.json                          — Cross-run persistent memory
└── .github/
    ├── workflows/operator.yml          — Cron-triggered workflow
    └── scripts/fetch-data.sh           — Data gathering script
```

### Key Features

- **State management** via `state.json` — persists across runs for deduplication
- **Skip guard** — exits cleanly when nothing to do
- **30-turn limit** — prevents runaway costs
- **Human escalation** — opens a GitHub issue when it cannot handle something
- **Narrow tool list** — Read, Bash (git/gh only), WebFetch

### Tokens

| Token | Example | Description |
|---|---|---|
| `{{AGENT_NAME}}` | Weekly Blog Writer | Human-readable agent name |
| `{{SCHEDULE}}` | 0 10 * * 1 | Cron expression |
| `{{TRIGGER_DESCRIPTION}}` | Every Monday at 10:00 UTC | Human-readable schedule |
| `{{DATA_SOURCES}}` | GitHub events, pending-context.json | What data the agent consumes |
| `{{OUTPUT_DESCRIPTION}}` | A weekly markdown blog post | What the agent produces |

## Related

- [Operator Standard](Operator-Standard)
- [Token System](Token-System)
- [New Project Skill](New-Project-Skill)
