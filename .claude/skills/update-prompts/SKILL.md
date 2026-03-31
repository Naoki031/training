---
name: update-prompts
description: Review and update chatbot prompt markdown files after a feature change, fix, or new functionality — decides which sections need updating and edits only those files
argument-hint: "[mô tả thay đổi cụ thể — bỏ trống để tự suy luận từ session]"
---

# /update-prompts — Cập nhật chatbot prompts

Rà soát và cập nhật các file markdown prompt sau khi có thay đổi tính năng. **Code và comment viết bằng tiếng Anh. Giải thích cho người dùng bằng tiếng Việt.**

## Cách dùng

| Cú pháp | Khi nào dùng |
|---------|-------------|
| `/update-prompts` | Không nhớ hoặc không muốn mô tả — tự suy luận từ những gì đã làm trong session này |
| `/update-prompts <mô tả>` | Biết rõ cần cập nhật gì — ví dụ "thêm field note vào form Leave" |

---

## BƯỚC 1 — Xác định context thay đổi

**Nếu có argument** (`/update-prompts <mô tả>`):
- Dùng mô tả đó làm basis phân tích, bỏ qua bước đọc git diff

**Nếu không có argument** (`/update-prompts`):
- Chạy `git diff HEAD` để xem toàn bộ thay đổi chưa commit trong session này
- Đọc diff, tóm tắt những gì đã thay đổi từ góc nhìn người dùng:
  - File `.vue` mới/sửa → tính năng UI mới hoặc đổi flow
  - Field mới trong entity/DTO → form có thêm field
  - Route mới trong controller → tính năng mới
  - Logic thay đổi trong service → hành vi thay đổi
  - Migration → schema change (thường là field mới)
- Nếu diff quá lớn, đọc thêm các file cụ thể để hiểu rõ hơn

---

## BƯỚC 2 — Phân tích ảnh hưởng đến prompt

Từ những thay đổi đã xác định, tự hỏi:

> **"Thay đổi này có ảnh hưởng đến thứ gì chatbot đang hướng dẫn người dùng không?"**

Chỉ cần cập nhật prompt khi thay đổi ảnh hưởng đến:
- Tên tính năng, menu, hoặc route người dùng thấy
- Cách thực hiện một thao tác (flow thay đổi)
- Tên hoặc tính chất của field trong form
- Quyền hạn: điều employee được/không được làm
- Hành vi hiển thị trên UI

**Không cần cập nhật** khi:
- Backend-only: query optimization, index, refactor service
- Bug fix không đổi behavior người dùng thấy
- Thay đổi cấu hình Docker/Nginx
- Thêm validation không thay đổi tên field

Nếu không cần cập nhật → giải thích lý do và dừng lại.

---

## BƯỚC 3 — Xác định files cần xem xét

Dựa vào loại thay đổi, chọn files liên quan từ bảng sau:

| File | Tags | Nội dung |
|------|------|----------|
| `01-role.md` | employee, admin | Role definition, app name, purpose |
| `02-overview-employee.md` | employee | App overview for employees |
| `02-overview-admin.md` | admin | App overview for admins |
| `03-features-employee.md` | employee | Feature list available to employees |
| `03-features-admin-all.md` | admin | Feature list — employee-facing features (admin view) |
| `03-features-admin-management.md` | admin | Feature list — admin-only management features |
| `04-clock-in-out-employee.md` | employee | How to clock in/out (employee) |
| `04-clock-in-out-admin.md` | admin | How to clock in/out (admin) |
| `05-submit-request.md` | employee, admin | How to submit requests |
| `06-form-off.md` | employee, admin | Leave request form fields |
| `06-form-wfh.md` | employee, admin | WFH request form fields |
| `06-form-overtime.md` | employee, admin | Overtime request form fields |
| `06-form-equipment.md` | employee, admin | Equipment request form fields |
| `06-form-clock-forget.md` | employee, admin | Clock forget request form fields |
| `07-workflow-employee.md` | employee | Request approval workflow (employee view) |
| `07-workflow-admin.md` | admin | Request approval workflow (admin view) |
| `08-tips-employee.md` | employee | Usage tips for employees |
| `08-tips-admin.md` | admin | Usage tips for admins |
| `09-restrictions.md` | employee | What employees cannot do |
| `10-closing.md` | employee, admin | Closing instruction / tone reminder |

**Mapping nhanh:**
- Thêm/đổi tính năng trong menu → `02-overview`, `03-features`
- Đổi flow clock-in/out → `04-clock-in-out`
- Đổi flow submit request → `05-submit-request`
- Thêm/đổi field form → `06-form-<type>`
- Đổi approval workflow → `07-workflow`
- Thêm tip hoặc cảnh báo → `08-tips`
- Đổi quyền hạn employee → `09-restrictions`

---

## BƯỚC 4 — Đọc và cập nhật

Đọc từng file trong danh sách liên quan. Với mỗi file tự hỏi:
> "Nội dung file này có mô tả đúng hành vi mới không? Có điều gì sai, thiếu, hay lỗi thời không?"

**Nguyên tắc khi sửa:**
- Chỉ sửa đúng phần liên quan — không refactor toàn bộ
- Giữ nguyên frontmatter (`tags`, `order`)
- Giữ style nhất quán với phần xung quanh (bullet points, bold key terms)
- Thay đổi áp dụng cho cả employee lẫn admin mà có file riêng → sửa cả hai

---

## BƯỚC 5 — Báo cáo

Trình bày ngắn gọn bằng tiếng Việt:
1. **Thay đổi phát hiện**: tóm tắt những gì đã làm trong session (nếu tự suy luận)
2. **Files đã sửa**: tên file + 1 dòng mô tả thay đổi
3. **Files xem nhưng không sửa**: lý do ngắn gọn
4. **Kết luận**: cần reload prompts không (`POST /chatbot/reload-prompts`)
