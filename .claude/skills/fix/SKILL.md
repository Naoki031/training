---
name: fix
description: Debug and fix a bug with root-cause analysis — diagnose, minimal fix, verify lint and tests
argument-hint: "<mô tả lỗi hoặc stack trace>"
---

# /fix — Debug và sửa lỗi

Chẩn đoán và sửa lỗi theo quy trình có hệ thống. **Code và comment viết bằng tiếng Anh. Giải thích cho người dùng bằng tiếng Việt.**

## Cách dùng
`/fix <mô tả lỗi hoặc dán stack trace>`

---

## BƯỚC 1 — Xác định layer

Đọc thông báo lỗi và tìm đúng file trước khi sửa bất kỳ thứ gì.

| Triệu chứng | Layer | Nơi cần xem |
|-------------|-------|-------------|
| `vue-tsc` / TypeScript error | Client | `.vue` file, interface, service |
| `401 Unauthorized` | API auth | Thiếu `@Public()`, JWT config |
| `403 Forbidden` | API permissions | `@Permissions()` / `PermissionsGuard` |
| `500` khi query DB | API service | TypeORM relations chưa load |
| DTO validation bị reject | API DTO | Thiếu decorator class-validator |
| Migration thất bại | DB | Kiểu column không khớp |
| Hydration mismatch | Client SSR | Dùng `useAsyncData` thay `onMounted` |
| `Cannot read property of undefined` | Client | Thiếu optional chaining hoặc type |
| CORS error | Nginx/Nuxt | Proxy trong `nuxt.config.ts` hoặc `app.enableCors()` |

---

## BƯỚC 2 — Đọc trước khi sửa

Luôn đọc file liên quan trước. **Không đoán mò.**

---

## BƯỚC 3 — Các lỗi phổ biến và cách sửa

### Lỗi vue-tsc (strict mode đang BẬT — `typescript: { strict: true, typeCheck: true }`)

**Thiếu generic trên `ref()`:**
```typescript
// ❌ sai
const items = ref([])
const item = ref(null)

// ✅ đúng
const items = ref<Array<CountryModel>>([])
const item = ref<CountryModel | null>(null)
```

**Sai kiểu prop:**
```typescript
// ❌ sai
const props = defineProps({ item: Object })

// ✅ đúng
import type { PropType } from 'vue'
const props = defineProps({
  item: { type: Object as PropType<CountryModel | null>, required: false, default: null }
})
```

**Import type sai:**
```typescript
// ❌ sai (import runtime value cho type-only)
import { CountryModel } from '@/interfaces/models/CountryModel'

// ✅ đúng
import type { CountryModel } from '@/interfaces/models/CountryModel'
```

**Không xử lý null:**
```typescript
// ❌ sai
props.item.id

// ✅ đúng
props.item?.id as number
```

**`useField` thiếu generic:**
```typescript
// ❌ sai
const { value: name } = useField('name')

// ✅ đúng
const { value: name } = useField<string>('name')
```

### Lỗi API

**401 trên route phải public:**
```typescript
// Thêm @Public() trên route
import { Public } from '@/modules/auth/decorators/public.decorator'

@Public()
@Post('login')
login() { ... }
```

**DTO validation không hoạt động:**
```typescript
// Phải dùng @Body(ValidationPipe) — không phải @Body() đơn thuần
async create(@Body(ValidationPipe) dto: CreateCountryDto) { ... }
```

**TypeORM relation không được load:**
```typescript
// ❌ sai
const user = await this.userRepository.findOne({ where: { id } })

// ✅ đúng — chỉ định relations rõ ràng
const user = await this.userRepository.findOne({
  where: { id },
  relations: ['user_group_permissions', 'user_group_permissions.permission_group'],
})
```

**TypeORM update sai pattern:**
```typescript
// ❌ sai
await this.repo.save({ id, ...dto })

// ✅ đúng
await this.repo.update({ id }, { ...dto })
const updated = await this.repo.findOne({ where: { id } })
```

---

## BƯỚC 4 — Sửa tối thiểu

Chỉ sửa đúng nguyên nhân gốc rễ. **Không:**
- Refactor code xung quanh
- Thêm comment hay docstring không liên quan
- Sửa code không liên quan đến bug

---

## BƯỚC 5 — Kiểm tra sau khi sửa

```bash
# Nếu sửa API:
make api-lint-fix
make api-test

# Nếu sửa Client:
make client-lint-fix

# Nếu sửa Docker/Nginx:
make restart
# Kiểm tra log: make logs
```

Với `vue-tsc`: lệnh lint chạy type-checking. Phải sửa hết lỗi mới coi là xong.

---

## BƯỚC 6 — Kiểm tra chatbot prompt

Tự hỏi: **"Fix này có thay đổi hành vi UI, flow, hoặc logic mà chatbot đang hướng dẫn người dùng không?"**

Nếu có → chạy `/update-prompts <mô tả fix>` để cập nhật đúng file markdown trong `sources/attendance_api/src/modules/chatbot/prompts/`.

---

## BƯỚC 7 — Giải thích cho người dùng

Trình bày ngắn gọn bằng tiếng Việt:
1. **Nguyên nhân**: lỗi gì, tại sao xảy ra
2. **Cách sửa**: đã thay đổi gì
3. **Phòng tránh**: làm sao tránh lần sau
