# 🚀 ERP TN Group - Complete PostgreSQL ERP System

Hệ thống PostgreSQL **production-ready** hoàn chỉnh cho TN Group với **bảo mật cao**, **auto backup**, **AI/ML Vector Database**, và **Web Ma## 🔐 **THÔNG TIN ĐĂNG NHẬP & TRUY CẬP**

### **Access URLs:**
- 🌐 **pgAdmin Web Interface**: http://localhost:8080
- 📊 **PostgreSQL Database**: localhost:5432
- ⚡ **Redis Cache**: localhost:6379

### **Thông tin đăng nhập:**
```
📧 pgAdmin:
   - Email: lamvantruyen@gmail.com
   - Password: [Xem trong file .env]

🗄️ Database Connection (từ pgAdmin):
   - Server Name: erp_postgres (hoặc localhost)
   - Port: 5432
   - Database: erp_tngroup
   - Username: erp_admin
   - Password: [Xem trong file .env - POSTGRES_PASSWORD]

⚡ Redis:
   - Host: localhost
   - Port: 6379
   - Password: [Xem trong file .env - POSTGRES_PASSWORD]
```

### **Cách kết nối pgAdmin với Database:**
1. Mở http://localhost:8080
2. Đăng nhập với email và password từ .env
3. Click "Add New Server"
4. Tab "General": Đặt tên server (VD: "ERP TN Group")
5. Tab "Connection":
   - Host: `erp_postgres` (nếu lỗi thì dùng `localhost`)
   - Port: `5432`
   - Maintenance database: `erp_tngroup`
   - Username: `erp_admin`
   - Password: [từ file .env]
6. Click "Save"

---terface**.

## 📋 **Tổng quan hệ thống**

Đây là một hệ thống ERP hoàn chỉnh được thiết kế để đáp ứng nhu cầu doanh nghiệp hiện đại:

- 🗄️ **PostgreSQL 15** - Database engine mạnh mẽ và ổn định
- 🌐 **pgAdmin 4** - Giao diện quản lý database trực quan
- 🚀 **Redis 7** - Caching system để tăng hiệu suất
- 🐳 **Docker** - Container deployment dễ dàng
- 💾 **Auto Backup** - Sao lưu tự động hàng ngày
- 🧠 **Vector Database** - Hỗ trợ AI/ML (optional)
- 🛡️ **Security** - Bảo mật cao cấp cho môi trường production

## 🛡️ **Security Features**

- ✅ **No Public Database Exposure** - PostgreSQL chỉ accessible qua internal network
- ✅ **SSL/TLS Encryption** - HTTPS với strong ciphers (TLSv1.2+)
- ✅ **Encrypted Backups** - GPG AES256 encryption với checksum verification
- ✅ **Docker Secrets** - Passwords không hardcoded trong code
- ✅ **Reverse Proxy** - Nginx với security headers và rate limiting
- ✅ **Network Isolation** - Custom secure bridge network
- ✅ **Resource Limits** - Container resource constraints
- ✅ **Access Control** - IP restrictions và authentication

## 🧠 **Vector Database Features**

- ✅ **pgvector Extension** - Native vector operations trong PostgreSQL
- ✅ **Similarity Search** - Cosine similarity, Euclidean distance
- ✅ **Document Embeddings** - Store và search document vectors (1536 dims)
- ✅ **Product Recommendations** - AI-powered product similarity
- ✅ **User Behavior Analytics** - Vector-based user analysis
- ✅ **Hybrid Search** - Combine text search với vector similarity
- ✅ **AI/ML Integration** - Ready for OpenAI, Cohere, Hugging Face
- ✅ **Performance Optimized** - IVFFLAT indexes cho fast search

## 📁 Cấu trúc thư mục

