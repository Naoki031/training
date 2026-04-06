---
name: sync-to-attendance
description: Copy all files from training/sources/{attendance_client,attendance_api} to attendance/sources, preserving attendance production config
argument-hint: "[--dry-run]"
---

# /sync-to-attendance — Copy files sang attendance project

Copy **toàn bộ file** từ:
- `/Users/trucnguyen/Documents/projects/training/sources/attendance_client` → `/Users/trucnguyen/Documents/projects/attendance/sources/attendance_client`
- `/Users/trucnguyen/Documents/projects/training/sources/attendance_api` → `/Users/trucnguyen/Documents/projects/attendance/sources/attendance_api`

`attendance` là project **production đã được cấu hình sẵn**. Mọi giá trị config trong đó phải được **giữ nguyên hoàn toàn** — không được overwrite bằng config của training.

## Usage
`/sync-to-attendance` — copy tất cả file + bảo toàn config attendance
`/sync-to-attendance --dry-run` — chỉ liệt kê, không copy

---

## Bước 1 — Lấy danh sách tất cả file cần sync

Dùng Glob để lấy toàn bộ file trong 2 thư mục nguồn:
- `sources/attendance_client/**/*` (bỏ qua `node_modules/`, `.nuxt/`, `dist/`, `.output/`)
- `sources/attendance_api/**/*` (bỏ qua `node_modules/`, `dist/`)

Chỉ lấy file (không lấy thư mục).

---

## Bước 2 — Tách danh sách: file thường vs file config nhạy cảm

Chia toàn bộ file thành 2 nhóm:

**Nhóm A — File thường** (copy thẳng, không cần xử lý thêm):
- Mọi `.vue`, `.ts`, `.json` (i18n, types, interfaces...) trừ các file bên dưới

**Nhóm B — File config nhạy cảm** (cần đọc target trước khi copy):
- `sources/attendance_client/nuxt.config.ts`
- `sources/attendance_api/src/app.module.ts`
- `sources/attendance_api/src/config/data-source.ts`
- `sources/attendance_api/src/config/database.providers.ts`
- `sources/attendance_client/package.json`
- `sources/attendance_api/package.json`
- `.env.example`

---

## Bước 3 — Phát hiện file bị xóa trong training

So sánh danh sách file training (Bước 1) với danh sách file tương ứng trong attendance target:

```bash
# Lấy danh sách file trong attendance target (cùng 2 thư mục, bỏ qua node_modules/ dist/ .nuxt/ .output/)
find /Users/trucnguyen/Documents/projects/attendance/sources/attendance_client \
  -type f ! -path "*/node_modules/*" ! -path "*/.nuxt/*" ! -path "*/dist/*" ! -path "*/.output/*"
find /Users/trucnguyen/Documents/projects/attendance/sources/attendance_api \
  -type f ! -path "*/node_modules/*" ! -path "*/dist/*"
```

Với mỗi file tồn tại trong attendance nhưng **không có** trong training → đưa vào **Nhóm D (Delete)**:
- Bỏ qua các file Nhóm B (config nhạy cảm) — không xóa các file config của attendance dù training không có
- Chỉ xóa file Nhóm A thường

**Hỏi xác nhận user** trước khi xóa, liệt kê rõ từng file:
```
Nhóm D — File tồn tại trong attendance nhưng đã bị xóa trong training (Z file):
  sources/attendance_client/components/OldComponent.vue
  sources/attendance_api/src/modules/old-feature/old.service.ts
  ...

Xóa các file này không? (y/n)
```

Nếu user xác nhận → xóa. Nếu không → bỏ qua Nhóm D.

---

## Bước 4 — Hiển thị danh sách (tóm tắt)

Chỉ hiển thị số lượng, không liệt kê từng file (có thể rất nhiều):

```
Nhóm A — Copy thẳng: X file
  (ví dụ: components/, pages/, services/, store/, locales/, ...)

Nhóm B — Cần merge thủ công: Y file
  sources/attendance_client/nuxt.config.ts
  sources/attendance_api/src/app.module.ts
  ...

Nhóm D — Xóa (có trong attendance, không còn trong training): Z file
  sources/attendance_client/components/OldComponent.vue
  ...
```

Nếu `--dry-run` → dừng tại đây.

---

## Bước 5 — Copy Nhóm A

Với mỗi file trong Nhóm A:
```bash
mkdir -p "<target_dir>"
cp "<training_source_path>" "<attendance_target_path>"
```

Mapping đường dẫn:
- `training/sources/attendance_client/...` → `attendance/sources/attendance_client/...`
- `training/sources/attendance_api/...` → `attendance/sources/attendance_api/...`

---

## Bước 6 — Xử lý Nhóm B: đọc target → diff → merge → hỏi user

Với **mỗi file** trong Nhóm B, thực hiện theo quy trình sau:

### 6.1 Đọc cả hai phiên bản
- Đọc file **nguồn** (training): nội dung mới cần sync
- Đọc file **đích** (attendance): cấu hình production hiện tại

### 6.2 Xác định những gì thay đổi trong training
So sánh hai file để tìm ra **phần logic mới** trong training (thêm module, thêm field, thêm key runtimeConfig, v.v.) — phân biệt với phần chỉ là config khác nhau.

### 6.3 Apply chỉ phần logic mới vào file attendance
Chỉ thêm/sửa phần **logic** (module mới, feature mới), **giữ nguyên toàn bộ giá trị config** của attendance:
- Các giá trị `runtimeConfig.public.*` → giữ nguyên của attendance
- Các connection string, URL, port → giữ nguyên của attendance
- Thứ tự khai báo module, imports → giữ nguyên của attendance nếu không có thay đổi logic

### 6.4 Báo cáo rõ ràng cho user

Với mỗi file Nhóm B, in ra:
```
[nuxt.config.ts]
  ✓ Thêm: runtimeConfig key 'chatbotName' (feature mới từ training)
  ✗ Giữ nguyên: apiBaseUrl = 'http://localhost:3001/api/v1' (production config)
  ✗ Giữ nguyên: wsUrl = 'http://localhost:3001' (production config)
```

Nếu không chắc phần nào là logic mới vs config khác nhau → **hỏi user** trước khi apply.

---

## Bước 7 — Xóa Nhóm D

Sau khi user xác nhận, xóa từng file trong Nhóm D:
```bash
rm "/Users/trucnguyen/Documents/projects/attendance/<file>"
```

---

## Bước 8 — Báo kết quả tổng

```
✓ Copy thành công: X file (Nhóm A)
✓ Merge thành công: Y file (Nhóm B)
  - nuxt.config.ts: thêm 'chatbotName', giữ nguyên URL config
  - app.module.ts: thêm ChatModule, giữ nguyên module list hiện tại
✓ Xóa thành công: Z file (Nhóm D)
  - sources/attendance_client/components/OldComponent.vue
```

---

## Notes chung
- **Nguyên tắc tối cao:** config của `attendance` luôn thắng — không được overwrite bất kỳ giá trị config nào
- Không thay đổi git state của cả hai project
- Không chạy `git add` hay `git commit` ở project đích
- Nếu một file Nhóm B quá phức tạp để merge tự động → báo user và bỏ qua, để user tự xử lý
