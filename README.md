# Attendance Management System

Full-stack attendance management system with biometric device integration, leave/WFH/overtime request workflows, Slack notifications, Google Sheets export, AI chatbot, and push notifications.

**Stack:** NestJS + TypeORM + MariaDB | Nuxt 3 + Vuetify 4 + Tailwind CSS | Nginx | Docker Compose

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose v2+
- Make (GNU)
- Git

---

## Quick Start

```bash
# 1. Clone repository
git clone <repo-url>
cd training

# 2. Create environment files
cp sources/attendance_api/.env.example sources/attendance_api/.env
cp sources/attendance_client/.env.example sources/attendance_client/.env

# 3. Edit API env — change at minimum:
#    JWT_KEY=<your-secret>
#    QR_SECRET=<your-qr-secret>

# 4. Build & start all services
make up-build

# 5. Run database migrations
make migrate

# 6. Seed initial data (roles, permissions, admin account)
make seed
```

Open http://localhost in your browser.

---

## Access

| Service | URL |
|---------|-----|
| Application (Nginx) | http://localhost |
| API (direct) | http://localhost:3001/api/v1 |
| MariaDB | localhost:3306 |

---

## Architecture

```
                  ┌───────────┐
                  │  Browser  │
                  └─────┬─────┘
                        │ :80
                  ┌─────▼─────┐
                  │   Nginx   │
                  └─┬───────┬─┘
                    │       │
           /api/*   │       │  /*
           /uploads │       │  /_nuxt/hmr
           /iclock  │       │
                    │       │
           ┌────────▼┐   ┌──▼───────┐
           │  API    │   │  Client  │
           │  :3001  │   │  :3000   │
           └────┬────┘   └──────────┘
                │
           ┌────▼─────┐
           │ MariaDB  │
           │  :3306   │
           └──────────┘
```

### Directory Structure

```
.
├── .docker/                  # Docker configurations
│   ├── client/               # Nuxt client Dockerfile
│   ├── mariadb/              # MariaDB Dockerfile + my.cnf
│   ├── nginx/                # Nginx Dockerfile & configs (development.conf, staging.conf)
│   ├── node_server/          # NestJS API Dockerfile + entrypoint
│   └── pma/                  # phpMyAdmin Dockerfile (staging only)
├── .github/workflows/        # CI/CD — deploy_staging.yml
├── sources/
│   ├── attendance_api/       # NestJS backend
│   │   ├── src/modules/      # Feature modules
│   │   ├── src/core/         # Database, constants
│   │   └── .env              # API environment variables
│   └── attendance_client/    # Nuxt frontend
│       ├── pages/            # Routes (home, chat, clock, login, management, profile, requests)
│       ├── components/       # Vue components
│       ├── composables/      # Reusable logic
│       ├── i18n/locales/     # Translations (en, vi, ja)
│       └── types/            # TypeScript type definitions
├── zk-relay/                 # ZKTeco device relay agent (standalone)
├── docker-compose.yml        # Development environment
├── docker-compose.staging.yml # Staging environment
├── .env.staging.docker.example # Staging env template
├── Makefile
└── CLAUDE.md                 # AI assistant conventions
```

### API Modules

| Module | Description |
|--------|-------------|
| `auth` | JWT authentication, login/register |
| `users` | User CRUD, profile management |
| `roles` | Role-based access control |
| `permissions` / `permission_groups` | Permission management |
| `groups` | User groups |
| `attendance_logs` | Attendance record tracking |
| `attendance_sync` | ZKTeco device sync |
| `iclock` | ZKTeco ICLOCK push protocol handler |
| `employee_requests` | Leave, WFH, overtime requests |
| `departments` | Department management |
| `user_departments` | User-department assignments |
| `companies` | Company management |
| `countries` / `cities` | Location data |
| `events` | Calendar events |
| `google_sheets` | Google Sheets export |
| `google_calendar` | Google Calendar integration |
| `messages` / `message_reactions` | In-app messaging |
| `chat` / `chatbot` | AI chatbot (Claude) |
| `translate` | Translation service |
| `slack_channels` | Slack integration for bug reports |
| `bug_reports` | Bug report management |
| `firebase` | Push notifications (FCM) |
| `user_work_schedules` | Work schedule assignments |
| `user_group_permissions` | User group permission assignments |

### Docker Services (Development)

| Service | Container | Port | Description |
|---------|-----------|------|-------------|
| nginx | attendance_nginx | 80 | Reverse proxy |
| api | attendance_api | 3001, 9229 | NestJS API + Node debugger |
| client | attendance_client | 3000, 24678 | Nuxt dev server + HMR |
| mariadb | attendance_mariadb | 3306 | MariaDB database |

### Docker Services (Staging)

| Service | Container | Port | Description |
|---------|-----------|------|-------------|
| nginx | attendance | 10080 | Reverse proxy (HTTPS redirect) |
| api | attendance_api | 3001 (internal) | NestJS API (production build) |
| client | attendance_client | 3000 (internal) | Nuxt SSR (production build) |