```
D:\ERP_TNGROUP\db_postgreSQL\
├── .env.example                # 📋 Environment template
├── .env                        # 🔐 Environment variables (KHÔNG commit)
├── .gitignore                  # Git ignore cho security
├── docker-compose.yml          # 🛡️  Secure Docker compose
├── Dockerfile                  # 🔒 Hardened PostgreSQL với pgvector
├── docker-entrypoint-custom.sh # Custom entrypoint với security
├── setup_environment.bat       # 🚀 Auto environment setup
├── generate_passwords.bat      # 🔐 Strong password generator
├── vector_db_manager.bat       # 🧠 Vector database management
├── python_vector_integration.py # 🐍 Python AI/ML integration
├── SECURITY.md                 # 📋 Security documentation
├── DEVELOPER.md                # 👨‍💻 Developer information
├── generate_ssl.bat            # 🔐 SSL certificate generator
├── security_center.bat         # 🛡️  Security management center
├── restore_secure.bat          # 🔓 Secure restore script
├── nginx/
│   └── nginx.conf              # 🌐 Reverse proxy với SSL
├── ssl/                        # 🔐 SSL certificates (tạo bằng script)
└── volumes/
    ├── data/                   # PostgreSQL data (secured)
    ├── backups/                # 🔒 Encrypted backups
    ├── init/                   # Init scripts với security
    │   ├── backup_script.sh    # 🔐 Encrypted backup script
    │   ├── backup_scripts.sql  # SQL init cho backup tracking
    │   └── vector_db_init.sql  # 🧠 Vector database initialization
    ├── pgladmin/                # pgAdmin data (secured)
    └── redis/                  # Redis data (secured)
```

## 🔄 Tính năng Auto Backup tích hợp

### ✅ **Backup tự động trong PostgreSQL container:**
- **Cron Job**: Chạy backup mỗi ngày lúc **2:00 AM** (giờ Việt Nam)
- **Compression**: Tự động nén backup với gzip
- **Cleanup**: Tự động xóa backup cũ hơn 30 ngày
- **Logging**: Ghi log chi tiết vào `/var/log/backup.log`
- **Format**: `backup_YYYYMMDD_HHMMSS.sql.gz`

### 🏗️ **Architecture:**
```
PostgreSQL Container:
├── PostgreSQL Database Service
├── Cron Daemon (auto backup)
├── Backup Script (/usr/local/bin/backup_script.sh)
└── Log file (/var/log/backup.log)
```

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
# 1. Di chuyển vào thư mục dự án
cd D:\ERP_TNGROUP\db_postgreSQL

# 2. Copy file cấu hình mẫu
copy .env.example .env

# 3. Chỉnh sửa file .env (BẮT BUỘC)
notepad .env
# Thay đổi passwords và email của bạn!
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

**🎉 HOÀN THÀNH! Hệ thống đã sẵn sàng sử dụng!**

---

## 🔧 **HƯỚNG DẪN CHI TIẾT**

### **Setup từng bước:**
```bash
# 1. � Auto setup environment
.\setup_environment.bat

# 2. �🔐 Generate strong passwords (optional)
.\generate_passwords.bat

# 3. �️  Build and start secure services
docker-compose build --no-cache
docker-compose up -d

# 4. 🔍 Check security status
.\security_center.bat
```

### **📝 Manual Setup:**
```bash
# 1. 📋 Copy environment template
copy .env.example .env

# 2. 📝 Edit .env file với passwords mạnh
notepad .env

# 3. 🔐 Generate SSL certificates
.\generate_ssl.bat

# 4. 🛡️  Build secure containers
docker-compose build --no-cache

# 5. 🚀 Start secure services
docker-compose up -d

# 6. 🔍 Check security status
.\security_center.bat
```

### **⚠️ QUAN TRỌNG - Environment Configuration:**
Trước khi chạy hệ thống, bạn **BẮT BUỘC** phải:
1. Copy `.env.example` thành `.env`
2. Thay đổi **TẤT CẢ** passwords trong `.env`
3. Cập nhật email và thông tin cá nhân
4. Tạo SSL certificates

**🔐 Passwords cần thay đổi:**
- `POSTGRES_PASSWORD` - Database password
- `PGADMIN_DEFAULT_EMAIL` - Your email
- `PGADMIN_DEFAULT_PASSWORD` - Admin interface password  
- `REDIS_PASSWORD` - Redis password
- `BACKUP_ENCRYPTION_KEY` - Backup encryption key

### **2. Access URLs (HTTPS Only):**
```
🔒 pgAdmin: https://localhost/
   Email: lamvantruyen@gmail.com
   Password: [from .env file]

🛡️  Database: Internal only
   Host: postgres_secure (không public access)
   Port: 5432 (internal)
   Database: erp_tngroup
```

## 📚 **HƯỚNG DẪN SỬ DỤNG CHO DEVELOPER**

### **Cấu trúc Database ERP:**
```sql
-- Tạo schema cơ bản cho ERP
CREATE SCHEMA IF NOT EXISTS erp;

-- Bảng users (người dùng)
CREATE TABLE erp.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng products (sản phẩm)  
CREATE TABLE erp.products (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    category_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng orders (đơn hàng)
CREATE TABLE erp.orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id INTEGER REFERENCES erp.users(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng order_items (chi tiết đơn hàng)
CREATE TABLE erp.order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES erp.orders(id),
    product_id INTEGER REFERENCES erp.products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);
```

