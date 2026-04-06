---
name: analyze-flow
description: Phân tích luồng và logic business của một chức năng — trace từ UI đến DB, kiểm tra tính đúng đắn
---

# /analyze-flow — Phân tích luồng & business logic

Trace đầy đủ từ frontend đến database. Phát hiện lỗi logic, thiếu guard, status transition sai, edge case bỏ sót. **Giải thích bằng tiếng Việt.**

## Cách dùng

- `/analyze-flow <tên chức năng>` — phân tích chức năng chỉ định
- `/analyze-flow` — phân tích chức năng đang làm trong session hiện tại

---

## BƯỚC 1 — Xác định phạm vi

Nếu có argument → tìm files liên quan bằng tên chức năng (glob + grep).
Nếu không có argument → dùng context session hiện tại, tổng hợp từ các file đã đọc/sửa.

Luôn đọc đủ **4 lớp** trước khi phân tích:

| Lớp | Files cần đọc |
|-----|---------------|
| **UI** | `pages/`, `components/` liên quan |
| **Client Service** | `services/<Name>Service.ts` |
| **API Controller** | `src/modules/<name>/<name>.controller.ts` |
| **API Service** | `src/modules/<name>/<name>.service.ts` |
| **Entity / DB** | `entities/<name>.entity.ts`, migration files |

---

## BƯỚC 2 — Trace luồng

Vẽ luồng theo chiều dọc từ user action đến DB và ngược lại:

```
[User Action]
    ↓
[Component: method gọi khi nào, validate gì trước khi gọi API]
    ↓
[Client Service: endpoint nào, method HTTP, payload gì]
    ↓
[Controller: route, guard, pipe, decorator]
    ↓
[Service: business logic, query, side effects (FCM, email, v.v.)]
    ↓
[DB: entity columns, relations, constraints]
    ↑
[Response path: shape trả về → component cập nhật state gì]
```

---

## BƯỚC 3 — Kiểm tra business logic

Với mỗi luồng, trả lời các câu hỏi sau:

### Auth & Authorization
- Route có `@Public()` không? Có nên không?
- Guard nào đang bảo vệ? `PermissionsGuard`, `JwtAuthGuard`?
- User thường có thể gọi route dành cho admin không?

### Validation & Input
- DTO có đủ decorator `class-validator` không?
- Controller dùng `@Body(ValidationPipe)` hay `@Body()` trần?
- Client có validate trước khi gọi API không (Yup, required check)?

### Status Transitions
- Các trạng thái hợp lệ là gì? (ví dụ KYC: null → pending → approved/rejected)
- Service có kiểm tra trạng thái hiện tại trước khi chuyển không?
- Có thể chuyển trạng thái ngược chiều (approved → pending) không? Có nên không?

### Race Conditions & Idempotency
- Nếu user bấm nút 2 lần nhanh → xảy ra gì?
- Client có guard `isLoading` không?
- API có idempotent không, hay tạo duplicate?

### Side Effects
- Email, FCM, WebSocket event — được gửi khi nào?
- Nếu side effect thất bại → main operation rollback không?
- Side effect có fire-and-forget (không await) hay blocking?

### Error Handling
- Service throw exception gì khi lỗi? (`NotFoundException`, `BadRequestException`...)
- Client bắt lỗi ở đâu? Có hiển thị cho user không?
- Lỗi 500 có bị nuốt im không?

### Data Consistency
- Sau khi API thành công, client cập nhật local state hay gọi lại API?
- Nếu partial update → state client có bị stale không?
- Relations có được load đủ khi return response không?

---

## BƯỚC 4 — Output

Trình bày kết quả theo cấu trúc:

### Luồng: [Tên chức năng]

#### Sơ đồ luồng
```
[mô tả các bước theo chiều dọc]
```

#### Logic business
Mô tả ngắn gọn rule chính: điều kiện nào được phép, kết quả là gì.

#### Kiểm tra

| # | Điểm kiểm tra | Trạng thái | Ghi chú |
|---|---------------|-----------|---------|
| 1 | Auth/Guard | ✅ / ⚠️ / ❌ | |
| 2 | DTO validation | ✅ / ⚠️ / ❌ | |
| 3 | Status transition | ✅ / ⚠️ / ❌ | |
| 4 | Race condition | ✅ / ⚠️ / ❌ | |
| 5 | Side effects | ✅ / ⚠️ / ❌ | |
| 6 | Error handling | ✅ / ⚠️ / ❌ | |
| 7 | Data consistency | ✅ / ⚠️ / ❌ | |

**Ký hiệu:** ✅ Đúng · ⚠️ Cần lưu ý · ❌ Có vấn đề

#### Vấn đề phát hiện

Với mỗi vấn đề (nếu có):
- **Mô tả**: chuyện gì xảy ra
- **File**: `path/to/file:line`
- **Hậu quả**: ảnh hưởng gì đến user / data
- **Đề xuất sửa**: cách fix tối thiểu

#### Kết luận
Một đoạn tóm tắt: luồng có đúng không, rủi ro ở đâu, cần làm gì.

---

## Lưu ý

- **Không sửa code** trong bước này trừ khi được yêu cầu — mục đích là phân tích, không phải refactor
- Nếu phát hiện vấn đề nghiêm trọng → hỏi user có muốn fix ngay không
- Ưu tiên logic sai > missing guard > missing error handling > UX issues
