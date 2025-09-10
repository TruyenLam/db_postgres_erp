# 🗄️ PostgreSQL Database Platform for ERP Applications

**Hệ thống PostgreSQL được tùy chỉnh chuyên biệt cho các ứng dụng ERP doanh nghiệp**

## 📋 **Giới thiệu**

Đây **KHÔNG PHẢI** là một ứng dụng ERP hoàn chỉnh, mà là một **nền tảng database PostgreSQL** được thiết kế và tối ưu hóa đặc biệt để phục vụ cho việc phát triển các ứng dụng ERP. 

### 🎯 **Mục đích của dự án:**

- 🗄️ **Database Infrastructure** - Cung cấp nền tảng database ổn định và mạnh mẽ
- 🔧 **ERP-Ready Configuration** - Cấu hình sẵn cho các yêu cầu ERP thông thường
- 🛡️ **Enterprise Security** - Bảo mật cấp doanh nghiệp từ ngày đầu
- 📊 **Management Tools** - Công cụ quản lý database trực quan
- ⚡ **Performance Optimization** - Tối ưu hiệu suất cho workload ERP
- 🔄 **Auto Backup & Recovery** - Hệ thống sao lưu tự động an toàn

### 👥 **Dành cho ai:**

- **Backend Developers** - Phát triển API và business logic cho ERP
- **Full-stack Developers** - Xây dựng ứng dụng ERP từ A-Z  
- **DevOps Engineers** - Deploy và quản lý hạ tầng ERP
- **Database Administrators** - Quản lý database ERP quy mô lớn
- **System Architects** - Thiết kế kiến trúc hệ thống ERP

---

## 🏗️ **Kiến trúc hệ thống**

### **Core Components:**
```
┌─────────────────────────────────────────────────────────────┐
│                PostgreSQL Database Platform                │
├─────────────────────────────────────────────────────────────┤
│  🗄️  PostgreSQL 15      │  📊  pgAdmin 4 Web UI            │
│  ⚡  Redis Cache         │  🐳  Docker Orchestration        │
│  💾  Auto Backup        │  🛡️  Enterprise Security         │
│  🧠  Vector DB (AI/ML)   │  📈  Performance Monitoring      │
└─────────────────────────────────────────────────────────────┘
```

### **✅ Tính năng chính:**

**🗄️ PostgreSQL Database:**
- ✅ PostgreSQL 15 Alpine (Latest stable)
- ✅ Optimized configuration cho ERP workloads
- ✅ Custom schema templates cho ERP entities
- ✅ Advanced indexing strategies
- ✅ Connection pooling & performance tuning

**📊 Database Management:**
- ✅ pgAdmin 4 web interface
- ✅ Visual query builder
- ✅ Database monitoring dashboard
- ✅ User & permission management
- ✅ Import/Export tools

**⚡ Caching & Performance:**
- ✅ Redis 7 caching layer
- ✅ Query result caching
- ✅ Session management
- ✅ Real-time data synchronization

**🛡️ Enterprise Security:**
- ✅ Role-based access control (RBAC)
- ✅ SSL/TLS encryption
- ✅ Network isolation
- ✅ Audit logging
- ✅ Secure password policies

**💾 Backup & Recovery:**
- ✅ Automated daily backups
- ✅ Point-in-time recovery
- ✅ Encrypted backup storage
- ✅ Backup retention policies
- ✅ One-click restore functionality

**🧠 AI/ML Ready (Optional):**
- ✅ pgvector extension
- ✅ Vector similarity search
- ✅ Document embeddings storage
- ✅ AI-powered analytics support

---

## 🚀 **HƯỚNG DẪN SETUP NHANH (5 PHÚT)**

### **Bước 1: Kiểm tra yêu cầu hệ thống**
```powershell
# Kiểm tra Docker đã cài đặt chưa
docker --version
docker-compose --version

# Nếu chưa có, download Docker Desktop:
# https://www.docker.com/products/docker-desktop/
```

