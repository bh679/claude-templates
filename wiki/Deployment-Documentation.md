[Home](Home) > [Features](Features) > Deployment Documentation

# Deployment Documentation

Gate 1 deployment impact assessment and wiki templates for documenting deployment procedures.

## How It Works

### Gate 1 Deployment Impact Checklist

During Gate 1 planning, the agent assesses whether planned changes impact deployment across 10 categories:

1. Environment variable changes
2. New dependencies or major version bumps
3. Port or networking changes
4. Database schema migrations
5. New API endpoints requiring proxy config
6. Docker/container configuration changes
7. Build step changes
8. New external service integrations
9. Startup or shutdown procedure changes
10. Infrastructure requirement changes

If any apply, the agent checks for existing deployment wiki pages, reads them, and includes deployment doc updates in the plan.

### Wiki Templates

The wiki writing standard provides templates for:
- **Deployment index page** (`Deployment.md`) — lists all deployment methods
- **Deployment method page** (`Deployment-<Method>.md`) — prerequisites, env vars, procedure, rollback, health check

## Technical Notes

- Integrated into Gate 1 of the three-gate workflow
- Post-Gate 3 documentation step includes updating deployment pages
- Templates are part of the wiki template set

## Related

- [Three-Gate Workflow](Three-Gate-Workflow)
- [Wiki Writing Standard](Wiki-Writing-Standard)
- [Wiki Template](Wiki-Template)