> Staging uses an external `shared` Docker network. No MariaDB container — connects to an external database. phpMyAdmin available on port 10080.

---

## Make Commands

Run `make help` for the full list.

### Docker

| Command | Description |
|---------|-------------|
| `make up` | Start all containers |
| `make up-build` | Start with image rebuild |
| `make down` | Stop and remove containers |
| `make build` | Build all images (no cache) |
| `make rebuild` | Full clean rebuild (removes volumes) |
| `make restart` | Restart all containers |
| `make stop` | Stop containers (keep state) |
| `make ps` | List running containers |
| `make stats` | Live resource usage |
| `make logs` | Tail all logs |
| `make logs-api` | Tail API logs |
| `make logs-client` | Tail Client logs |
| `make logs-db` | Tail MariaDB logs |
| `make clean-volumes` | Remove node_modules volumes |
| `make prune` | Remove stopped containers, dangling images, unused volumes |

### Database

| Command | Description |
|---------|-------------|
| `make migrate` | Run pending migrations |
| `make migration-revert` | Revert last migration |
| `make migration-create name=<n>` | Create new migration |
| `make seed` | Run all seeders |
| `make seed-create name=<n>` | Create new seeder |
| `make seed-one file=<n>` | Run specific seeder |
| `make db` | Open MariaDB CLI |
| `make db-shell` | Open shell in MariaDB container |
| `make db-dump` | Dump to `dump.sql` |
| `make db-restore` | Restore from `dump.sql` |

### API

| Command | Description |
|---------|-------------|
| `make api` | Open shell in API container |
| `make api-npm-i` | Install dependencies |
| `make api-renpm-i` | Clean install dependencies |
| `make api-build` | Build NestJS |
| `make api-lint` | Run ESLint (check only) |
| `make api-lint-fix` | Run ESLint auto-fix |
| `make api-format` | Run Prettier |
| `make api-test` | Run unit tests |
| `make api-test-cov` | Run tests with coverage |

### Client

| Command | Description |
|---------|-------------|
| `make client` | Open shell in Client container |
| `make client-npm-i` | Install dependencies |
| `make client-renpm-i` | Clean install dependencies |
| `make client-build` | Build for production |
| `make client-lint` | Run ESLint (check only) |
| `make client-lint-fix` | Run ESLint auto-fix |
| `make client-format` | Run Prettier |
| `make client-prepare` | Regenerate .nuxt/ |

### Scaffold

| Command | Description |
|---------|-------------|
| `make create-resource name=modules/<n>` | Scaffold a NestJS resource |

### Staging

| Command | Description |
|---------|-------------|
| `make stg-up` | Start staging containers |
| `make stg-up-build` | Start staging with rebuild |
| `make stg-build` | Build staging images (no cache) |
| `make stg-down` | Stop staging containers |
| `make stg-restart` | Restart staging containers |
| `make stg-logs` | Tail staging logs |
| `make stg-ps` | List staging containers |
| `make stg-api` | Open shell in staging API |
| `make stg-client` | Open shell in staging client |
| `make stg-nginx-reload` | Reload nginx config |
| `make stg-migrate` | Run pending migrations (staging) |
| `make stg-seed` | Run seeders (staging) |

---

## Environment Variables

### API — `sources/attendance_api/.env`

#### Core

| Variable | Default | Description |
|----------|---------|-------------|
| `NODE_ENV` | `development` | Environment mode |
| `PORT` | `3001` | API server port |
| `API_PREFIX` | `api/v1` | API route prefix |
| `JWT_KEY` | `random_secret_key` | JWT signing key (**change in production**) |
| `JWT_EXPIRATION_TIME` | `3600` | Token expiry (seconds) |
| `SALT_ROUNDS` | `10` | Bcrypt salt rounds |
| `CLIENT_URL` | `http://localhost` | Client URL for Slack links |

#### Database

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `attendance_mariadb` | Database host (container name) |
| `DB_PORT` | `3306` | Database port |
| `DB_USER` | `root` | Database user |
| `DB_PASS` | `password` | Database password (**change in production**) |
| `DB_NAME` | `attendance` | Database name |
| `DB_DIALECT` | `mysql` | Database dialect |

#### Google Sheets (Optional)

| Variable | Description |
|----------|-------------|
| `GOOGLE_SHEETS_KEY_FILE` | Path to service account JSON |
| `GOOGLE_SHEETS_CREDENTIALS` | JSON credentials as string |
| `GOOGLE_SHEETS_SPREADSHEET_ID` | Default spreadsheet ID |
| `GOOGLE_SHEETS_SHEET_NAME` | Default sheet name |

#### ZKTeco Biometric Device (Optional)

