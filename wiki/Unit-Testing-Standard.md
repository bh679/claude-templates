[Home](Home) > [Features](Features) > Unit Testing Standard

# Unit Testing Standard

Framework-agnostic unit testing requirements enforced across all projects, with 80% minimum line coverage.

## How It Works

Every project exposes a unit test command (`test:unit` in package.json or language equivalent) that returns exit code 0 on all-pass, non-zero on failure, and outputs a human-readable summary.

### What to Test

- Pure functions and utilities
- Business logic and domain rules
- Data transformations and formatting
- Edge cases: nulls, empty inputs, boundary values
- Error paths: invalid input, missing data, exceptions

### What NOT to Test at Unit Level

- External API calls (mock them)
- Database queries (integration test territory)
- UI rendering details (e2e test territory)
- Framework internals

### Test Quality Rules

1. One behaviour per test
2. Descriptive names describing expected behaviour
3. No interdependencies between tests
4. No magic values
5. Prefer real objects over mocks when cheap
6. Test the contract, not the implementation

## Technical Notes

- Current version: 1.0.0
- Integrated into Gate 2 of the three-gate workflow
- File placement: co-located or mirror directory (choose one per project)
- Coverage exceptions: generated code, type definitions, config files

## Related

- [Three-Gate Workflow](Three-Gate-Workflow)
- [Standards](Standards)