### **Kết nối từ ứng dụng:**

**Python (psycopg2):**
```python
import psycopg2

# Thông tin kết nối
conn = psycopg2.connect(
    host="localhost",
    port="5432", 
    database="erp_tngroup",
    user="erp_admin",
    password="YOUR_PASSWORD_FROM_ENV"
)

# Thực hiện query
cursor = conn.cursor()
cursor.execute("SELECT * FROM erp.users")
results = cursor.fetchall()
```

**Node.js (pg):**
```javascript
const { Pool } = require('pg');

const pool = new Pool({
    host: 'localhost',
    port: 5432,
    database: 'erp_tngroup', 
    user: 'erp_admin',
    password: 'YOUR_PASSWORD_FROM_ENV'
});

// Query
const result = await pool.query('SELECT * FROM erp.products');
```

**PHP (PDO):**
```php
$pdo = new PDO(
    'pgsql:host=localhost;port=5432;dbname=erp_tngroup',
    'erp_admin', 
    'YOUR_PASSWORD_FROM_ENV'
);

$stmt = $pdo->query('SELECT * FROM erp.orders');
$orders = $stmt->fetchAll();
```

### **Development Workflow:**
1. 🔄 **Phát triển local**: Sử dụng pgAdmin để thiết kế schema
2. 📝 **Version control**: Backup schema thành SQL files
3. 🧪 **Testing**: Sử dụng script test tự động
4. 🚀 **Deploy**: Build và deploy với Docker
5. 📊 **Monitor**: Theo dõi logs và performance

---
```bash
# 🧠 Vector database management
.\vector_db_manager.bat

# 🐍 Python AI/ML integration
python python_vector_integration.py

# 🔍 Test similarity search
docker-compose exec postgres_secure psql -U erp_admin -d erp_tngroup -c "
SELECT * FROM vector_db.search_similar_documents(
    (SELECT ARRAY(SELECT random() FROM generate_series(1, 1536)))::vector,
    0.8, 5
);"

# �️ Product recommendations
docker-compose exec postgres_secure psql -U erp_admin -d erp_tngroup -c "
SELECT * FROM vector_db.get_product_recommendations('prod_001', 5);"
```

### **4. AI/ML Integration Examples:**
```python
# OpenAI Integration
import openai
from erp_vector_db import ERPVectorDB

# Get embedding từ OpenAI
response = openai.Embedding.create(
    input="Your text here",
    model="text-embedding-ada-002"
)
embedding = response['data'][0]['embedding']

# Insert vào vector database
vector_db = ERPVectorDB()
vector_db.connect()
vector_db.insert_document_embedding(
    document_id="doc_001",
    title="AI Document",
    content="Document content",
    embedding=embedding
)
```

## 🧪 **TESTING VÀ KIỂM TRA HỆ THỐNG**

### **Scripts test tự động:**
```powershell
# Test toàn bộ hệ thống
powershell -ExecutionPolicy Bypass -File test_system.ps1

# Test hiệu suất nhanh
powershell -ExecutionPolicy Bypass -File quick_test.ps1

# Deploy và test hoàn chỉnh
powershell -ExecutionPolicy Bypass -File deploy_system.ps1
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

# Restore từ backup
docker exec -i erp_postgres psql -U erp_admin -d erp_tngroup < backup/backup_file.sql

# Xem danh sách backup
dir backup\

# Chạy backup script
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
```

## ⚙️ Cấu hình Backup

**Thay đổi lịch backup:**
Sửa file `volumes/init/setup_backup.sh`:
```bash
# Backup mỗi ngày lúc 2:00 AM
0 2 * * * postgres /usr/local/bin/backup_script.sh

# Backup mỗi 6 giờ
0 */6 * * * postgres /usr/local/bin/backup_script.sh

# Backup mỗi tuần (Sunday 2:00 AM)
0 2 * * 0 postgres /usr/local/bin/backup_script.sh
```

**Thay đổi retention:**
Sửa `KEEP_DAYS` trong `volumes/init/backup_script.sh`:
```bash
KEEP_DAYS=30  # Giữ backup 30 ngày
KEEP_DAYS=7   # Giữ backup 7 ngày
KEEP_DAYS=90  # Giữ backup 90 ngày
```

