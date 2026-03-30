---
paths:
  - "**/*.test.*"
---

<!-- standard: unit-testing | version: 1.1.0 -->
# Unit Testing Standard

> **Source of truth** for unit testing requirements across all Claude-powered projects.

---

## Overview

Unit tests enforce function-level contracts and catch regressions early. When a shared function or dependency changes, unit tests fail immediately — showing exactly what broke and where.

This standard is **framework-agnostic**. Each project chooses its own test runner (Vitest, Jest, pytest, Go test, etc.).

---

## Test Script Contract

Every project MUST expose a unit test command that satisfies this contract:

| Requirement | Detail |
|---|---|
| Script name | `test:unit` in `package.json`, or the language-idiomatic equivalent (`pytest`, `go test ./...`, etc.) |
| Exit code | `0` on all-pass, non-zero on any failure |
| Stdout output | Human-readable summary: total, passed, failed, skipped, coverage % |

If a project uses `package.json`, the script must be runnable via `npm run test:unit`.

---

## Coverage Requirements

- **80% minimum line coverage** — enforced on every run
- New code must have corresponding tests — no shipping untested functions
- Coverage exceptions: generated code, type definitions, config files

---

## What to Test

- Pure functions and utilities
- Business logic and domain rules
- Data transformations and formatting
- Edge cases: nulls, empty inputs, boundary values, overflow
- Error paths: invalid input, missing data, thrown exceptions

---

## What NOT to Test (at unit level)

- External API calls — mock them
- Database queries — integration test territory
- UI rendering details — e2e test territory
- Framework internals — trust the framework

---

## Test Organization

**File placement** — choose one convention per project and stay consistent:

| Convention | Example |
|---|---|
| Co-located | `src/utils/format.ts` → `src/utils/format.test.ts` |
| Mirror directory | `src/utils/format.ts` → `__tests__/utils/format.test.ts` |

**Naming:** `<module>.test.<ext>` or `<module>_test.<ext>` (Go convention).

---

## Test Quality Rules

1. **One behaviour per test** — if a test name contains "and", split it
2. **Descriptive names** — describe the expected behaviour, not the method name
   - Good: `returns empty array when input is null`
   - Bad: `test processData`
3. **No interdependencies** — each test runs in isolation, any order
4. **No magic values** — use descriptive constants or named variables
5. **Prefer real objects over mocks** when cheap to construct — mocks can mask real bugs
6. **Test the contract, not the implementation** — assert outputs and side effects, not internal state
