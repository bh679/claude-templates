[Home](Home) > Roadmap

# Roadmap

Planned and in-progress work for Claude Templates.

---

## Backlog — Gaps Identified

These items represent missing pieces discovered during documentation review.

### Workflow Standard Hooks

**Status:** Planned
**Priority:** High

The hooks folder structure has `workflow/` marked as "(future)" but no hooks exist yet. The three-gate workflow relies entirely on agent compliance rather than automated enforcement.

### Acceptance Criteria

- [ ] Pre-tool hook that warns if code is being written without Gate 1 approval
- [ ] Post-tool hook that reminds about Gate 2 testing after implementation
- [ ] Hook that blocks PR merge commands without Gate 3 approval

### Notes

The git standard already has enforcement hooks. The workflow standard is the most critical standard without hook enforcement.

---

### Wiki Writing Hooks

**Status:** Planned
**Priority:** Medium

The hooks folder structure has `wiki/` marked as "(future)" but no hooks exist yet.

### Acceptance Criteria

- [ ] Hook that validates breadcrumb format on wiki page writes
- [ ] Hook that checks for broken internal wiki links

---

### Executive Ops Officer Template Documentation

**Status:** Planned
**Priority:** Medium

The `templates/executive-ops-officer/` template exists with a full set of files (CLAUDE.md, guidelines, ops-config.json, state.json, GitHub Actions workflow) but has no documentation in `templates/README.md`, no bootstrapping checklist, and no token reference table.

### Acceptance Criteria

- [ ] Add executive-ops-officer to the template README
- [ ] Document its unique `ops-config.json` file
- [ ] Add token reference table
- [ ] Add bootstrapping checklist

---

### Missing README Coverage for Standards

**Status:** Planned
**Priority:** Medium

The project README lists 4 standards (workflow, git, versioning, wiki-writing) but 3 more exist: operator, unit-testing, http-diagnostics.

### Acceptance Criteria

- [ ] Add operator, unit-testing, and http-diagnostics to README standards table

---

### Drift Detection for Standards Beyond CLAUDE.md

**Status:** Planned
**Priority:** Medium

The drift check script currently compares version comments in consumer CLAUDE.md files. It does not detect drift in:
- Hook versions (already handled by `check-hooks.sh`, but not in CI)
- Wiki template drift
- Settings.json drift

### Acceptance Criteria

- [ ] Integrate `check-hooks.sh` into the drift-check GitHub Action
- [ ] Add wiki template version checking
- [ ] Add settings.json structure comparison

---

### Unit Test Infrastructure in Product Engineer Template

**Status:** Planned
**Priority:** High

The product engineer template has Playwright for e2e but no unit testing framework. The unit-testing standard requires a `test:unit` script but the template's package.json does not include one.

### Acceptance Criteria

- [ ] Add Vitest (or similar) to template package.json
- [ ] Add `npm run test:unit` script
- [ ] Add Gate 2 step requiring unit test results
- [ ] Add CI workflow running unit tests on every PR

### Notes

This was identified and scoped in a previous session. Implementation was approved but not yet started.

---

### Consumer Project Freshness

**Status:** Planned
**Priority:** Low

Some consumer projects in `consumers.json` may have been bootstrapped before recent standard additions (unit-testing, http-diagnostics, hooks). There is no systematic way to track which standards each consumer has adopted vs. which are available.

### Acceptance Criteria

- [ ] Add `embedded_standards` field to consumers.json entries
- [ ] Drift detection reports which optional standards a consumer has NOT adopted

---

### Self-Referential Git Workflow Enforcement

**Status:** Planned
**Priority:** Medium

The claude-templates repo itself lacks the enforcement hooks it prescribes for consumer projects. Direct pushes to main are possible.

### Acceptance Criteria

- [ ] Install git and versioning hooks in this repo
- [ ] Add branch protection or hook-based enforcement against direct main pushes
- [ ] Add `.claude/settings.json` with hook configuration

### Notes

Identified in a previous session. The repo dogfoods its standards in CLAUDE.md but does not enforce them mechanically.

---

### Automated Consumer Onboarding Validation

**Status:** Planned
**Priority:** Low

When a new project is bootstrapped via `/new-project`, the verification step is manual. A CI check could validate that new consumers.json entries have correct structure and that the referenced repos exist.

### Acceptance Criteria

- [ ] CI workflow that validates consumers.json schema
- [ ] Check that listed repos are accessible
- [ ] Check that referenced template type is valid

---

### Standard Dependency Graph

**Status:** Planned
**Priority:** Low

Standards reference each other (workflow references unit-testing, git references versioning) but these dependencies are not formally tracked. A breaking change in one standard could cascade to others.

### Acceptance Criteria

- [ ] Document which standards depend on which
- [ ] Drift detection warns when a dependent standard is outdated
