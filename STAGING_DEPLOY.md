# Hướng dẫn Deploy lên Staging

Tài liệu chi tiết từng bước deploy hệ thống Attendance lên môi trường staging.

---

## 1. Tổng quan kiến trúc Staging

```
                    ┌──────────────┐
                    │  GitHub      │
                    │  (staging    │
                    │   branch)    │
                    └──────┬───────┘
                           │ push trigger
                    ┌──────▼───────┐
                    │ GitHub       │
                    │ Actions      │
                    └──────┬───────┘
                           │ SSH deploy
                    ┌──────▼──────────────────────┐
                    │  Staging Server              │
                    │  /home/public_html/attendance│
                    │                              │
                    │  ┌────────────────────────┐  │
                    │  │  Nginx (attendance)     │  │
                    │  │  :10080                │  │
                    │  └──┬──────────┬──────────┘  │
                    │     │          │              │
                    │  ┌──▼───┐  ┌──▼──────┐       │
                    │  │ API  │  │ Client  │       │
                    │  │:3001 │  │ :3000   │       │
                    │  └──┬───┘  └─────────┘       │
                    │     │                        │
                    │     │ external network       │
                    │  ┌──▼──────────────┐         │
                    │  │ External MariaDB│         │
                    │  └─────────────────┘         │
                    └──────────────────────────────┘
```

**Điểm khác biệt so với Development:**

| | Development | Staging |
|---|---|---|
| Docker Compose | `docker-compose.yml` | `docker-compose.staging.yml` |
| MariaDB | Container nội bộ | External database |
| Network | `app-network` (bridge) | `shared` (external) |
| Nginx port | 80 | 10080 |
| Nginx container name | `attendance_nginx` | `attendance` |
| Node env | `development` | `production` |
| API command | `npm run start:dev` (watch) | `node dist/main` |
| Client command | `npm run dev` (HMR) | `node .output/server/index.mjs` (SSR) |
| Volumes | Source code + node_modules | `uploads/` + `secrets/` only |
| Env file | `sources/attendance_api/.env` + `sources/attendance_client/.env` | `.env.staging.docker` (shared) |
| phpMyAdmin | Không | Có (port 10080, digest auth) |

---

## 2. Yêu cầu Server

- **OS:** Linux (Ubuntu/Debian)
- **Docker:** Docker Engine 24+ & Docker Compose v2+
- **Make:** GNU Make
- **Git:** Installed
- **RAM:** Tối thiểu 2GB (4GB khuyến nghị)
- **Disk:** Tối thiểu 10GB free
- **Network:** Server có thể kết nối đến external MariaDB
- **Ports:** 10080 mở cho reverse proxy / load balancer

---

## 3. Chuẩn bị Server (lần đầu)

### 3.1. Tạo shared Docker network

Staging sử dụng external network tên `shared`. Tạo trước khi chạy docker-compose:

```bash
docker network create shared
```

Kiểm tra:

```bash
docker network ls | grep shared
```

### 3.2. Clone repository

```bash
cd /home/public_html
git clone <repo-url> attendance
cd attendance
```

### 3.3. Chuẩn bị thư mục

```bash
mkdir -p uploads secrets
chmod 755 uploads secrets
```

- `uploads/` — file upload từ API (bug report screenshots, ...)
- `secrets/` — file bảo mật (Google Sheets service account JSON, ...)

### 3.4. Tạo file `.env.staging.docker`

```bash
cp .env.staging.docker.example .env.staging.docker
```

Chỉnh sửa các giá trị bắt buộc:

```bash
nano .env.staging.docker
```

**Các giá trị PHẢI thay đổi:**

