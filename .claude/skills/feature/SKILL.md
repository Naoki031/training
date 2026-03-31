---
name: feature
description: Implement a new feature end-to-end following exact project conventions — entity, DTO, service, controller, migration, Vue page/component, service class, store
argument-hint: "<mô tả tính năng>"
---

# /feature — Xây dựng tính năng mới

Thực hiện đầy đủ theo đúng conventions của project. **Code và comment viết bằng tiếng Anh. Giải thích cho người dùng bằng tiếng Việt.**

## Cách dùng
`/feature <mô tả tính năng>`

---

## BƯỚC 1 — Làm rõ & lên kế hoạch

Đọc module liên quan hiện có (ví dụ `sources/attendance_api/src/modules/countries/`) trước khi viết bất kỳ dòng code nào.

Liệt kê các file cần tạo/sửa. Nếu phạm vi lớn, hỏi xác nhận trước.

---

## BƯỚC 2 — API: NestJS

### Entity (`entities/<name>.entity.ts`)
```typescript
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm'

@Entity({ name: '<table_name>' })
export class <Name> {
  @PrimaryGeneratedColumn()
  id!: number

  @Column({ nullable: false })
  field_name!: string

  @Column({ nullable: true })
  optional_field?: string

  @CreateDateColumn({ nullable: true, name: 'created_at' })
  created_at?: Date

  @CreateDateColumn({ nullable: true, name: 'updated_at' })
  updated_at?: Date

  @CreateDateColumn({ nullable: true, name: 'deleted_at' })
  deleted_at?: Date
}
```
- Dùng `id!: number` (non-null assertion) cho required fields
- Dùng `field?: string` cho optional fields
- Luôn có đủ 3 timestamps: `created_at`, `updated_at`, `deleted_at`
- Relations: `@OneToMany(() => Child, (child) => child.parent)`

### DTO (`dto/create-<name>.dto.ts`)
```typescript
import { IsString, IsNotEmpty, IsOptional, IsNumber } from 'class-validator'

export class Create<Name>Dto {
  @IsString()
  @IsNotEmpty()
  field_name: string

  @IsString()
  @IsOptional()
  optional_field?: string

  @IsNumber()
  @IsOptional()
  numeric_field?: number
}
```
- Chồng decorator trên từng property — không có constructor
- `@IsOptional()` luôn đặt đầu tiên trên optional fields

### Service (`<name>.service.ts`)
```typescript
import { Injectable, NotFoundException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { <Name> } from './entities/<name>.entity'
import { Create<Name>Dto } from './dto/create-<name>.dto'
import { Update<Name>Dto } from './dto/update-<name>.dto'

@Injectable()
export class <Name>Service {
  constructor(
    @InjectRepository(<Name>)
    private readonly <name>Repository: Repository<<Name>>,
  ) {}

  /**
   * Creates a new <name> entry.
   */
  async create(createDto: Create<Name>Dto): Promise<<Name>> {
    return this.<name>Repository.save(createDto)
  }

  /**
   * Retrieves all <name> entries.
   */
  async findAll(): Promise<<Name>[]> {
    return this.<name>Repository.find()
  }

  /**
   * Retrieves a single <name> by ID.
   */
  findOne(id: number): Promise<<Name>> {
    const item = this.<name>Repository.findOne({ where: { id } })
    if (!item) throw new NotFoundException('<Name> not found')
    return item
  }

  /**
   * Updates a <name> by ID.
   */
  async update(id: number, updateDto: Update<Name>Dto): Promise<<Name>> {
    await this.<name>Repository.update({ id }, { ...updateDto })
    return this.findOne(id)
  }

  /**
   * Removes a <name> by ID.
   */
  async remove(id: number) {
    return this.<name>Repository.delete({ id })
  }
}
```
- JSDoc comment tiếng Anh trên mọi public method
- `repository.save()` cho create, `repository.update({ id }, {...})` cho update
- Eager load relations: `repository.findOne({ where: { id }, relations: ['rel', 'rel.sub'] })`

