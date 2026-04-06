.PHONY: help \
	up up-build build rebuild stop down restart \
	logs logs-api logs-client logs-db \
	ps stats \
	api api-shell api-npm-i api-renpm-i api-build api-lint api-lint-fix api-format api-test \
	migration-create migrate migration-revert \
	seed-create seed seed-one \
	create-resource \
	client client-shell client-npm-i client-renpm-i client-build client-lint client-lint-fix client-format \
	db db-shell db-dump db-restore \
	prune \
	stg-up stg-up-build stg-build stg-down stg-restart stg-logs stg-ps \
	stg-api stg-client stg-nginx-reload stg-migrate stg-seed \
	ngrok-up ngrok-url ngrok-down

# ============================================================
# Variables
# ============================================================
api_dockerName      = attendance_api
client_dockerName   = attendance_client
db_dockerName       = attendance_mariadb

api_dataSource      = src/core/database/data-source.ts
api_migrationDir    = src/core/database/migrations
api_seedDir         = src/core/database/seeds

db_user             = root
db_password         = password
db_name             = attendance
db_dump_file       ?= dump.sql

# ============================================================
# Help
# ============================================================
help: ## Show this help message
	@echo ''
	@echo 'Usage: make [target] [VAR=value]'
	@echo ''
	@awk 'BEGIN {FS = ":.*##"; section=""} \
		/^# ---/ { sub(/^# ---+ */, "", $$0); section=$$0; printf "\n\033[1;33m%s\033[0m\n", section } \
		/^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-28s\033[0m %s\n", $$1, $$2 }' \
		$(MAKEFILE_LIST)
	@echo ''

# ============================================================
# --- Docker Compose
# ============================================================

up: ## Start all containers (detached)
	COMPOSE_BAKE=true docker compose up -d

up-build: ## Start all containers, rebuild images first
	COMPOSE_BAKE=true docker compose up -d --build

build: ## Build all images (no cache)
	docker compose build --no-cache --force-rm

rebuild: ## Full clean rebuild: down → remove volumes → build → up
	docker compose down --remove-orphans --volumes
	docker compose build --no-cache --force-rm
	COMPOSE_BAKE=true docker compose up -d

stop: ## Stop all containers (keep state)
	docker compose stop

down: ## Stop and remove containers, networks
	docker compose down --remove-orphans

restart: ## Restart all containers
	@$(MAKE) down
	@$(MAKE) up

ps: ## List running containers
	docker compose ps

stats: ## Live resource usage of all containers
	docker stats $(api_dockerName) $(client_dockerName) $(db_dockerName)

logs: ## Tail logs of all containers
	docker compose logs -f

logs-api: ## Tail API logs
	docker compose logs -f api

logs-client: ## Tail Client logs
	docker compose logs -f client

logs-db: ## Tail MariaDB logs
	docker compose logs -f mariadb

clean-volumes: ## Remove node_modules volumes (fixes stale packages after version upgrades)
	docker compose down --remove-orphans
	docker volume rm -f \
		$$(docker volume ls -q | grep -E "attendance_(api|client)_node_modules|attendance_client_nuxt") \
		2>/dev/null || true
	@echo "Volumes removed. Run 'make up-build' to rebuild."

prune: ## Remove stopped containers, dangling images, unused volumes
	docker system prune -f
	docker volume prune -f

# ============================================================
# --- API
# ============================================================

api: ## Open shell in API container
	docker container exec -it $(api_dockerName) /bin/sh

api-shell: api ## Alias for `api`

api-npm-i: ## Install API dependencies
	docker container exec -i $(api_dockerName) npm install

api-renpm-i: ## Clean install API dependencies (remove node_modules first)
	docker container exec -i $(api_dockerName) sh -c 'rm -rf node_modules package-lock.json && npm install'

api-build: ## Build API (NestJS compile)
	docker container exec -i $(api_dockerName) npm run build

api-lint: ## Run ESLint on API (check only)
	docker container exec -i $(api_dockerName) npm run lint

api-lint-fix: ## Run ESLint on API and auto-fix
	docker container exec -i $(api_dockerName) npm run lint:fix

api-format: ## Run Prettier on API
	docker container exec -i $(api_dockerName) npm run format

api-test: ## Run API unit tests
	docker container exec -i $(api_dockerName) npm run test

api-test-cov: ## Run API tests with coverage
	docker container exec -i $(api_dockerName) npm run test:cov

# make migration-create name=create_users_table
migration-create: ## Create a new migration file  [name=<migration_name>]
	docker container exec -i $(api_dockerName) \
		sh -c 'npx typeorm migration:create $(api_migrationDir)/$(name)'

migrate: ## Run all pending migrations
	docker container exec -i $(api_dockerName) \
		sh -c 'npm run typeorm migration:run -- --dataSource $(api_dataSource)'

migration-revert: ## Revert the last executed migration
	docker container exec -i $(api_dockerName) \
		sh -c 'npm run typeorm migration:revert -- --dataSource $(api_dataSource)'

# make seed-create name=user_seeder.ts
seed-create: ## Create a new seeder file  [name=<seeder_name>.ts]
	docker container exec -i $(api_dockerName) \
		sh -c 'npm run seed:create -- --name $(api_seedDir)/$(name)'

seed: ## Run all seeders
	docker container exec -i $(api_dockerName) sh -c 'npm run seed'

