# �️ PostgreSQL Database Platform for ERP - Quick Start Guide

**Nền tảng database PostgreSQL được tùy chỉnh cho ứng dụng ERP**

> ⚠️ **Lưu ý**: Đây là database platform, không phải ứng dụng ERP hoàn chỉnh

## ⚡ SETUP NHANH (3 BƯỚC)

### 1️⃣ Kiểm tra Docker
```powershell
docker --version
# Nếu chưa có: Download Docker Desktop
```

### 2️⃣ Cấu hình & Khởi động
```powershell
# Clone repository
git clone https://github.com/TruyenLam/db_postgres_erp.git
cd db_postgres_erp

# Copy cấu hình
copy .env.example .env

# Chỉnh sửa passwords (BẮT BUỘC)
notepad .env

# Khởi động database platform
docker-compose -f docker-compose.test.yml up -d
```

### 3️⃣ Test & Truy cập
```powershell
# Test hệ thống
powershell -ExecutionPolicy Bypass -File test_system.ps1

# Truy cập pgAdmin: http://localhost:8080
# Email: lamvantruyen@gmail.com
# Password: [từ file .env]
```

## 🗄️ **KẾT NỐI DATABASE**

```yaml
Host: localhost
Port: 5432
Database: erp_tngroup
Username: erp_admin
Password: [từ file .env]
```

## 🛠️ **SỬ DỤNG CHO DEVELOPMENT**

```sql
-- Tạo schema ERP
CREATE SCHEMA erp;

-- Ví dụ bảng users
CREATE TABLE erp.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);
```

## 🔧 COMMANDS THƯỜNG DÙNG

```powershell
# Kiểm tra trạng thái
docker ps

# Xem logs
docker logs erp_postgres

# Backup database
docker exec erp_postgres pg_dump -U erp_admin -d erp_tngroup > backup/backup.sql

# Restart hệ thống
docker-compose restart

# Dừng hệ thống
docker-compose down
```

## 📞 HỖ TRỢ
📧 Email: lamvantruyen@gmail.com  
💼 LinkedIn: https://www.linkedin.com/in/lamtruyen/

---
**🎉 ERP TN Group System Ready!**
