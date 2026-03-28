[Home](Home) > [Features](Features) > Wiki Writing Standard

# Wiki Writing Standard

Documentation style, breadcrumbs, link rules, and page templates for all project wikis.

## How It Works

### Breadcrumbs

Every wiki page (except Home) starts with a breadcrumb trail:

```
[Home](Home) > [Section](Section) > Current Page Title
```

### Page Structure

Each page follows: breadcrumb, title, one-sentence description, Overview, Details, Related links.

### Heading Levels

- `#` — Page title (one per page)
- `##` — Major sections
- `###` — Subsections
- Never skip levels

### Links

Internal wiki links use page names with hyphens, no `.md` extension. External links use full URLs.

### Images

Named as `<feature-slug>-<context>-<YYYY-MM>.png`, stored in `images/` directory, always with descriptive alt text.

## Templates Provided

- Feature documentation template
- Roadmap feature template
- Deployment index and method templates
- Endpoint index and resource templates

## Technical Notes

- Current version: 1.0.0
- Tone: present tense, second person for instructions
- Commit messages: `docs: <what was added or changed>`

## Related

- [Wiki Template](Wiki-Template)
- [Standards](Standards)
