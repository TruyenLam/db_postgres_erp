#!/bin/bash

# ================================================
# ERP TN Group - Database Initialization Script
# Thiết lập cron job cho auto backup
# ================================================

set -e

echo "🚀 ERP TN Group - Setting up auto backup..."

# Install cron if not available
if ! command -v cron >/dev/null 2>&1; then
    echo "📦 Installing cron..."
    apt-get update && apt-get install -y cron
fi

# Copy backup script và set permissions
if [ -f /docker-entrypoint-initdb.d/backup_script.sh ]; then
    cp /docker-entrypoint-initdb.d/backup_script.sh /usr/local/bin/
    chmod +x /usr/local/bin/backup_script.sh
    echo "✅ Backup script installed"
fi

# Tạo cron job file
cat > /etc/cron.d/postgres-backup << 'EOF'
# ERP TN Group - Auto Backup Schedule
# Backup mỗi ngày lúc 2:00 AM (Vietnam time)
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
TZ=Asia/Ho_Chi_Minh

# m h dom mon dow user command
0 2 * * * postgres /usr/local/bin/backup_script.sh >/dev/null 2>&1

# Backup thêm vào 14:00 (2 PM) để test
# 0 14 * * * postgres /usr/local/bin/backup_script.sh >/dev/null 2>&1
EOF

# Set permissions cho cron job
chmod 0644 /etc/cron.d/postgres-backup

# Tạo log directory
mkdir -p /var/log
touch /var/log/backup.log
chown postgres:postgres /var/log/backup.log

echo "✅ Cron job scheduled: Daily backup at 2:00 AM (Asia/Ho_Chi_Minh)"

# Start cron daemon
service cron start

# Enable cron service to start on boot
update-rc.d cron enable

echo "🎉 Auto backup setup completed!"

# Log the setup
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Auto backup initialized" >> /var/log/backup.log