## 🔄 Rebuild sau khi thay đổi

```bash
# Stop services
docker-compose down

# Rebuild với changes
docker-compose build --no-cache

# Restart
docker-compose up -d
```

## ⚡ Lợi ích của việc tích hợp

- ✅ **Gọn gàng**: Chỉ 1 container thay vì 2
- ✅ **Hiệu suất**: Backup local, không qua network
- ✅ **Đơn giản**: Không cần quản lý service riêng
- ✅ **Reliability**: Cron job ổn định trong PostgreSQL container
- ✅ **Resource**: Tiết kiệm memory và CPU
- ✅ **Maintenance**: Dễ monitor và troubleshoot

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

### **Liên hệ hỗ trợ:**
Nếu vấn đề vẫn không được giải quyết:
- 📧 Email: lamvantruyen@gmail.com
- 💼 LinkedIn: https://www.linkedin.com/in/lamtruyen/
- 🌐 Website: shareapiai.com

---

---

## 👨‍💻 **Developer Information**

**Developed by:** Lam Van Truyen  
**Email:** lamvantruyen@gmail.com  
**LinkedIn:** https://www.linkedin.com/in/lamtruyen/  
**Website:** shareapiai.com  

## 📞 **Support & Contact**

Nếu bạn cần hỗ trợ hoặc có câu hỏi về hệ thống:
- 📧 Email: lamvantruyen@gmail.com
- 💼 LinkedIn: https://www.linkedin.com/in/lamtruyen/
- 🌐 Website: shareapiai.com

---

## � **KẾT LUẬN**

### **✅ Tính năng đã hoàn thành:**
- ✅ PostgreSQL 15 Database với full configuration
- ✅ pgAdmin 4 Web Management Interface  
- ✅ Redis Cache System
- ✅ Docker Container Orchestration
- ✅ Automated Backup System
- ✅ Security & Authentication
- ✅ Performance Optimization
- ✅ Complete Testing Scripts
- ✅ Comprehensive Documentation

### **🎯 Hệ thống phù hợp cho:**
- 🏢 **ERP Systems** - Quản lý tài nguyên doanh nghiệp
- 📊 **Business Applications** - Ứng dụng kinh doanh
- 🔄 **Data Management** - Quản lý dữ liệu phức tạp  
- 📈 **Analytics & Reporting** - Phân tích và báo cáo
- 🤖 **AI/ML Applications** - Ứng dụng AI/ML (với Vector DB)

### **📈 Khả năng mở rộng:**
- 🔄 **Horizontal Scaling** - Thêm PostgreSQL replicas
- ⚡ **Performance Tuning** - Tối ưu queries và indexes
- 🧠 **AI Integration** - Tích hợp Vector Database
- 🌐 **API Development** - Xây dựng REST APIs
- 📱 **Mobile Support** - Hỗ trợ ứng dụng mobile

### **🚀 Next Steps:**
1. **Customization**: Tùy chỉnh schema theo nhu cầu cụ thể
2. **Application Development**: Phát triển ứng dụng ERP
3. **Performance Monitoring**: Thiết lập monitoring production  
4. **Security Hardening**: Tăng cường bảo mật cho production
5. **CI/CD Pipeline**: Thiết lập quy trình deploy tự động

---

## 👨‍💻 **Developer Information**

**🏢 Developed for:** TN Group  
**👤 Developer:** Lam Van Truyen  
**📧 Email:** lamvantruyen@gmail.com  
**💼 LinkedIn:** https://www.linkedin.com/in/lamtruyen/  
**🌐 Website:** shareapiai.com  

## 📞 **Support & Contact**

Để được hỗ trợ kỹ thuật hoặc có câu hỏi về hệ thống:

📧 **Email Support:** lamvantruyen@gmail.com  
💼 **Professional Network:** https://www.linkedin.com/in/lamtruyen/  
🌐 **Technical Blog:** shareapiai.com  

**⏰ Response Time:** Thường trong vòng 24 giờ  
**🔧 Support Type:** Technical consultation, troubleshooting, customization  

---

### 🎉 **ERP TN Group System - Ready for Production!**

**📅 Created:** September 2025  
**🔄 Last Updated:** September 9, 2025  
**📊 Version:** 1.0 Stable  
**✅ Status:** Production Ready  

---

> 💡 **Tip:** Bookmark this README để dễ dàng tham khảo các commands và troubleshooting steps!

</code>

**🏆 Chúc bạn thành công với hệ thống ERP TN Group!**
