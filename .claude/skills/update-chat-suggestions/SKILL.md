---
name: update-chat-suggestions
description: Add or update suggested questions shown in the chatbot UI — initial chips and help panel groups. Edits i18n files (en/vi/ja) and Vue components together.
argument-hint: "<mô tả thay đổi — thêm câu hỏi mới / đổi câu hỏi / thêm nhóm mới>"
---

# /update-chat-suggestions — Cập nhật câu hỏi gợi ý chatbot UI

Thêm hoặc sửa câu hỏi gợi ý hiển thị trong giao diện chat. **Code và comment viết bằng tiếng Anh. Giải thích cho người dùng bằng tiếng Việt.**

## Cách dùng
`/update-chat-suggestions <mô tả thay đổi>`

Ví dụ:
```
/update-chat-suggestions thêm câu hỏi về export báo cáo vào help panel (admin)
/update-chat-suggestions đổi câu hỏi chip "How to create a leave request?" thành "How to submit a leave request?"
/update-chat-suggestions thêm nhóm "Reports" vào help panel cho admin với 2 câu hỏi
```

---

## KIẾN TRÚC

Câu hỏi gợi ý có **2 vùng độc lập**:

### Vùng 1 — Chips ban đầu (ChatbotWidget)
Hiển thị khi chat còn trống. 4 câu cho tất cả + 1 câu chỉ admin.

- **i18n key:** `chatbot.suggestions.<key>`
- **Vue:** `sources/attendance_client/components/chatbot/ChatbotWidget.vue`
  - `SUGGESTED_QUESTIONS` computed (line ~255): thêm/xóa `t('chatbot.suggestions.<key>')`
  - Admin: thêm vào `adminQuestions` array; Employee: thêm vào `employeeQuestions` array

### Vùng 2 — Help panel groups (ChatbotHelpPanel)
Panel bên cạnh chat, câu hỏi theo nhóm chủ đề.

- **i18n keys:**
  - Tên nhóm: `chatbot.help.groups.<groupKey>`
  - Câu hỏi: `chatbot.help.questions.<questionKey>`
- **Vue:** `sources/attendance_client/components/chatbot/ChatbotHelpPanel.vue`
  - `helpGroups` computed (line ~43): thêm nhóm mới hoặc câu hỏi vào nhóm hiện có
  - Admin-only groups: thêm vào block `if (userStore.isAdmin)` với `adminOnly: true`

### i18n files (cập nhật cả 3):
```
sources/attendance_client/i18n/locales/en.json  ← English (viết trước)
sources/attendance_client/i18n/locales/vi.json  ← Tiếng Việt
sources/attendance_client/i18n/locales/ja.json  ← 日本語
```

Tất cả chatbot keys nằm ở cuối file, trong section `"chatbot": { ... }`.

---

## CÁC NHÓM HIỆN CÓ TRONG HELP PANEL

| groupKey | adminOnly | Các questionKey hiện có |
|----------|-----------|------------------------|
| `requests` | ❌ | createLeave, createWfh, createOvertime, borrowEquipment, forgetClock |
| `clockInOut` | ❌ | clockQr, clockBiometric, clockWfh |
| `myRequests` | ❌ | editRequest, reuseRequest, trackStatus |
| `approvals` | ✅ | whereApprove, rejectRequest, pendingBadge |
| `attendance` | ✅ | syncDevice, viewLogs, generateQr |
| `usersOrg` | ✅ | manageUsers, assignDept, setDeviceId |
| `integrations` | ✅ | configSlack, configGoogleSheets |

---

## BƯỚC 1 — Đọc trước khi sửa

Đọc file liên quan để hiểu nội dung hiện tại:
- Nếu sửa chips → đọc `ChatbotWidget.vue` đoạn `SUGGESTED_QUESTIONS`
- Nếu sửa help panel → đọc `ChatbotHelpPanel.vue` đoạn `helpGroups`
- Luôn đọc `en.json` để biết format và keys hiện có

---

## BƯỚC 2 — Cập nhật i18n (en.json trước)

**Thêm câu hỏi mới vào nhóm hiện có:**
```json
"questions": {
  ...existing keys...,
  "newQuestionKey": "Question text in English?"
}
```

**Thêm nhóm mới:**
```json
"groups": {
  ...existing keys...,
  "newGroupKey": "Group Label"
},
"questions": {
  ...existing keys...,
  "newQ1": "Question 1?",
  "newQ2": "Question 2?"
}
```

**Sau khi sửa en.json** → sửa vi.json và ja.json với cùng key, dịch phù hợp.

**Quy tắc i18n:**
- Key dùng camelCase, mô tả nội dung ngắn gọn
- Ký tự `@` trong chuỗi tiếng Việt → escape thành `{'@'}`
- Không xóa key cũ trừ khi câu hỏi đó bị xóa hoàn toàn

---

## BƯỚC 3 — Cập nhật Vue component

**Thêm câu hỏi vào chips (ChatbotWidget.vue):**
```typescript
const employeeQuestions = [
  t('chatbot.suggestions.existingKey'),
  t('chatbot.suggestions.newKey'),   // thêm vào đây
]
// hoặc admin-only:
const adminQuestions = [
  t('chatbot.suggestions.adminApproval'),
  t('chatbot.suggestions.newAdminKey'),  // thêm vào đây
]
```

**Thêm câu hỏi vào nhóm hiện có (ChatbotHelpPanel.vue):**
```typescript
{
  label: t('chatbot.help.groups.requests'),
  questions: [
    t('chatbot.help.questions.createLeave'),
    t('chatbot.help.questions.newQuestionKey'),  // thêm vào đây
  ],
},
```

**Thêm nhóm mới (admin-only) vào ChatbotHelpPanel.vue:**
```typescript
if (userStore.isAdmin) {
  groups.push(
    ...existing admin groups...,
    {
      label: t('chatbot.help.groups.newGroupKey'),
      questions: [
        t('chatbot.help.questions.newQ1'),
        t('chatbot.help.questions.newQ2'),
      ],
      adminOnly: true,
    },
  )
}
```

---

## BƯỚC 4 — Verify

```bash
make client-lint-fix
```

Kiểm tra nhanh:
```bash
node -e "const fs=require('fs'); const json=JSON.parse(fs.readFileSync('sources/attendance_client/i18n/locales/en.json')); console.log(json.chatbot.help.questions)"
```

---

## BƯỚC 5 — Báo cáo

Trình bày bằng tiếng Việt:
1. **Thay đổi đã thực hiện**: vùng nào (chips / help panel), câu hỏi/nhóm nào được thêm/sửa/xóa
2. **Files đã sửa**: danh sách (thường là en.json, vi.json, ja.json + 1 Vue file)
3. **Cần chú ý**: nếu câu hỏi mới liên quan đến tính năng chưa có trong prompt → gợi ý chạy `/update-prompts`
