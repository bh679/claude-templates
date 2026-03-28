# Plan: Unit Testing + Runtime Diagnostics for Product Engineer

## Context

The product-engineer template currently only has Playwright e2e tests and curl-based API testing at Gate 2. There are no unit testing requirements and no runtime diagnostics. This means:
- Regression bugs slip through because function-level contracts aren't tested
- Debugging deployed features requires manual investigation with no structured data
- Gate 2 reports lack coverage metrics and health verification

This plan adds two capabilities as **instructions in CLAUDE.md** (no boilerplate code files):
1. **Framework-agnostic unit testing** — defines the contract (scripts, coverage threshold, reporting) but lets each project choose its runner
2. **Runtime diagnostics** — instructs the product engineer to always build health endpoints, error logging, usage tracking, and bug context snapshots into every app, using structured JSON files

---

## Files to Modify (4 files)

### 1. `standards/workflow.md` (source of truth)

**Gate 2 section** (lines 67-84) — expand agent actions:

```
1. Run unit tests (project's chosen runner) — verify 80%+ line coverage
2. Run integration/e2e tests (curl for APIs, Playwright MCP for UI)
3. Verify health check endpoint: `curl -s http://localhost:<port>/health | jq .`
4. Take screenshots using `browser_take_screenshot`
5. Use `browser_snapshot` for accessibility tree analysis
6. Enter plan mode with **Gate 2 Testing Report** containing:
   - Unit test summary: total, passed, failed, skipped, coverage %
   - Health check response JSON
   - Screenshot paths (for blogging)
   - Clickable local URL with port
   - Step-by-step user testing instructions
   - Integration/e2e test results
   - What passed / what failed
```

### 2. `templates/product-engineer/CLAUDE.md` (template)

**A. Expand Gate 2** (lines 58-68) to match the updated standard — add unit test run, health check verification, and expanded report format.

**B. Add `### Unit Testing` subsection** (after line 177, before API Testing):

```markdown
### Unit Testing

Each project chooses its own test runner (Vitest, Jest, pytest, Go test, etc.).

**Contract:**
- A `test:unit` script (or project equivalent) must exist
- Must exit 0 on all-pass, non-zero on failure
- Must produce human-readable pass/fail summary and coverage % to stdout
- Minimum 80% line coverage

**Gate 2 requirement:** Run unit tests before presenting the Testing Report.
Include: total tests, passed, failed, skipped, coverage %.
```

**C. Add new `## Runtime Diagnostics` section** (after Testing section, before Documentation — between lines 200-201):

Instructs the product engineer to build four capabilities into every app:

1. **Health endpoint** (`GET /health`) returning JSON: status, version, uptime, timestamp
2. **Error logging** to `./diagnostics/errors.jsonl` — structured JSON per line with timestamp, level, message, stack, context (env, version, git SHA, runtime)
3. **Usage tracking** to `./diagnostics/usage.jsonl` — event name, timestamp, metadata
4. **Bug context snapshots** to `./diagnostics/snapshots/<timestamp>-<hash>.json` — error details + environment info + dependency list + recent events + system stats

Includes the JSON schemas inline and notes:
- Create `./diagnostics/` with `.gitkeep`
- Add `diagnostics/*.jsonl` and `diagnostics/snapshots/` to `.gitignore`
- Implement log rotation appropriate to deployment
- For non-filesystem deployments, redirect to a logging service

### 3. `templates/product-engineer/package.json`

Add `test:unit` script placeholder:
```json
"test:unit": "echo 'Configure test:unit for your chosen test runner' && exit 1"
```

The exit 1 forces the consumer to replace it — same pattern as `{{TOKENS}}`.

### 4. `templates/README.md`

Add to bootstrapping checklist (section "1. Project-level setup"):
```
- [ ] Create `<project>/diagnostics/.gitkeep`
- [ ] Add `diagnostics/*.jsonl` and `diagnostics/snapshots/` to `.gitignore`
- [ ] Update `test:unit` script in `package.json` for your chosen test runner
```

Update file structure diagram to include `diagnostics/` directory.

---

## Verification

1. Read all 4 modified files and verify internal consistency
2. Confirm Gate 2 in `standards/workflow.md` and `templates/product-engineer/CLAUDE.md` match
3. Verify `package.json` has the `test:unit` script
4. Verify `templates/README.md` bootstrapping checklist includes diagnostics setup
5. Run drift check script to ensure no consumer format issues: `bash .github/scripts/check-drift.sh`

---

## Single Commit

```
feat: add unit testing contract and runtime diagnostics to product-engineer template
```