| Variable | Description |
|----------|-------------|
| `ZK_DEVICE_IP` | Device IP address |
| `ZK_DEVICE_PORT` | Device port (default: 4370) |
| `ZK_DEVICE_TIMEOUT` | Device timeout ms (default: 5000) |
| `ZK_SYNC_FROM_DATE` | Start date for sync (default: 2025-01-01) |
| `ZK_AUTO_SYNC_ENABLED` | Auto sync every minute (default: false) |
| `ZK_ALLOWED_SNS` | Comma-separated allowed serial numbers |

#### QR Check-in

| Variable | Description |
|----------|-------------|
| `QR_SECRET` | Secret for QR clock-in (**required**) |

#### AI Chatbot (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| `ANTHROPIC_API_KEY` | — | Anthropic API key |
| `CHATBOT_TONE` | `professional` | professional / friendly / concise |
| `CHATBOT_MODEL` | `claude-sonnet-4-6` | Claude model ID |
| `TRANSLATE_MODEL` | — | Separate model for translation |

#### Slack Error Notifications (Optional)

| Variable | Description |
|----------|-------------|
| `SLACK_ERROR_WEBHOOK_URL` | Webhook URL for error alerts |
| `SLACK_ERROR_CHANNEL_ID` | Override channel ID |
| `SLACK_ERROR_MENTION_USER_IDS` | Comma-separated user IDs to mention |
| `SLACK_ERROR_MENTION_GROUPS` | Comma-separated group handles to mention |

#### Firebase Push Notifications (Optional)

| Variable | Description |
|----------|-------------|
| `FIREBASE_PROJECT_ID` | Firebase project ID |
| `FIREBASE_CLIENT_EMAIL` | Service account email |
| `FIREBASE_PRIVATE_KEY` | Service account private key |

### Client — `sources/attendance_client/.env`

| Variable | Default | Description |
|----------|---------|-------------|
| `NUXT_PUBLIC_API_BASE_URL` | `http://localhost:3001/api/v1` | API endpoint |
| `NUXT_PUBLIC_WS_URL` | `http://localhost:3001` | WebSocket URL |
| `NUXT_PUBLIC_FIREBASE_*` | — | Firebase Web SDK config (optional) |

### Staging — `.env.staging.docker`

Shared env file for both API and Client containers on staging. See [.env.staging.docker.example](.env.staging.docker.example) for full reference.

Key differences from development:
- `APP_URL` — set to staging domain (e.g. `https://attendance.example.com`)
- `DB_HOST` — points to external database host (no MariaDB container)
- `NODE_ENV=production`
- `NUXT_PUBLIC_API_BASE_URL` and `NUXT_PUBLIC_WS_URL` derived from `APP_URL`

---

## ZKTeco Device Integration

### Direct connection (API pulls from device)

Set `ZK_DEVICE_IP`, `ZK_DEVICE_PORT`, and optionally `ZK_AUTO_SYNC_ENABLED=true` in the API `.env`.

### Relay agent (for remote/unreachable devices)

The `zk-relay/` directory contains a standalone Node.js agent that pulls attendance data from a ZKTeco device on a local network and pushes it to the staging/production API.

```bash
cd zk-relay
npm install
# Edit config.js with device IP and API URL
node relay.js
```

---

## Development Guide

### Adding a new database column

```bash
make migration-create name=add_column_to_table
# Edit the migration file (up + down)
make migrate
```

Then update all 6 places: entity, DTO, frontend form type, Yup schema, form initial values, resetForm values.

### Adding a new API module

```bash
make create-resource name=modules/<module_name>
```

Register the new entity in:
1. Module's `TypeOrmModule.forFeature()`
2. `src/core/database.providers.ts`
3. `src/core/data-source.ts`

### Coding conventions

- Code and comments in **English**
- No abbreviations (ESLint enforced): `value` not `val`, `error` not `err`
- Vue refs always generic: `ref<T[]>([])`, `useField<string>('f')`
- Type-only imports: `import type { }`
- i18n: escape `@` as `{'@'}` in locale JSON

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Container won't start | `make logs-api` or `make logs-client` |
| Stale dependencies | `make clean-volumes` then `make up-build` |
| Migration fails | Check DB: `make db` |
| Port conflict | Stop services on ports 80, 3001, 3306 |
| Nuxt type errors | `make client-lint-fix` |
| API not responding | Verify `.env` exists, `DB_HOST=attendance_mariadb` |

### Full reset

```bash
make rebuild
make migrate
make seed
```

---

## CI/CD

- **Branch:** `staging` → auto-deploy via GitHub Actions (`.github/workflows/deploy_staging.yml`)
- Deploys by SSH to staging server → `git pull` → `make stg-up-build`
- On failure: Slack notification via webhook

See [STAGING_DEPLOY.md](STAGING_DEPLOY.md) for detailed deployment instructions.

---

## Contact

- Developer: Nguyen Trung Truc
- Email: trucnguyen.remvn031@gmail.com
