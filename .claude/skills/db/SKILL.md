---
name: db
description: Database operations — run/revert migrations, seeds, dump, restore, open MariaDB shell
argument-hint: "[migrate|revert|create <name>|seed|seed <file>|seed-create <name>|shell|dump|restore <file>]"
---

# /db — Database Operations

Manage MariaDB migrations, seeds, and backups for the Attendance project.

## Context
- DB: MariaDB · container: `attendance_mariadb`
- User: `root` · Password: `password` · Database: `attendance`
- Migrations dir: `src/core/database/migrations/`
- Seeds dir: `src/core/database/seeds/`
- DataSource: `src/core/database/data-source.ts`

## Usage
`/db [action] [options]`

| Action | Make Command | Description |
|--------|-------------|-------------|
| `migrate` | `make migrate` | Run all pending migrations |
| `revert` | `make migration-revert` | Revert last migration |
| `create <name>` | `make migration-create name=<name>` | Create migration file |
| `seed` | `make seed` | Run all seeders |
| `seed <file>` | `make seed-one file=<file>` | Run single seeder |
| `seed-create <name>` | `make seed-create name=<name>` | Create seeder file |
| `shell` | `make db` | Open MariaDB CLI |
| `dump [file]` | `make db-dump [db_dump_file=<file>]` | Dump DB to SQL file |
| `restore <file>` | `make db-restore db_dump_file=<file>` | Restore from SQL file |

## What to do
- Parse the action and run the corresponding `make` command from `/Users/trucnguyen/Documents/projects/training/`
- For `create`, format name as snake_case (e.g., `create_attendance_table`)
- For destructive actions (`revert`, `restore`), warn the user and confirm before proceeding
- After `migrate`, suggest running `make seed` if this is a fresh setup
- If no argument, show migration status by opening DB shell with: `make db`