### Controller (`<name>.controller.ts`)
```typescript
import { Controller, Get, Post, Body, Put, Param, Delete, ParseIntPipe, ValidationPipe, UseGuards } from '@nestjs/common'
import { <Name>Service } from './<name>.service'
import { Create<Name>Dto } from './dto/create-<name>.dto'
import { Update<Name>Dto } from './dto/update-<name>.dto'
import { PermissionsGuard } from '@/modules/permissions/guards/permissions.guard'
import { Permissions } from '@/modules/permissions/decorators/permissions.decorator'

@Controller('<names>')
@UseGuards(PermissionsGuard)
export class <Name>Controller {
  constructor(private readonly <name>Service: <Name>Service) {}

  @Post()
  @Permissions('create')
  async create(@Body(ValidationPipe) createDto: Create<Name>Dto) {
    try {
      return await this.<name>Service.create(createDto)
    } catch (error) {
      console.error('Error creating <name>:', error)
      throw error
    }
  }

  @Get()
  @Permissions('read')
  findAll() {
    return this.<name>Service.findAll()
  }

  @Get(':id')
  @Permissions('read')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.<name>Service.findOne(id)
  }

  @Put(':id')
  @Permissions('update')
  update(@Param('id', ParseIntPipe) id: number, @Body(ValidationPipe) updateDto: Update<Name>Dto) {
    return this.<name>Service.update(id, updateDto)
  }

  @Delete(':id')
  @Permissions('delete')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.<name>Service.remove(id)
  }
}
```
- `@UseGuards(PermissionsGuard)` đặt ở class level
- `@Body(ValidationPipe)` — **bắt buộc**, không dùng `@Body()` đơn thuần
- `@Param('id', ParseIntPipe)` cho tham số số nguyên
- Chỉ thêm `@Public()` khi route thực sự không cần auth

### Sau khi viết API: tạo migration
```bash
make migration-create name=create_<names>_table
```
Implement `up()` và `down()` dựa trên entity. Đăng ký module trong `app.module.ts`.

---

## BƯỚC 3 — Client: Nuxt.js 3

### Interface (`interfaces/models/<Name>Model.ts`)
```typescript
export interface <Name>Model {
  id: number
  field_name: string
  optional_field?: string
  created_at?: string
  updated_at?: string
}
```

### Service (`services/<Name>Service.ts`)
```typescript
import { apiClient } from '@/utils/apiClient'
import type { <Name>Model } from '@/interfaces/models/<Name>Model'

export default class <Name>Service {
  public static async getAll(): Promise<<Name>Model[]> {
    return await apiClient.get<<Name>Model[]>('<names>')
  }

  public static async getOne(id: number): Promise<<Name>Model> {
    return await apiClient.get<<Name>Model>(`<names>/${id}`)
  }

  public static async create(data: Record<string, unknown>): Promise<<Name>Model> {
    return await apiClient.post<<Name>Model>('/<names>', data)
  }

  public static async update(id: number, data: Record<string, unknown>): Promise<<Name>Model> {
    return await apiClient.put<<Name>Model>(`/<names>/${id}`, data)
  }

  public static async delete(id: number): Promise<boolean> {
    return (await apiClient.delete(`/<names>/${id}`)) as boolean
  }
}
```
- `export default class` với `public static async` — không có constructor
- Luôn dùng `apiClient` từ `@/utils/apiClient` — **không** dùng `$fetch` trực tiếp
- Generic trên mọi method: `apiClient.get<T>(url)`

