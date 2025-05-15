# Attendance Project 🚀

[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-enabled-blue?logo=docker)](https://docs.docker.com/compose/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A modern **attendance management system** built for rapid deployment using **Docker Compose**.  
**Tech Stack**:  
- **API**: NestJS  
- **Client**: Nuxt.js  
- **Database**: MariaDB  
- **Reverse Proxy**: Nginx  

---

## 📂 Project Structure

```
attendance-project/
├── .docker/                     # Docker configuration files
│   ├── client/                  # Client service configs
│   ├── mariadb/                 # Database configs
│   ├── nginx/                   # Nginx configs
│   └── node_server/             # API server configs
├── sources/                     # Source code
│   ├── attendance_api/          # NestJS API
│   └── attendance_client/       # Nuxt.js Client
├── docker-compose.yml           # Docker Compose configuration
└── README.md                    # Project documentation
```

---

## ⚙️ System Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (compatible with Mac, Windows, or Linux)
- Docker Compose v2 or higher

---

## 🚀 Quick Start

Follow these steps to get the system up and running:

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd attendance-project
   ```

2. **Clone submodules** for the API and Client:
   ```bash
   git clone https://github.com/Naoki031/attendance_client sources/attendance_client
   git clone https://github.com/Naoki031/attendance_api sources/attendance_api
   ```

3. **Set up environment files**:
   ```bash
   cp sources/attendance_api/.env.example sources/attendance_api/.env
   cp sources/attendance_client/.env.example sources/attendance_client/.env
   ```

4. **Ensure Docker Desktop is running**.

5. **Build and start the system**:
   ```bash
   docker compose up -d --build
   ```
   *Alternatively, if a Makefile is provided*:
   ```bash
   make up-build
   ```

---

## 🌐 Accessing Services

Once the system is running, access the services at:

- **API**: [http://localhost:3001](http://localhost:3001)  
- **Client**: [http://localhost:3000](http://localhost:3000)  
- **Database Admin** (if enabled): [http://localhost:8080](http://localhost:8080)  

---

## 🛠️ Useful Commands

| Task                     | Command                                      |
|--------------------------|----------------------------------------------|
| Stop the system          | `docker compose down` or `make down`         |
| View logs                | `docker compose logs -f`                     |
| Rebuild images           | `docker compose build --no-cache` or `make build` |
| Check running containers | `docker compose ps`                          |

---

## ⚠️ Important Notes

- **Port conflicts**: If ports (e.g., 3306) are occupied, stop conflicting services (like local MySQL/MariaDB) or update ports in `docker-compose.yml`.
- **Docker Daemon**: Ensure the Docker daemon is running before executing commands.
- **Environment variables**: Customize `.env` files to match your environment.

---

## ❓ Frequently Asked Questions

**Q: Why can't I connect to the Docker daemon?**  
**A**: Ensure Docker Desktop is running. If the issue persists, restart Docker Desktop or your computer.

**Q: Port 3306 is already in use. What should I do?**  
**A**: Either stop the local MySQL/MariaDB service or modify the port in `docker-compose.yml`.

---

## 👤 Contact Information

- **Developer**: Nguyễn Trung Trực  
- **Email**: trucnguyen.dofuu@gmail.com  

---

> *Happy Coding! 🚦*
