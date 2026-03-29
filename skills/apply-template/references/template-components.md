# Template Components Reference

What each template type includes. Use this to detect the current state and know what to compare.

---

## engineering/product

### CLAUDE.md Structure
- Role header: `# Product Engineer — {{PROJECT_NAME}}`
- Source comment: `<!-- Source: github.com/bh679/claude-templates/templates/engineering/product/CLAUDE.md -->`
- `{{INCLUDE:engineering/project-overview.md}}` — project overview section
- `{{INCLUDE:engineering/base.md}}` — standards + key rules (contains all STANDARD tokens)
- Gate 1 section (plan approval + deployment check)
- Gate 2 section (testing approval + Playwright MCP)
- Testing section (API + UI)
- Documentation section (wiki + deployment)

### Standards (via base.md)
| Standard | Token in base.md |
|---|---|
| workflow | `{{STANDARD:workflow}}` |
| git | `{{STANDARD:git}}` |
| versioning | `{{STANDARD:versioning}}` |
| project-board | `{{STANDARD:project-board}}` |
| port-management | `{{STANDARD:port-management}}` |
| wiki-writing | `{{STANDARD:wiki-writing}}` |

### Template Files
| File | Purpose |
|---|---|
| `CLAUDE.md` | Main instructions |
| `.claude/settings.json` | Permissions + hooks |
| `.claude/gates/gate-1-plan.md` | Gate 1 detailed instructions |
| `.claude/gates/gate-2-test.md` | Gate 2 detailed instructions |
| `.claude/gates/gate-3-merge.md` | Gate 3 detailed instructions |
| `package.json` | Playwright dependency |
| `playwright.config.js` | Playwright config |

### Gate Files
Source: `standards/gates/` — copied to `.claude/gates/` in consumer projects.
Version comment format: `<!-- gate: <name> | version: X.Y.Z -->`

| Gate | Version | Purpose |
|---|---|---|
| `gate-1-plan.md` | 1.0.0 | Plan approval — deployment checklist, session ID |
| `gate-2-test.md` | 1.0.0 | Testing approval — screenshots, accessibility |
| `gate-3-merge.md` | 1.0.0 | Merge approval — PR, documentation, blog |

### Settings (permissions)
- allow: Read, Glob, Edit, Write, Bash, WebSearch, WebFetch
- deny: `git push --force`, `git reset --hard`, `rm -rf`

### Hooks
| Hook | Type | Source |
|---|---|---|
| `.claude/hooks/git/pre-bash.sh` | Claude Code PreToolUse | `standards/hooks/git/pre-bash.sh` |
| `.claude/hooks/git/post-bash.sh` | Claude Code PostToolUse | `standards/hooks/git/post-bash.sh` |
| `.git/hooks/pre-commit` | Git pre-commit | `standards/hooks/versioning/git-hook-pre-commit.sh` |

### Fingerprints (for detection)
Strings that should appear in a fully-applied product CLAUDE.md:
- "Gate 1", "Gate 2", "Gate 3"
- "EnterPlanMode", "ExitPlanMode"
- "Product Engineer"
- "github.com/bh679/claude-templates"

---

## engineering/backend

### CLAUDE.md Structure
Same as product, plus:
- Role header: `# Backend Engineer — {{PROJECT_NAME}}`
- Backend Impact Checklist (in Gate 1)
- Endpoint documentation mandate (in Documentation section)
- Optional `{{STANDARD:http-diagnostics}}` (commented out by default)
- Additional backend tokens: `{{API_BASE_PATH}}`, `{{DB_TYPE}}`, `{{TEST_COMMAND}}`

### Standards (via base.md)
Same as product (workflow, git, versioning, project-board, port-management, wiki-writing), plus optionally http-diagnostics.

### Template Files
| File | Purpose |
|---|---|
| `CLAUDE.md` | Main instructions |
| `.claude/settings.json` | Permissions + hooks (same as product) |
| `.claude/gates/gate-1-plan.md` | Gate 1 detailed instructions |
| `.claude/gates/gate-2-test.md` | Gate 2 detailed instructions |
| `.claude/gates/gate-3-merge.md` | Gate 3 detailed instructions |

### Gate Files
Same as product — all three gates required.

### Fingerprints
- "Gate 1", "Gate 2", "Gate 3"
- "Backend Engineer"
- "Backend Impact Checklist"
- "github.com/bh679/claude-templates"

---

## operator

### CLAUDE.md Structure
- Role header: `# {{AGENT_NAME}}`
- Source comment: `<!-- Operator template — github.com/bh679/claude-templates -->`
- Data Sources section
- Output section
- `{{INCLUDE:operator-base.md}}` — state management, skip guard, turn limit, escalation
- Skip Condition section
- Allowed Tools section
- Commit Message Format section

### Standards
| Standard | Included via |
|---|---|
| operator | Embedded in `operator-base.md` |
| git | Referenced but not always embedded |

### Template Files
| File | Purpose |
|---|---|
| `CLAUDE.md` | Main instructions |
| `.claude/settings.json` | Restricted permissions |
| `guidelines.md` | Output quality rules |
| `state.json` | Runtime state tracking |
| `.github/workflows/operator.yml` | GitHub Actions schedule |
| `.github/scripts/fetch-data.sh` | Data fetching script |

### Settings (permissions)
- allow: Read, Glob, Bash(ls:*), Bash(find:*), Bash(pwd:*)
- No Edit, Write, WebSearch, WebFetch

### Fingerprints
- "autonomous Claude operator"
- "state.json"
- "skip guard" or "Skip Condition"
- "github.com/bh679/claude-templates"

---

## repo (minimal)

### Template Files
| File | Purpose |
|---|---|
| `CLAUDE.md` | Minimal instructions |
| `.claude/settings.json` | Basic permissions |

---

## consumers.json Schema

```json
{
  "repo": "owner/repo-name",
  "template": "engineering/product | engineering/backend | operator",
  "claude_md_path": "CLAUDE.md",
  "description": "Human-readable description",
  "required_files": ["operator-only: list of required files"]
}
```