### Page (`pages/<path>/index.vue`)
```vue
<template>
  <!-- Vuetify components -->
</template>

<script lang="ts" setup>
/** START IMPORT */
import type { <Name>Model } from '@/interfaces/models/<Name>Model'
import <Name>Service from '@/services/<Name>Service'
/* END IMPORT */

/** START DEFINE NAME COMPONENT */
definePageMeta({
  name: 'admin.<names>.index',
})
/* END DEFINE */

/** START DEFINE PROPERTY AND EMITS */
/* END DEFINE PROPERTY AND EMITS */

/** START DEFINE VALIDATE */
/* END DEFINE VALIDATE */

/** START DEFINE STATE */
const items = ref<Array<<Name>Model>>([])
const isLoading = ref(false)
const dialog = ref(false)
const editedItem = ref<<Name>Model | null>(null)
/* END DEFINE STATE */

/** START DEFINE COMPUTED */
/* END DEFINE COMPUTED */

/** START DEFINE METHOD */
const getItems = async () => {
  if (isLoading.value) return
  try {
    isLoading.value = true
    const data = await <Name>Service.getAll()
    items.value = Object.values(data)
  } catch (error) {
    console.error('Failed to fetch <names>:', error)
  } finally {
    isLoading.value = false
  }
}

const close = () => {
  dialog.value = false
  editedItem.value = null
}
/* END DEFINE METHOD */

/** START DEFINE WATCHER */
watch(
  () => dialog,
  (val) => { if (!val) close() },
  { immediate: false },
)
/* END DEFINE WATCHER */

/** START DEFINE LIFE CYCLE HOOK */
onMounted(() => {
  getItems()
})
/* END DEFINE LIFE CYCLE HOOK */
</script>

<style scoped></style>
```

**Quan trọng cho vue-tsc** (strict mode bật):
- `ref<Array<Model>>([])` — luôn có generic, không được để `ref([])`
- `ref<Model | null>(null)` — không được để `ref(null)` trần
- `import type { }` — không `import { }` cho interface/type
- Dùng alias `@/` — không dùng relative path cho services/interfaces

### Component có form (`components/<name>/DialogCreateOrUpdate.vue`)
```vue
<script lang="ts" setup>
/** start import */
import type { PropType } from 'vue'
import * as Yup from 'yup'
import type { <Name>Model } from '@/interfaces/models/<Name>Model'
import <Name>Service from '@/services/<Name>Service'
/* end import */

/** start define property and emits */
const props = defineProps({
  item: {
    type: Object as PropType<<Name>Model | null>,
    required: false,
    default: null,
  },
  dialog: {
    type: Boolean,
    required: true,
  },
})
const emit = defineEmits(['confirm', 'close-modal'])
/* end define property and emits */

/** start define validate */
const schema = Yup.object().shape({
  name: Yup.string().required('Name is required'),
})

const { values, handleSubmit, setFieldValue } = useForm({
  validationSchema: schema,
  initialValues: { name: '' as string | null },
})

const { value: name } = useField<string>('name')
/* end define validate */

/** start defined computed */
const title = computed(() => (props.item ? 'Edit <Name>' : 'New <Name>'))
/* end defined computed */

/** start defined methods */
const handleCreate = handleSubmit(async (form) => {
  <Name>Service.create(form)
    .then((res: <Name>Model) => { emit('confirm', res) })
    .catch((error) => { console.error('Failed to create:', error) })
})

const handleUpdate = handleSubmit(async (form) => {
  <Name>Service.update(props.item?.id as number, form)
    .then((res: <Name>Model) => { emit('confirm', res) })
    .catch((error) => { console.error('Failed to update:', error) })
})

const confirm = () => {
  if (!props.item) handleCreate()
  else handleUpdate()
}

const close = () => { emit('close-modal', null) }
/* end defined methods */

/** start define watcher */
watch(() => props.dialog, (val) => { if (!val) close() }, { immediate: false })

watchEffect(() => {
  if (props.item) setFieldValue('name', props.item.name)
})
/* end define life watcher */

/** start define life cycle hook */
/* end define life cycle hook */
</script>
```
- `useForm` và `useField` **không cần import** — được auto-import trong `nuxt.config.ts`
- `PropType<T>` bắt buộc cho prop kiểu object/array
- `useField<string>('fieldName')` — phải có generic

---

## BƯỚC 4 — Kiểm tra sau khi hoàn thành

```bash
make api-lint-fix        # sửa lint API
make migrate             # chạy migration mới
make api-test            # không có regression
make client-lint-fix     # sửa lỗi Vue/TS
```

---

## BƯỚC 5 — Cập nhật chatbot prompt

**BẮT BUỘC.** Mỗi tính năng mới hoặc thay đổi flow đều phải được cập nhật vào prompt chatbot.

Chạy `/update-prompts <mô tả tính năng vừa thêm>` để rà soát và cập nhật đúng file.

Liệt kê tất cả file đã tạo/sửa và các việc còn lại (seed data, test...).
