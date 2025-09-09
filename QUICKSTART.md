# 🚀 ERP TN Group - Quick Start Guide

## ⚡ SETUP NHANH (3 BƯỚC)

### 1️⃣ Kiểm tra Docker
```powershell
docker --version
# Nếu chưa có: Download Docker Desktop
```

### 2️⃣ Cấu hình & Khởi động
```powershell
# Copy cấu hình
copy .env.example .env

# Chỉnh sửa passwords (BẮT BUỘC)
notepad .env

# Khởi động hệ thống
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