### **Bước 2: Clone và setup môi trường**
```powershell
# 1. Clone repository
git clone https://github.com/TruyenLam/db_postgres_erp.git
cd db_postgres_erp

# 2. Copy file cấu hình mẫu
copy .env.example .env

# 3. Chỉnh sửa file .env (BẮT BUỘC)
notepad .env
# ⚠️ Thay đổi passwords và email của bạn!
```

### **Bước 3: Khởi động hệ thống**
```powershell
# Phiên bản test cơ bản (khuyến nghị cho lần đầu)
docker-compose -f docker-compose.test.yml up -d

# Hoặc phiên bản đầy đủ với Vector DB
docker-compose build --no-cache
docker-compose up -d
```

### **Bước 4: Kiểm tra và test**
```powershell
# Chạy script test tự động
powershell -ExecutionPolicy Bypass -File test_system.ps1

# Hoặc test thủ công
docker ps  # Xem các container đang chạy
```

### **Bước 5: Truy cập hệ thống**
- 🌐 **pgAdmin**: http://localhost:8080
- 📊 **Database**: localhost:5432
- ⚡ **Redis**: localhost:6379

**🎉 HOÀN THÀNH! Database platform đã sẵn sàng cho việc phát triển ERP!**

---

## 🔐 **THÔNG TIN TRUY CẬP**

### **Database Connection:**
```yaml
Host: localhost (hoặc erp_postgres từ container)
Port: 5432
Database: erp_tngroup
Username: erp_admin
Password: [Xem trong file .env]
```

### **pgAdmin Web Interface:**
```yaml
URL: http://localhost:8080
Email: lamvantruyen@gmail.com
Password: [Xem trong file .env]
```

### **Redis Cache:**
```yaml
Host: localhost
Port: 6379
Password: [Xem trong file .env]
```

### **Cách kết nối pgAdmin với Database:**
1. Mở http://localhost:8080
2. Đăng nhập với email và password từ .env
3. Click "Add New Server"
4. Tab "General": Đặt tên server (VD: "ERP Database")
5. Tab "Connection":
   - Host: `erp_postgres` (nếu lỗi thì dùng `localhost`)
   - Port: `5432`
   - Maintenance database: `erp_tngroup`
   - Username: `erp_admin`
   - Password: [từ file .env]
6. Click "Save"

---

## 📚 **HƯỚNG DẪN SỬ DỤNG CHO DEVELOPER**

### **Cấu trúc Database ERP cơ bản:**

```sql
-- Schema chính cho ERP
CREATE SCHEMA IF NOT EXISTS erp;

-- Bảng người dùng
CREATE TABLE erp.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    department_id INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng phòng ban
CREATE TABLE erp.departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    manager_id INTEGER REFERENCES erp.users(id),
    parent_id INTEGER REFERENCES erp.departments(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng khách hàng
CREATE TABLE erp.customers (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    tax_code VARCHAR(50),
    contact_person VARCHAR(100),
    credit_limit DECIMAL(15,2) DEFAULT 0,
    payment_terms INTEGER DEFAULT 30,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng nhà cung cấp
CREATE TABLE erp.suppliers (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    tax_code VARCHAR(50),
    contact_person VARCHAR(100),
    payment_terms INTEGER DEFAULT 30,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng sản phẩm/dịch vụ
CREATE TABLE erp.products (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    unit VARCHAR(20) DEFAULT 'pcs',
    category_id INTEGER,
    supplier_id INTEGER REFERENCES erp.suppliers(id),
    cost_price DECIMAL(15,2),
    selling_price DECIMAL(15,2),
    stock_quantity DECIMAL(15,3) DEFAULT 0,
    min_stock_level DECIMAL(15,3) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng đơn hàng
CREATE TABLE erp.orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INTEGER REFERENCES erp.customers(id),
    order_date DATE DEFAULT CURRENT_DATE,
    delivery_date DATE,
    status VARCHAR(20) DEFAULT 'pending',
    subtotal DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    created_by INTEGER REFERENCES erp.users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng chi tiết đơn hàng
CREATE TABLE erp.order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES erp.orders(id),
    product_id INTEGER REFERENCES erp.products(id),
    quantity DECIMAL(15,3) NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    line_total DECIMAL(15,2) NOT NULL
);

-- Indexes để tối ưu performance
CREATE INDEX idx_users_username ON erp.users(username);
CREATE INDEX idx_users_email ON erp.users(email);
CREATE INDEX idx_customers_code ON erp.customers(code);
CREATE INDEX idx_products_code ON erp.products(code);
CREATE INDEX idx_orders_customer ON erp.orders(customer_id);
CREATE INDEX idx_orders_date ON erp.orders(order_date);
CREATE INDEX idx_order_items_order ON erp.order_items(order_id);
```

