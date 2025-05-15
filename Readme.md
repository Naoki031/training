# Attendance Project 🚀

[![Docker Compose](https://img.shields.io/badge/docker--compose-enabled-blue?logo=docker)](https://docs.docker.com/compose/)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

Hệ thống quản lý điểm danh hiện đại, triển khai nhanh chóng với Docker Compose.  
**Stack:** NestJS (API) · Nuxt.js (Client) · MariaDB (Database) · Nginx (Reverse Proxy)

---

## 🗂️ Cấu trúc thư mục

```
.
├── .docker/
│   ├── client/
│   ├── mariadb/
│   ├── nginx/
│   └── node_server/
├── sources/
│   ├── attendance_api/
│   └── attendance_client/
├── docker-compose.yml
└── Readme
```

---

## ⚙️ Yêu cầu hệ thống

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Mac/Windows/Linux)
- Docker Compose v2 trở lên

---

## 🚀 Khởi động nhanh

```sh
# 1. Clone repository
git clone <repo-url>
cd training

# 2. Tạo file .env cho từng service nếu chưa có
cp sources/attendance_api/.env.example sources/attendance_api/.env
cp sources/attendance_client/.env.example sources/attendance_client/.env

# 3. Khởi động Docker Desktop (nếu chưa chạy)

# 4. Build & chạy toàn bộ hệ thống
docker compose up -d --build
# hoặc nếu có Makefile
make up-build
```

---

## 🌐 Truy cập dịch vụ

- **API:** [http://localhost:3001](http://localhost:3001)
- **Client:** [http://localhost:3000](http://localhost:3000)
- **Database Admin (nếu có):** [http://localhost:8080](http://localhost:8080)

---

## 🛠️ Một số lệnh hữu ích

| Chức năng                | Lệnh                                           |
|--------------------------|------------------------------------------------|
| Dừng toàn bộ hệ thống    | `docker compose down` hoặc `make down`         |
| Xem logs                 | `docker compose logs -f`                       |
| Xây dựng lại image       | `docker compose build --no-cache` hoặc `make build` |
| Kiểm tra container       | `docker compose ps`                            |

---

## ⚠️ Lưu ý

- Nếu gặp lỗi port bị chiếm, hãy kiểm tra và dừng các dịch vụ đang sử dụng port đó trên máy host (ví dụ: MySQL/MariaDB cài sẵn).
- Đảm bảo Docker daemon luôn chạy trước khi thao tác.
- Đừng quên cập nhật biến môi trường trong các file `.env` cho phù hợp với môi trường của bạn.

---

## ❓ FAQ

**Q:** Không thể kết nối Docker daemon?  
**A:** Hãy chắc chắn Docker Desktop đã chạy. Nếu vẫn lỗi, thử khởi động lại Docker Desktop hoặc máy tính.

**Q:** Port 3306 bị chiếm?  
**A:** Đổi sang port khác trong `docker-compose.yml` hoặc dừng dịch vụ MySQL/MariaDB trên máy host.

---

## 👤 Thông tin liên hệ

- **Người phát triển:** Nguyễn Trung Trực  
- **Email:** trucnguyen.dofuu@gmail.com

---

> *Happy Coding! 🚦*