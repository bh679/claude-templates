[Home](Home) > [Features](Features) > Wiki Template

# Wiki Template

Starter files for project wiki documentation, providing a consistent structure across all projects.

## How It Works

The template provides pre-structured wiki pages that are copied into project wiki repos at bootstrap time.

### Files Included

```
templates/wiki/
├── CLAUDE.md         — Wiki editor instructions (role, templates, rules)
├── Home.md           — Index page with project overview
├── Features.md       — Feature index table
├── Deployment.md     — Deployment methods index (optional)
├── Endpoints.md      — API endpoint index (optional, backend projects)
```

### Wiki Editor Role

The CLAUDE.md defines a Wiki Editor role that:
- Reads the wiki-writing standard before any edits
- Follows breadcrumb conventions
- Uses provided templates for features, roadmap, deployment, and endpoints
- Commits with `docs: <description>` messages

## Related

- [Wiki Writing Standard](Wiki-Writing-Standard)
- [Templates](Templates)
- [Deployment Documentation](Deployment-Documentation)
