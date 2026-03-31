# Plan: Thêm Filter cho các trang List

## Phạm vi
7 trang list cần filter (Users đã có sẵn):

| Module | Filter fields | Loại |
|--------|--------------|------|
| Companies | search (text), country_id (autocomplete), city_id (autocomplete) | text + relation |
| Departments | search (text) | text only |
| Roles | search (text) | text only |
| Permissions | search (text) | text only |
| Permission Groups | search (text) | text only |
| Cities | search (text), country_id (autocomplete) | text + relation |
| Countries | search (text) | text only |

`search` sẽ tìm kiếm LIKE trên các trường text chính (name, slug, descriptions...).

## Approach

### 1. Tạo generic `FilterPanel` component
**File mới**: `components/common/FilterPanel.vue`
- Props: `v-model` (filters object), `expanded`, `searchLabel`, `fields` (config cho additional fields như autocomplete/select)
- Render: 1 text field "search" + dynamic fields từ config + nút "Clear filter"
- Dùng `v-expand-transition` giống UserFilterPanel

### 2. Nâng cấp `useCrudPage` composable
**File sửa**: `composables/useCrudPage.ts`
- Thêm option `filterFn` — static method filter trên service
- Thêm state: `filters`, `filterExpanded`, `activeFilterCount`, `isFilterActive`
- Thêm methods: `resetFilters`, auto-debounce 300ms trên filters change
- Khi có filter active → gọi `service.filter(params)`, không thì `service.getAll()`
- Giữ backward compatible — pages không dùng filter vẫn hoạt động bình thường

### 3. API — Controller + Service (7 modules, mỗi module 2 file)

**Controller pattern** — thêm `@Query` params:
```typescript
@Get()
@Permissions('read')
findAll(
  @Query('search') search?: string,
  // + relation-specific params cho cities/companies
) {
  const hasFilter = search || ...
  if (hasFilter) return this.xxxService.findWithFilters({ search, ... })
  return this.xxxService.findAll()
}
```

**Service pattern** — thêm `findWithFilters()`:
```typescript
async findWithFilters(params: { search?: string, ... }): Promise<Xxx[]> {
  const queryBuilder = this.xxxRepository.createQueryBuilder('alias')
  if (params.search) {
    queryBuilder.andWhere('(alias.name LIKE :search OR alias.slug LIKE :search)',
      { search: `%${params.search.toLowerCase()}%` })
  }
  // + relation filters cho cities/companies
  return queryBuilder.getMany()
}
```

### 4. Client Service — thêm `filter()` method (7 files)
Giống `UserService.filter()` — dùng `URLSearchParams` để build query string.

### 5. Page — thêm filter toolbar + FilterPanel (7 pages)
- 6 pages dùng `useCrudPage`: chỉ cần thêm filter config vào composable options
- 1 page custom (Companies): thêm filter state + FilterPanel trực tiếp

## Thứ tự thực hiện

### Batch 1: Infrastructure
1. Tạo `components/common/FilterPanel.vue`
2. Nâng cấp `composables/useCrudPage.ts`

### Batch 2: Simple modules (text-only filter)
3. **Countries**: API controller/service + client service + page
4. **Departments**: API controller/service + client service + page
5. **Roles**: API controller/service + client service + page
6. **Permissions**: API controller/service + client service + page
7. **Permission Groups**: API controller/service + client service + page

### Batch 3: Complex modules (text + relation filter)
8. **Cities**: API + client service + page (filter by country)
9. **Companies**: API + client service + page (filter by country + city)

### Batch 4: Verify
10. `make api-lint-fix && make client-lint-fix`

## Files tổng cộng
- **Mới**: 1 (FilterPanel component)
- **Sửa**: ~23 files (7 controllers, 7 services, 7 client services, 1 composable, 7 pages — nhưng nhiều page chỉ sửa vài dòng vì dùng composable)