### **Kết nối từ ứng dụng:**

**Python (psycopg2/asyncpg):**
```python
import psycopg2
from sqlalchemy import create_engine

# Thông tin kết nối
DATABASE_URL = "postgresql://erp_admin:YOUR_PASSWORD@localhost:5432/erp_tngroup"

# SQLAlchemy connection
engine = create_engine(DATABASE_URL)

# Direct psycopg2 connection
conn = psycopg2.connect(
    host="localhost",
    port="5432", 
    database="erp_tngroup",
    user="erp_admin",
    password="YOUR_PASSWORD_FROM_ENV"
)
```

**Node.js (pg/Sequelize):**
```javascript
const { Pool } = require('pg');
const { Sequelize } = require('sequelize');

// pg connection pool
const pool = new Pool({
    host: 'localhost',
    port: 5432,
    database: 'erp_tngroup', 
    user: 'erp_admin',
    password: 'YOUR_PASSWORD_FROM_ENV',
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

// Sequelize ORM
const sequelize = new Sequelize(
    'erp_tngroup', 'erp_admin', 'YOUR_PASSWORD', {
        host: 'localhost',
        dialect: 'postgres'
    }
);
```

**PHP (PDO/Laravel):**
```php
// PDO connection
$pdo = new PDO(
    'pgsql:host=localhost;port=5432;dbname=erp_tngroup',
    'erp_admin', 
    'YOUR_PASSWORD_FROM_ENV'
);

// Laravel .env configuration
DB_CONNECTION=pgsql
DB_HOST=localhost
DB_PORT=5432
DB_DATABASE=erp_tngroup
DB_USERNAME=erp_admin
DB_PASSWORD=YOUR_PASSWORD_FROM_ENV
```

**Java (JDBC/Spring Boot):**
```java
// JDBC URL
String url = "jdbc:postgresql://localhost:5432/erp_tngroup";
String username = "erp_admin";
String password = "YOUR_PASSWORD_FROM_ENV";

// Spring Boot application.properties
spring.datasource.url=jdbc:postgresql://localhost:5432/erp_tngroup
spring.datasource.username=erp_admin
spring.datasource.password=YOUR_PASSWORD_FROM_ENV
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
```

---

## 🧪 **TESTING VÀ KIỂM TRA HỆ THỐNG**

### **Scripts test tự động:**
```powershell
# Test toàn bộ hệ thống
powershell -ExecutionPolicy Bypass -File test_system.ps1

# Test hiệu suất nhanh
powershell -ExecutionPolicy Bypass -File quick_test.ps1

# Validate volume mapping
powershell -ExecutionPolicy Bypass -File validate_volumes.ps1
```

### **Test thủ công:**
```powershell
# Kiểm tra containers đang chạy
docker ps

# Test kết nối database
docker exec -it erp_postgres psql -U erp_admin -d erp_tngroup -c "\l"

# Test tạo bảng và dữ liệu
docker exec -it erp_postgres psql -U erp_admin -d erp_tngroup -c "
    CREATE TABLE test_table (id SERIAL PRIMARY KEY, name VARCHAR(100)); 
    INSERT INTO test_table (name) VALUES ('Test 1'), ('Test 2'); 
    SELECT * FROM test_table;"

# Test backup
docker exec erp_postgres pg_dump -U erp_admin -d erp_tngroup > backup/test_backup.sql

# Kiểm tra logs
docker logs erp_postgres --tail 20
```

