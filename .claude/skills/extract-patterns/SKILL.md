---
name: extract-patterns
description: Cuối session — tự động trích xuất patterns, bugs đã fix, và anti-patterns mới vào memory để session sau không lặp lại
---

# /extract-patterns — Continuous Learning

Chạy cuối mỗi session phức tạp để cập nhật memory với kiến thức mới.

**Code và comment viết bằng tiếng Anh. Giải thích cho người dùng bằng tiếng Việt.**

---

## QUY TRÌNH

### BƯỚC 1 — Nhìn lại session này

Dựa trên cuộc trò chuyện vừa rồi, tự hỏi:
- Bug nào đã phát sinh do thiếu hiểu biết về codebase?
- File nào phải đọc nhiều lần (có thể document lại để tránh)?
- Pattern nào mới phát hiện chưa có trong CLAUDE.md?
- Có anti-pattern nào mới cần tránh?
- Có relationship/convention nào chưa được document?

### BƯỚC 2 — Đọc memory hiện tại

Đọc file sau để tránh duplicate:
- `/Users/trucnguyen/.claude/projects/-Users-trucnguyen-Documents-projects-training/memory/project_architecture.md`
- `/Users/trucnguyen/Documents/projects/training/CLAUDE.md` (phần "Critical Gotchas")

### BƯỚC 3 — Phân loại những gì cần lưu

**Lưu vào `project_architecture.md` nếu:**
- Entity relationship mới phát hiện
- Service method quan trọng (loads gì, throws gì)
- Bug pattern đã gây ra lỗi thực tế trong session này
- Anti-pattern mới

**Lưu vào `CLAUDE.md` (phần "Critical Gotchas") nếu:**
- Bug dễ lặp lại + không rõ ràng từ code
- Convention quan trọng của project

**Không lưu:**
- Ephemeral task details (đang làm gì, đang ở đâu)
- Thứ đã có trong memory rồi
- Thứ derivable từ reading code (file paths, function names)

### BƯỚC 4 — Cập nhật files

Chỉ update nếu có gì thực sự mới và có giá trị. Không lưu vì lưu.

**Format entry mới trong `project_architecture.md`:**
```
## [Category]
**[Short title]**: [Fact]. [Why it matters / common mistake it prevents].
```

**Format entry mới trong CLAUDE.md Critical Gotchas:**
```
N. **[Short label]** — [what to do / not do], [why]
```

### BƯỚC 5 — Báo cáo

Liệt kê ngắn gọn bằng tiếng Việt:
- Đã thêm gì mới vào memory
- Bỏ qua gì (và tại sao không đáng lưu)
