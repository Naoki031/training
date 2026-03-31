---
name: review
description: Code review for NestJS API and Nuxt.js client — checks correctness, security, TypeScript, and stack conventions
---

# /review — Review code

Review code theo đúng stack của project. **Code và comment viết bằng tiếng Anh. Kết quả review trình bày bằng tiếng Việt.**

---

## Các điểm cần kiểm tra

**API (NestJS):**
- Thiếu `@Public()` trên route phải public
- Entity thiếu `@Column()` decorator hoặc relation chưa cấu hình
- Sửa entity nhưng chưa tạo migration
- DTO thiếu `class-validator` decorators
- Dùng `@Body()` thay vì `@Body(ValidationPipe)`
- Secret hardcode thay vì `process.env`

**Client (Nuxt/Vue):**
- `ref()` thiếu generic type
- Import type sai: dùng `import { }` thay `import type { }`
- Prop type thiếu `PropType<T>`
- Gọi API trực tiếp bằng `$fetch` thay vì qua `apiClient`
- `useField()` thiếu generic
- Null không được xử lý trước khi dùng

## Cách thực hiện

1. **Đọc** các file được yêu cầu (hoặc `git diff` nếu không chỉ định cụ thể)
2. **Review** theo các điểm trên
3. **Báo cáo** kết quả theo mức độ:
   - 🔴 **Nghiêm trọng**: lỗi logic, bảo mật, sẽ gây crash
   - 🟡 **Cảnh báo**: vi phạm convention, có thể gây lỗi ngầm
   - 🟢 **Gợi ý**: cải thiện nhỏ, không bắt buộc
4. **Sửa** chỉ các lỗi nghiêm trọng — trừ khi được yêu cầu thêm

Bỏ qua các vấn đề style/formatting đã được ESLint bắt.