### **Kết quả test mong muốn:**
```
✅ Container Status: ALL RUNNING
✅ Database Connection: SUCCESSFUL  
✅ pgAdmin Access: WORKING
✅ Redis Connection: HEALTHY
✅ Backup System: FUNCTIONAL
✅ Performance: OPTIMAL
```

---

## 🔧 **QUẢN LÝ VÀ MONITORING**

### **Xem logs và trạng thái:**
```powershell
# Logs PostgreSQL
docker logs erp_postgres --tail 50

# Logs pgAdmin  
docker logs erp_pgadmin --tail 20

# Logs Redis
docker logs erp_redis --tail 20

# Trạng thái tất cả containers
docker ps -a

# Sử dụng tài nguyên
docker stats
```

### **Backup và Restore:**
```powershell
# Backup thủ công
docker exec erp_postgres pg_dump -U erp_admin -d erp_tngroup > backup/manual_backup.sql

# Backup với compression
docker exec erp_postgres pg_dump -U erp_admin -d erp_tngroup | gzip > backup/compressed_backup.sql.gz

# Restore từ backup
docker exec -i erp_postgres psql -U erp_admin -d erp_tngroup < backup/backup_file.sql

# Xem danh sách backup
dir backup\

# Chạy backup script tự động
.\backup_manual.bat
```

### **Quản lý containers:**
```powershell
# Dừng hệ thống
docker-compose down

# Dừng và xóa volumes (NGUY HIỂM!)
docker-compose down -v

# Khởi động lại
docker-compose up -d

# Rebuild khi có thay đổi
docker-compose build --no-cache
docker-compose up -d

# Scale Redis (nếu cần)
docker-compose up -d --scale redis=2
```

---

## ❗ **TROUBLESHOOTING - GIẢI QUYẾT VẤN ĐỀ**

### **Vấn đề thường gặp:**

**1. 🐳 Docker Desktop không chạy:**
```powershell
# Khởi động Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Đợi 60 giây rồi kiểm tra
timeout /t 60
docker info
```

**2. 🔐 Lỗi password/authentication:**
```powershell
# Kiểm tra file .env
type .env

# Tạo lại passwords
.\generate_passwords.bat

# Rebuild containers với config mới
docker-compose down -v
docker-compose build --no-cache  
docker-compose up -d
```

**3. 🌐 Không truy cập được pgAdmin:**
```powershell
# Kiểm tra container pgAdmin
docker logs erp_pgadmin

# Kiểm tra port có bị chiếm không
netstat -an | findstr :8080

# Restart pgAdmin
docker restart erp_pgadmin
```

**4. 🗄️ Database không kết nối được:**
```powershell
# Kiểm tra PostgreSQL container
docker logs erp_postgres

# Test connection trực tiếp
docker exec -it erp_postgres psql -U erp_admin -d erp_tngroup

# Kiểm tra network
docker network ls
docker network inspect db_postgresql_erp_network
```

**5. 💾 Backup không hoạt động:**
```powershell
# Kiểm tra thư mục backup
dir backup\

# Test backup thủ công
docker exec erp_postgres pg_dump -U erp_admin -d erp_tngroup > backup/test.sql

# Kiểm tra permissions
icacls backup\
```

**6. 🚀 Performance chậm:**
```powershell
# Kiểm tra tài nguyên
docker stats

# Restart toàn bộ hệ thống
docker-compose restart

# Tăng memory cho Docker Desktop (Settings > Resources)
```

### **Commands hữu ích:**
```powershell
# Xóa tất cả và bắt đầu lại (NGUY HIỂM!)
docker-compose down -v --remove-orphans
docker system prune -af
docker volume prune -f

# Backup toàn bộ trước khi reset
docker exec erp_postgres pg_dump -U erp_admin -d erp_tngroup > backup/before_reset.sql

# Kiểm tra disk space
docker system df
```

---

## 📈 **PERFORMANCE TUNING**

### **PostgreSQL Optimization:**
```sql
-- Kiểm tra slow queries
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC LIMIT 10;

-- Kiểm tra index usage
SELECT schemaname, tablename, attname, n_distinct, correlation 
FROM pg_stats 
WHERE schemaname = 'erp';

-- Analyze database statistics
ANALYZE;

-- Vacuum để cleanup
VACUUM ANALYZE;
```

