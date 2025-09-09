#!/bin/bash

# ================================================
# ERP TN Group - Custom PostgreSQL Entrypoint
# Khởi động PostgreSQL + Cron cho auto backup
# ================================================

set -e

echo "🚀 Starting ERP TN Group PostgreSQL with Auto Backup..."

# Khởi động PostgreSQL trong background
echo "📊 Starting PostgreSQL..."
docker-entrypoint.sh postgres &
PG_PID=$!

# Đợi PostgreSQL sẵn sàng
echo "⏳ Waiting for PostgreSQL to be ready..."
until pg_isready -U "${POSTGRES_USER:-erp_admin}" -d "${POSTGRES_DB:-erp_tngroup}" 2>/dev/null; do
    sleep 2
done
echo "✅ PostgreSQL is ready!"

# Khởi động cron service
echo "⏰ Starting cron service..."
service cron start

# Tạo log file cho backup
mkdir -p /var/log
touch /var/log/backup.log
chown postgres:postgres /var/log/backup.log

echo "🎉 ERP TN Group PostgreSQL with Auto Backup is ready!"
echo "📋 Auto backup scheduled daily at 2:00 AM (Asia/Ho_Chi_Minh)"
echo "📁 Backup location: /backups"
echo "📝 Backup logs: /var/log/backup.log"

# Log the startup
echo "[$(date '+%Y-%m-%d %H:%M:%S')] PostgreSQL with Auto Backup started" >> /var/log/backup.log

# Giữ container chạy
wait $PG_PID
