---
name: test
description: Run Jest unit tests and coverage for the NestJS API
argument-hint: "[cov|lint]"
---

# /test — Run Tests

Run tests for the Attendance API.

## Context
- Test framework: Jest (via NestJS defaults)
- Test files: `sources/attendance_api/src/**/*.spec.ts`
- Container: `attendance_api`

## Usage
`/test [scope]`

| Scope | Command | Description |
|-------|---------|-------------|
| (none) | `make api-test` | Run all unit tests |
| `cov` | `make api-test-cov` | Run tests with coverage report |
| `lint` | `make api-lint` | Lint check (no fix) |

## What to do
1. Run the appropriate `make` command from `/Users/trucnguyen/Documents/projects/training/`
2. Parse test output and report:
   - Total passed / failed / skipped
   - Any failing test names with the error message
3. For failing tests, read the relevant `.spec.ts` file and diagnose the root cause
4. Suggest fixes only for failing tests — do not refactor passing tests
