---
name: commit
description: Create a conventional commit — auto-detect changes, pick correct type/scope, write message
argument-hint: "[message]"
---

# /commit — Create a conventional commit

Create a well-structured git commit following Conventional Commits spec.

## Usage
`/commit` — auto-detect changes and propose commit message
`/commit <message>` — use provided message as base

## Conventional Commits format
```
<type>(<scope>): <short description>

[optional body]
```

**Types:**
| Type | When to use |
|------|------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code change (not feat/fix) |
| `chore` | Build, deps, config (no prod code) |
| `test` | Adding/fixing tests |
| `docs` | Documentation only |
| `style` | Formatting only (no logic change) |
| `perf` | Performance improvement |

**Scopes for this project:**
`api`, `client`, `db`, `auth`, `users`, `roles`, `permissions`, `docker`, `nginx`

## Examples
```
feat(api): add attendance check-in endpoint with GPS validation
fix(auth): resolve 401 on public routes missing @Public decorator
chore(docker): update node base image to 20-alpine
refactor(users): extract password hashing to shared utility
```

## Process

1. Run `git diff --staged` (or `git diff HEAD` if nothing staged) to see changes
2. Identify the type and scope from the diff
3. Write a short description (≤72 chars, imperative mood: "add" not "added")
4. Add body if the change is non-obvious
5. Stage relevant files and commit:

```bash
git add <specific files>   # never `git add .` without reviewing
git commit -m "$(cat <<'EOF'
type(scope): description

Optional body explaining why, not what.
EOF
)"
```

Do not skip pre-commit hooks (`--no-verify`) unless user explicitly asks.
Do not include unrelated files in the same commit.
