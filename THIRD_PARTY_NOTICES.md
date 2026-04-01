# Third-Party Notices

This file documents third-party code included in or derived from external projects.

---

## Everything Claude Code (ECC)

- **Project:** Everything Claude Code
- **Author:** Affaan Mustafa
- **Repository:** https://github.com/affaan-m/everything-claude-code
- **License:** MIT
- **Copyright:** (c) 2026 Affaan Mustafa

### License Text

```
MIT License

Copyright (c) 2026 Affaan Mustafa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### Files Copied Directly from ECC

These files were copied from the ECC repository and are used under the MIT license above.

#### Skills (copied from `skills/`)

| Local Path | ECC Source Path | Description |
|---|---|---|
| `skills/strategic-compact/SKILL.md` | `skills/strategic-compact/SKILL.md` | Context compaction strategy for long sessions |
| `skills/search-first/SKILL.md` | `skills/search-first/SKILL.md` | Research-before-coding workflow |
| `skills/verification-loop/SKILL.md` | `skills/verification-loop/SKILL.md` | Pre-PR verification system |

#### Skills (adapted from `rules/`)

| Local Path | ECC Source Path | Description |
|---|---|---|
| `skills/ecc-performance/SKILL.md` | `rules/common/performance.md` | Model selection and context window management |
| `skills/ecc-security/SKILL.md` | `rules/common/security.md` | Security checks and secret management |
| `skills/ecc-git-workflow/SKILL.md` | `rules/common/git-workflow.md` | Commit message format and PR workflow |

#### Agents (copied from `agents/`)

| Local Path | ECC Source Path | Description |
|---|---|---|
| `agents/code-reviewer.md` | `agents/code-reviewer.md` | Code review specialist agent |

### Rules Derived from ECC

The following files in `rules/common/` are identical to or derived from their ECC counterparts. They were adopted during initial repository setup.

| Local Path | ECC Source Path | Status |
|---|---|---|
| `rules/common/performance.md` | `rules/common/performance.md` | Identical |
| `rules/common/security.md` | `rules/common/security.md` | Identical |
| `rules/common/agents.md` | `rules/common/agents.md` | Near-identical (one agent entry removed) |
| `rules/common/coding-style.md` | `rules/common/coding-style.md` | Identical |
| `rules/common/hooks.md` | `rules/common/hooks.md` | Identical |
| `rules/common/patterns.md` | `rules/common/patterns.md` | Identical |
| `rules/common/testing.md` | `rules/common/testing.md` | Near-identical (minor additions for co-location convention) |