| Variable | Giá trị |
|----------|---------|
| `APP_URL` | `https://your-staging-domain.com` |
| `DB_HOST` | IP/hostname của external MariaDB |
| `DB_PORT` | Port của MariaDB (thường 3306) |
| `DB_USER` | Database username cho staging |
| `DB_PASS` | Database password |
| `DB_NAME` | Tên database (vd: `attendance_staging`) |
| `JWT_KEY` | Secret key mạnh (dùng `openssl rand -base64 32`) |
| `QR_SECRET` | Secret key cho QR check-in (dùng `openssl rand -base64 32`) |

**Các giá trị tuỳ chọn (nếu dùng):**

| Variable | Mô tả |
|----------|-------|
| `GOOGLE_SHEETS_KEY_FILE` | Đường dẫn file JSON trong `secrets/` |
| `GOOGLE_SHEETS_SPREADSHEET_ID` | Google Sheets ID |
| `ANTHROPIC_API_KEY` | API key cho AI chatbot |
| `SLACK_ERROR_WEBHOOK_URL` | Webhook URL cho Slack notification |
| `FIREBASE_*` | Firebase config cho push notifications |

> **Lưu ý:** File `.env.staging.docker` đã được thêm vào `.gitignore` — KHÔNG commit file này lên git.

### 3.5. Chuẩn bị Google Sheets credentials (nếu dùng)

```bash
# Copy service account JSON vào thư mục secrets/
cp ~/google-sheet.json secrets/google-sheet.json
chmod 600 secrets/google-sheet.json
```

---

## 4. Deploy lần đầu

### 4.1. Build và start containers

```bash
make stg-up-build
```

Lệnh này sẽ:
1. Pull source code (đã clone ở bước 3.2)
2. Build 3 images: nginx, api, client (multi-stage, production target)
3. Start containers

### 4.2. Kiểm tra containers đang chạy

```bash
make stg-ps
```

Kết quả mong đợi: 3 containers `attendance`, `attendance_api`, `attendance_client` ở trạng thái `Up`.

### 4.3. Chạy database migrations

```bash
make stg-migrate
```

### 4.4. Seed dữ liệu ban đầu

```bash
make stg-seed
```

### 4.5. Kiểm tra logs

```bash
# Xem tất cả logs
make stg-logs

# Hoặc mở shell vào container để debug
make stg-api
make stg-client
```

### 4.6. Verify

Truy cập `https://your-staging-domain.com` và kiểm tra:
- Trang login hiển thị
- Login với admin account (từ seed data)
- API response: `https://your-staging-domain.com/api/v1`

---

## 5. Deploy cập nhật (từ GitHub Actions)

### 5.1. Cấu hình GitHub Secrets

Trong repository GitHub → Settings → Secrets and variables → Actions, thêm:

| Secret | Mô tả |
|--------|-------|
| `PRIVATE_KEY` | SSH private key để kết nối staging server |
| `STAGING_HOST` | IP/hostname của staging server |
| `STAGING_USER` | SSH username |
| `STAGING_PORT` | SSH port (thường 22) |
| `SLACK_WEBHOOK_URL` | Webhook URL cho deploy failure notification (optional) |

### 5.2. Trigger deploy

```bash
# Từ local, push code lên branch staging
git checkout staging
git push origin staging
```

GitHub Actions sẽ tự động:
1. SSH vào staging server
2. `git pull origin staging`
3. `mkdir -p uploads secrets`
4. `make stg-up-build`
5. Clean dangling images

Nếu thất bại → Slack notification.

### 5.3. Trigger manual deploy

Vào GitHub → Actions → DeployStaging → "Run workflow".

---

## 6. Deploy cập nhật (thủ công trên server)

```bash
cd /home/public_html/attendance

# 1. Pull code mới nhất
git pull origin staging

# 2. Đảm bảo thư mục tồn tại
mkdir -p uploads secrets

# 3. Rebuild và restart
make stg-up-build

# 4. (Nếu có migration mới)
make stg-migrate

# 5. (Nếu cần seed mới)
make stg-seed

# 6. Kiểm tra
make stg-ps
make stg-logs
```

---

## 7. Hot-reload Nginx config (không downtime)

