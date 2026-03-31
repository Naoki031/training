# Attendance Project

## Rules
- Code/comments: **English**. Explanations to user: **tiếng Việt**
- **No abbreviations** (ESLint enforced): `val→value`, `err→error`, `res→result`, `btn→button`, `e→error/event`
- All commands via `make` targets inside Docker — never `npm` on host
- `@Public()` to bypass global JWT guard · `import type { }` for type-only imports

## Stack
NestJS + TypeORM + MariaDB (`attendance_api`) · Nuxt 3 + Vuetify 4 (`attendance_client`) · Nginx · Docker Compose

## Make Targets
`up-build` `up` `down` `api` `client` `db` `migrate` `migration-revert` `migration-create name=<n>` `seed` `create-resource name=modules/<n>` `api-test` `api-lint-fix` `client-lint-fix`

## Verification
- New DB columns → migration with `up()` + `down()`
- Vue refs → always generic: `ref<T[]>([])`, `useField<string>('f')`
- New entity → register in 3 places: module `forFeature`, `database.providers.ts`, `data-source.ts`
- New DB column → add `@IsOptional()` to DTO (whitelist strips undecorated fields)
- API filter → update controller `@Query` + service `findWithFilters` together
- New user fields → update all 6 places: entity, DTO, form type, Yup schema, form initial values, resetForm values
- i18n: escape `@` as `{'@'}` in locale JSON — unplugin-vue-i18n treats `@` as linked message
- i18n: generic keys (clearFilter, etc.) go in `common` section, not feature-specific sections
- i18n: verify key exists at correct JSON path with `node -e "JSON.parse(fs.readFileSync('file')).section.key"`
- Dialog with vee-validate → use `watch(() => props.dialog, ...)` not `watchEffect` — `resetForm()`/`setFieldValue()` inside `watchEffect` causes re-run loop on every keystroke
- Sidebar route without matching i18n key in all 3 locales (en/vi/ja) renders as blank/invisible — always add key to `nav` section of all locale files
- Missing NestJS provider → `UnknownDependenciesException`. When service doesn't exist yet, stub with private method + `_paramName` for unused params instead of DI injection
- `moment.utc()` for server timestamps — server stores UTC, `moment()` parses as local time causing wrong display
- End of complex session → `/extract-patterns`
