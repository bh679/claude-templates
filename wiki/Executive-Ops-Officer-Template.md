[Home](Home) > [Features](Features) > Executive Ops Officer Template

# Executive Ops Officer Template

An operator variant that surveys all active projects daily, classifies their health into escalation tiers, and sends a digest email via SendGrid.

## How It Works

The Executive Ops Officer (EOO) runs daily via GitHub Actions. It:

1. Reads `ops-config.json` for the list of repos to monitor
2. Consumes pre-fetched data (GitHub Projects V2 cards, open PRs, workflow results)
3. Classifies each repo into escalation tiers:
   - Red: stalled items, aged PRs, workflow failures
   - Yellow: something shipped or notable activity
   - Green: nothing to report
4. Composes a plain-text digest email (max 300 words)
5. Sends via SendGrid API
6. Updates `state.json` for next-run comparison

### Observer Mode

The EOO reads only — it never opens issues, closes PRs, or modifies monitored repos. The only writes are the digest email and `state.json`.

### Files Included

```
templates/executive-ops-officer/
├── CLAUDE.md                           — Agent instructions with escalation tiers
├── guidelines.md                       — Email quality rules (tone, format, length)
├── ops-config.json                     — Repos, email config, staleness thresholds
├── state.json                          — Cross-run memory
└── .github/
    ├── workflows/executive-ops.yml     — Daily cron trigger
    └── scripts/fetch-data.sh           — GitHub data gathering
```

## Technical Notes

- Extends `operator-base.md` (shared state management, skip guard, turn limit)
- Requires `SENDGRID_API_KEY` and `ANTHROPIC_API_KEY` secrets
- Skip condition: all repos green AND were green last run (no email sent)
- Thresholds configurable in `ops-config.json` (default: 5 days stale items, 3 days stale PRs)

## Related

- [Operator Standard](Operator-Standard)
- [Operator Template](Operator-Template)
- [Templates](Templates)
