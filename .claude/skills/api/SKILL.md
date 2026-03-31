---
name: api
description: NestJS API tasks — scaffold resource, lint, test, build, install inside attendance_api container
argument-hint: "[shell|lint|format|build|test|test-cov|install|reinstall|resource <name>]"
---

# /api — NestJS API Tasks

Perform common API development tasks inside the `attendance_api` container.

## Context
- Framework: NestJS (TypeScript)
- ORM: TypeORM
- Guard: JWT global guard (`@Public()` to bypass)
- Modules: `src/modules/` (auth, users, roles, permissions, countries, permission_groups, user_group_permissions)
- DB config: `src/core/database/data-source.ts`

## Usage
`/api [action] [options]`

| Action | Make Command | Description |
|--------|-------------|-------------|
| `shell` | `make api` | Open shell in API container |
| `lint` | `make api-lint-fix` | Lint and auto-fix |
| `format` | `make api-format` | Run Prettier |
| `build` | `make api-build` | Compile NestJS |
| `test` | `make api-test` | Run unit tests |
| `test-cov` | `make api-test-cov` | Tests with coverage |
| `install` | `make api-npm-i` | Install dependencies |
| `reinstall` | `make api-renpm-i` | Clean install |
| `resource <name>` | `make create-resource name=modules/<name>` | Scaffold NestJS resource |

## What to do
- Parse the argument and run the corresponding `make` command from `/Users/trucnguyen/Documents/projects/training/`
- For `resource`, extract the module name and run `make create-resource name=modules/<name>`
- If no argument given, show current API logs: `make logs-api`
- When scaffolding a resource, explain the generated files (controller, service, module, entity, dto) and next steps (register in app.module.ts if needed, add migration)