# make seed-one file=permission_group.seeder.ts
seed-one: ## Run a single seeder  [file=<seeder_file>.ts]
	docker container exec -i $(api_dockerName) \
		sh -c 'npm run seed:run -- --name $(api_seedDir)/$(file) --dataSource $(api_dataSource)'

# make create-resource name=modules/users
create-resource: ## Scaffold a NestJS resource  [name=<path/name>]
	docker container exec -i $(api_dockerName) sh -c 'nest g resource $(name)'

# ============================================================
# --- Client
# ============================================================

client: ## Open shell in Client container
	docker container exec -it $(client_dockerName) /bin/sh

client-shell: client ## Alias for `client`

client-npm-i: ## Install Client dependencies
	docker container exec -i $(client_dockerName) npm install

client-renpm-i: ## Clean install Client dependencies (remove node_modules first)
	docker container exec -i $(client_dockerName) sh -c 'rm -rf node_modules package-lock.json && npm install'

client-build: ## Build Client (Nuxt production build)
	docker container exec -i $(client_dockerName) npm run build

client-lint: ## Run ESLint on Client (check only)
	docker container exec -i $(client_dockerName) npm run lint

client-lint-fix: ## Run ESLint on Client and auto-fix
	docker container exec -i $(client_dockerName) npm run lint:fix

client-format: ## Run Prettier on Client
	docker container exec -i $(client_dockerName) npm run format

client-prepare: ## Run nuxt prepare (regenerate .nuxt/)
	docker container exec -i $(client_dockerName) npm run postinstall

# ============================================================
# --- Database
# ============================================================

db: ## Open MariaDB CLI as root
	docker container exec -it $(db_dockerName) \
		mariadb -u$(db_user) -p$(db_password) $(db_name)

db-shell: ## Open shell in MariaDB container
	docker container exec -it $(db_dockerName) /bin/sh

# make db-dump [db_dump_file=my_backup.sql]
db-dump: ## Dump database to file  [db_dump_file=dump.sql]
	docker container exec $(db_dockerName) \
		mariadb-dump -u$(db_user) -p$(db_password) $(db_name) > $(db_dump_file)
	@echo "Dumped to $(db_dump_file)"

# make db-restore db_dump_file=my_backup.sql
db-restore: ## Restore database from file  [db_dump_file=dump.sql]
	docker container exec -i $(db_dockerName) \
		mariadb -u$(db_user) -p$(db_password) $(db_name) < $(db_dump_file)
	@echo "Restored from $(db_dump_file)"

# ============================================================
# --- Staging
# ============================================================

stg-up: ## [Staging] Start all containers
	docker compose -f docker-compose.staging.yml up -d

stg-up-build: ## [Staging] Start all containers, rebuild images first
	docker compose -f docker-compose.staging.yml up -d --build

stg-build: ## [Staging] Build all images (no cache)
	docker compose -f docker-compose.staging.yml build --no-cache --force-rm

stg-down: ## [Staging] Stop and remove containers
	docker compose -f docker-compose.staging.yml down --remove-orphans

stg-restart: ## [Staging] Restart all containers
	@$(MAKE) stg-down
	@$(MAKE) stg-up

stg-logs: ## [Staging] Tail logs of all containers
	docker compose -f docker-compose.staging.yml logs -f

stg-ps: ## [Staging] List running containers
	docker compose -f docker-compose.staging.yml ps

stg-api: ## [Staging] Open shell in API container
	docker container exec -it attendance_api /bin/sh

stg-client: ## [Staging] Open shell in Client container
	docker container exec -it attendance_client /bin/sh

stg-nginx-reload: ## [Staging] Reload nginx config without restart
	docker container exec attendance nginx -s reload

stg-migrate: ## [Staging] Run pending migrations
	docker container exec attendance_api \
		sh -c 'node ./node_modules/typeorm/cli.js migration:run -d dist/core/database/data-source.js'

stg-seed: ## [Staging] Run all seeders
	docker container exec attendance_api \
		sh -c 'node ./node_modules/typeorm-extension/bin/cli.cjs seed:run -d dist/core/database/data-source.js'

migrate-refresh: ## Drop all tables, re-run migrations, then seed (development only)
	@echo "Dropping all tables..."
	docker container exec -i $(api_dockerName) \
		sh -c 'npm run typeorm schema:drop -- --dataSource $(api_dataSource)'
	@echo "Running migrations..."
	@$(MAKE) migrate
	@echo "Seeding data..."
	@$(MAKE) seed
	@echo "Done! Database reset complete."

# ============================================================
# --- Ngrok (HTTPS tunnel for mobile testing)
# ============================================================

ngrok-up: ## Start ngrok tunnel (requires NGROK_AUTHTOKEN in .env)
	docker compose --profile ngrok up -d ngrok
	@echo "Ngrok starting... run 'make ngrok-url' in a few seconds"

ngrok-url: ## Show current public HTTPS tunnel URL
	@curl -s http://localhost:4040/api/tunnels 2>/dev/null \
		| python3 -c "import sys,json; tunnels=json.load(sys.stdin).get('tunnels',[]); print(tunnels[0]['public_url'] if tunnels else 'Ngrok not ready yet, try again')" \
		2>/dev/null || echo "Ngrok not running. Run 'make ngrok-up' first."

ngrok-down: ## Stop ngrok tunnel
	docker compose --profile ngrok stop ngrok
	docker compose --profile ngrok rm -f ngrok