Nếu chỉ thay đổi nginx config (file `.docker/nginx/staging.conf`):

```bash
# Copy config mới vào container
# (Rebuild nginx stage)
make stg-up-build

# HOẶC reload nhanh nếu chỉ sửa config:
make stg-nginx-reload
```

---

## 8. Rollback

### 8.1. Rollback code

```bash
cd /home/public_html/attendance

# Xem commit gần đây
git log --oneline -5

# Rollback về commit cụ thể
git checkout <commit-hash>
make stg-up-build
```

### 8.2. Rollback database migration

```bash
# Rollback migration cuối cùng
docker container exec attendance_api \
  sh -c 'node ./node_modules/typeorm/cli.js migration:revert -d dist/core/database/data-source.js'
```

### 8.3. Full rollback (nghiêm trọng)

```bash
# Stop containers
make stg-down

# Rollback code
git checkout <commit-hash>

# Rebuild
make stg-up-build

# Rollback migrations nếu cần
# Restore database từ backup nếu cần
```

---

## 9. Database Backup & Restore

### 9.1. Dump (trên external MariaDB)

```bash
mysqldump -h <db-host> -u <db-user> -p<db-password> <db-name> > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 9.2. Restore

```bash
mysql -h <db-host> -u <db-user> -p<db-password> <db-name> < backup_20260331_120000.sql
```

### 9.3. Automate backup (cron)

```bash
# Thêm vào crontab (backup lúc 2h sáng mỗi ngày)
crontab -e
# Thêm dòng:
0 2 * * * mysqldump -h <db-host> -u <db-user> -p<db-password> <db-name> | gzip > /home/public_html/attendance/backups/db_$(date +\%Y\%m\%d).sql.gz
```

---

## 10. Troubleshooting

| Vấn đề | Giải pháp |
|---------|-----------|
| Container không start | `make stg-logs` — kiểm tra lỗi |
| API không kết nối DB | Kiểm tra `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS` trong `.env.staging.docker` |
| Nginx trả 502 | Kiểm tra API/Client container đang chạy: `make stg-ps` |
| HTTPS redirect loop | Kiểm tra reverse proxy/load balancer gửi header `X-Forwarded-Proto: https` |
| Migration fail | SSH vào API container: `make stg-api` rồi check logs |
| Build fail | `make stg-build` để xem chi tiết lỗi build |
| Dangling images chiếm disk | `docker image prune -f` |
| Thay đổi env không có hiệu lực | `make stg-down` rồi `make stg-up-build` |

### Xem logs chi tiết

```bash
# Tất cả containers
make stg-logs

# Chỉ API
docker compose -f docker-compose.staging.yml logs -f api

# Chỉ Client
docker compose -f docker-compose.staging.yml logs -f client

# Chỉ Nginx
docker compose -f docker-compose.staging.yml logs -f nginx

# 100 dòng gần nhất
docker compose -f docker-compose.staging.yml logs --tail 100
```

---

## 11. Checklist trước khi Deploy

- [ ] `.env.staging.docker` đã được cấu hình đúng
- [ ] `secrets/google-sheet.json` đã được copy (nếu dùng Google Sheets)
- [ ] Database external đã tạo và accessible
- [ ] `shared` Docker network đã tồn tại
- [ ] Ports 10080 không bị chiếm
- [ ] Migration mới đã được test ở local
- [ ] Branch `staging` đã merge code mới nhất
- [ ] GitHub Secrets đã được cấu hình (nếu dùng CI/CD)

---

## 12. Checklist sau khi Deploy

- [ ] Tất cả containers đang chạy: `make stg-ps`
- [ ] Migrations đã chạy: kiểm tra API logs không có migration error
- [ ] Trang web load được: truy cập staging URL
- [ ] Login thành công
- [ ] API trả response: `/api/v1` endpoint
- [ ] SSL/HTTPS hoạt động
- [ ] Slack notification nhận được (nếu cấu hình)
