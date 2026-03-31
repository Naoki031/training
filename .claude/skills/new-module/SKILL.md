---
name: new-module
description: Scaffold a complete NestJS module — resource, entity, migration, and register in AppModule
argument-hint: "<tên module>"
---

# /new-module — Tạo NestJS module đầy đủ

Tạo một module mới theo đúng conventions của project. **Code và comment viết bằng tiếng Anh. Giải thích cho người dùng bằng tiếng Việt.**

## Cách dùng
`/new-module <tên-module>`

Ví dụ: `/new-module attendance`

---

## Các bước thực hiện

### Bước 1 — Scaffold NestJS resource
```bash
make create-resource name=modules/<module-name>
```
Chọn: REST API, Yes để generate CRUD entry points.

### Bước 2 — Các file được tạo ra
- `src/modules/<module-name>/<module-name>.module.ts`
- `src/modules/<module-name>/<module-name>.controller.ts`
- `src/modules/<module-name>/<module-name>.service.ts`
- `src/modules/<module-name>/entities/<module-name>.entity.ts`
- `src/modules/<module-name>/dto/create-<module-name>.dto.ts`
- `src/modules/<module-name>/dto/update-<module-name>.dto.ts`

### Bước 3 — Cập nhật Entity
```typescript
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm'

@Entity({ name: '<module-name>s' })
export class <ModuleName> {
  @PrimaryGeneratedColumn()
  id!: number

  // Add columns here

  @CreateDateColumn({ nullable: true, name: 'created_at' })
  created_at?: Date

  @CreateDateColumn({ nullable: true, name: 'updated_at' })
  updated_at?: Date

  @CreateDateColumn({ nullable: true, name: 'deleted_at' })
  deleted_at?: Date
}
```

### Bước 4 — Tạo migration
```bash
make migration-create name=create_<module-name>s_table
```
Sau đó implement `up()` và `down()` dựa trên entity vừa tạo.

### Bước 5 — Đăng ký trong AppModule
Thêm `<ModuleName>Module` vào mảng `imports` trong `src/app.module.ts`.

### Bước 6 — Chạy migration
```bash
make migrate
```

Kiểm tra từng bước trước khi tiếp tục bước tiếp theo.
