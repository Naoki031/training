# ------------------------------------------------------------
# For API development
# ------------------------------------------------------------
api_dockerName=attendance_api
api_dataSource=src/core/database/data-source.ts
api_migrationDir=src/core/database/migrations
api_seedDir=src/core/database/seeds

up:
	COMPOSE_BAKE=true docker compose up -d

up-build:
	COMPOSE_BAKE=true docker compose up -d --build

build:
	docker compose build --no-cache --force-rm

stop:
	docker compose stop

down:
	docker compose down --remove-orphans

restart:
	@make down
	@make up

logs:
	docker compose logs

ps:
	docker compose ps

api:
	docker container exec -it $(api_dockerName) /bin/sh

api-renpm-i:
	docker container exec -it $(api_dockerName) bash -c 'rm -rf node_modules package-lock.json && npm install'

api-npm-i:
	docker container exec -it $(api_dockerName) npm install

api-npm-dev:
	docker container exec -it $(api_dockerName) npm run dev

api-npm-build:
	docker container exec -it $(api_dockerName) npm run build

# make migration-create name=create_users_table
migration-create:
	docker container exec -it $(api_dockerName) bash -c 'npx typeorm migration:create $(api_migrationDir)/$(name)'

# make migrate
migrate:
	docker container exec -it $(api_dockerName) bash -c 'npm run typeorm migration:run -- --dataSource $(api_dataSource)'

# make seed-create name=seed_name.ts
seed-create:
	docker container exec -it $(api_dockerName) bash -c 'npm run seed:create -- --name $(api_seedDir)/$(name)'

# make seed
seed:
	docker container exec -it $(api_dockerName) bash -c 'npm run seed'

# make seed-one file=permission_group.seeder.ts
seed-one:
	docker container exec -it $(api_dockerName) bash -c 'npm run seed:run -- --name src/core/database/seeds/$(file) --dataSource src/core/database/data-source.ts'

# make create-resource name=modules/users
create-resource:
	docker container exec -it $(api_dockerName) bash -c 'nest g resource $(name)'

# ------------------------------------------------------------
# For Client development
# ------------------------------------------------------------
client_dockerName=attendance_client

client:
	docker container exec -it $(client_dockerName) /bin/sh

client-renpm-i:
	docker container exec -it $(client_dockerName) bash -c 'rm -rf node_modules package-lock.json && npm install'

client-i:
	docker container exec -it $(client_dockerName) npm install

client-dev:
	docker container exec -it $(client_dockerName) npm run dev

client-build:
	docker container exec -it $(client_dockerName) npm run build