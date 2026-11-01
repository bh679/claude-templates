# Web project gate add-ons

The gate playbooks in `playbooks/gates/` are project-type neutral. These files add the web-specific
steps (browser testing, local URLs, ports, server deployment) for projects that need them.

**To use:** copy the files into the project's `.claude/gates/`. Each template gate checks that folder
for a file of the same name and follows it as well. If the project already has an add-on of the same
name, merge the two into one file.

```bash
cp templates/gates/web/gate-*.md <project>/.claude/gates/
```

| File | Adds |
|---|---|
| `gate-1-plan.md` | Package-registry research; server/web deployment checklist |
| `gate-2-test.md` | Playwright/curl tests, browser screenshots, accessibility snapshot, local URL |