### **Configuration Tuning:**
```ini
# postgresql.conf optimizations (trong volumes/data/)
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
```

### **Redis Optimization:**
```bash
# Redis config optimizations
maxmemory 256mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

---

## 🔄 **DEPLOYMENT ENVIRONMENTS**

### **Development Environment:**
```powershell
# Sử dụng docker-compose.dev.yml
docker-compose -f docker-compose.dev.yml up -d

# Includes: Jupyter notebook, debug mode
```

### **Testing Environment:**
```powershell
# Sử dụng docker-compose.test.yml
docker-compose -f docker-compose.test.yml up -d

# Simplified setup cho testing
```

### **Production Environment:**
```powershell
# Sử dụng docker-compose.yml
docker-compose up -d

# Full security, SSL, monitoring
```

---

## 🏁 **KẾT LUẬN**

### ✅ **Những gì bạn nhận được:**

- 🗄️ **Production-ready PostgreSQL Database** - Sẵn sàng cho ứng dụng ERP
- 📊 **Professional Management Tools** - pgAdmin, monitoring, backup
- 🛡️ **Enterprise Security** - Authentication, encryption, access control
- ⚡ **High Performance** - Optimized cho ERP workloads
- 🔄 **Automated Operations** - Backup, recovery, maintenance
- 📚 **Complete Documentation** - Setup, usage, troubleshooting
- 🧪 **Testing Framework** - Automated validation scripts

### 🚀 **Next Steps cho việc phát triển ERP:**

1. **📱 Frontend Development**
   - React, Vue.js, Angular cho web interface
   - React Native, Flutter cho mobile apps

2. **🔧 Backend API Development**
   - REST API với Node.js, Python, PHP, Java
   - GraphQL cho flexible data queries
   - Microservices architecture

3. **📊 Business Logic Implementation**
   - Accounting modules (GL, AP, AR)
   - Inventory management
   - CRM & Sales management
   - HR & Payroll systems
   - Reporting & Analytics

4. **🔌 Integration Capabilities**
   - Third-party API integrations
   - Import/Export functionalities
   - Email & notification systems
   - Document management

### 🎯 **Lợi ích của việc sử dụng platform này:**

- **⏱️ Tiết kiệm thời gian**: Không cần setup database từ đầu
- **🛡️ Bảo mật cao**: Enterprise-grade security từ ngày đầu
- **📈 Scalable**: Dễ dàng mở rộng theo nhu cầu doanh nghiệp
- **🔧 Maintenance**: Automated backup và monitoring
- **👥 Team Ready**: Multiple developers có thể work cùng lúc
- **📚 Documentation**: Đầy đủ hướng dẫn và best practices

---

## 👨‍💻 **Developer Information**

**🏢 Developed for:** TN Group & ERP Development Community  
**👤 Developer:** Lam Van Truyen  
**📧 Email:** lamvantruyen@gmail.com  
**💼 LinkedIn:** https://www.linkedin.com/in/lamtruyen/  
**🌐 Website:** shareapiai.com  

## 📞 **Support & Contact**

Để được hỗ trợ kỹ thuật hoặc có câu hỏi về platform:

📧 **Email Support:** lamvantruyen@gmail.com  
💼 **Professional Network:** https://www.linkedin.com/in/lamtruyen/  
🌐 **Technical Blog:** shareapiai.com  
🔗 **GitHub Repository:** https://github.com/TruyenLam/db_postgres_erp

**⏰ Response Time:** Thường trong vòng 24 giờ  
**🔧 Support Type:** Technical consultation, troubleshooting, customization  

---

### 🎉 **PostgreSQL Database Platform for ERP - Ready for Development!**

**📅 Created:** September 2025  
**🔄 Last Updated:** September 10, 2025  
**📊 Version:** 1.0 Production Ready  
**✅ Status:** Active Development & Support  

---

> 💡 **Tip:** Bookmark this README để dễ dàng tham khảo các commands và best practices khi phát triển ERP!

**🚀 Chúc bạn thành công với việc phát triển ứng dụng ERP trên nền tảng này!**
