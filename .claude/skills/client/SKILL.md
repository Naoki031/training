---
name: client
description: Nuxt.js client tasks — build, lint, shell, logs inside attendance_client container
argument-hint: "[shell|lint|format|build|prepare|install|reinstall|logs]"
---

# /client — Nuxt.js Client Tasks

Perform common client development tasks inside the `attendance_client` container.

## Context
- Framework: Nuxt.js 3 (Vue 3, Composition API)
- Structure: `pages/`, `components/`, `composables/`, `stores/`, `services/`, `layouts/`, `middleware/`
- Container: `attendance_client`
- URL: http://localhost:3000

## Usage
`/client [action]`

| Action | Make Command | Description |
|--------|-------------|-------------|
| `shell` | `make client` | Open shell in Client container |
| `lint` | `make client-lint-fix` | Lint and auto-fix |
| `format` | `make client-format` | Run Prettier |
| `build` | `make client-build` | Nuxt production build |
| `prepare` | `make client-prepare` | Regenerate `.nuxt/` (after install) |
| `install` | `make client-npm-i` | Install dependencies |
| `reinstall` | `make client-renpm-i` | Clean install |
| `logs` | `make logs-client` | Tail client logs |

## What to do
- Parse the action and run the corresponding `make` command from `/Users/trucnguyen/Documents/projects/training/`
- If no argument, run `make logs-client` to show current client output
- For Vue/Nuxt questions, reference the actual files in `sources/attendance_client/` before answering
