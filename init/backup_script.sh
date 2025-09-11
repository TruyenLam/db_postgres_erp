#!/bin/bash

# ================================================
# ERP TN Group - Secure Auto Backup Script
# Backup PostgreSQL với encryption và security
# ================================================

# Set timezone
export TZ=Asia/Ho_Chi_Minh

# Database connection info
DB_HOST="localhost"
DB_NAME="${POSTGRES_DB:-erp_tngroup}"
DB_USER="${POSTGRES_USER:-erp_admin}"
PGPASSWORD="${POSTGRES_PASSWORD}"
export PGPASSWORD

# Backup settings
BACKUP_DIR="/backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="backup_${DATE}.sql"
ENCRYPTED_FILE="backup_${DATE}.sql.gpg"
LOG_FILE="/var/log/backup.log"

# Security settings
ENCRYPTION_KEY="${BACKUP_ENCRYPTION_KEY:-ERP_TN_GROUP_BACKUP_KEY_2025}"
KEEP_DAYS=30

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to secure delete
secure_delete() {
    if [ -f "$1" ]; then
        # Overwrite file with random data before deletion
        dd if=/dev/urandom of="$1" bs=1M count=1 2>/dev/null || true
        rm -f "$1"
    fi
}

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Security: Set proper permissions
chmod 700 "$BACKUP_DIR"

# Start backup
log_message "🔒 Starting secure backup: $BACKUP_FILE"

# Check database connectivity
if ! pg_isready -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
    log_message "❌ Database not accessible for backup"
    exit 1
fi

# Run pg_dump to temporary file
TEMP_BACKUP="/tmp/temp_backup_${DATE}.sql"
if pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" \
    --no-password \
    --verbose \
    --format=custom \
    --compress=9 \
    --encoding=UTF8 \
    > "$TEMP_BACKUP" 2>/dev/null; then
    
    # Get file size
    FILE_SIZE=$(stat -f%z "$TEMP_BACKUP" 2>/dev/null || stat -c%s "$TEMP_BACKUP" 2>/dev/null || echo "unknown")
    log_message "✅ Database dump completed: $FILE_SIZE bytes"
    
    # Encrypt backup file
    if command -v gpg >/dev/null 2>&1; then
        log_message "🔐 Encrypting backup file..."
        
        # Create GPG encrypted backup
        echo "$ENCRYPTION_KEY" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 --compress-algo 2 --output "$BACKUP_DIR/$ENCRYPTED_FILE" "$TEMP_BACKUP"
        
        if [ $? -eq 0 ]; then
            log_message "🔒 Backup encrypted successfully: $ENCRYPTED_FILE"
            
            # Secure delete temporary file
            secure_delete "$TEMP_BACKUP"
            
            # Set secure permissions on encrypted backup
            chmod 600 "$BACKUP_DIR/$ENCRYPTED_FILE"
            
            # Calculate checksum
            if command -v sha256sum >/dev/null 2>&1; then
                CHECKSUM=$(sha256sum "$BACKUP_DIR/$ENCRYPTED_FILE" | cut -d' ' -f1)
                echo "$CHECKSUM  $ENCRYPTED_FILE" > "$BACKUP_DIR/${ENCRYPTED_FILE}.sha256"
                log_message "� Checksum created: $CHECKSUM"
            fi
            
        else
            log_message "❌ Backup encryption failed"
            secure_delete "$TEMP_BACKUP"
            exit 1
        fi
    else
        # Fallback: Compress without encryption (less secure)
        log_message "⚠️  GPG not available, using compression only"
        gzip -9 "$TEMP_BACKUP"
        mv "${TEMP_BACKUP}.gz" "$BACKUP_DIR/backup_${DATE}.sql.gz"
        chmod 600 "$BACKUP_DIR/backup_${DATE}.sql.gz"
        log_message "📦 Backup compressed: backup_${DATE}.sql.gz"
    fi
    
    # Cleanup old backups
    log_message "🧹 Cleaning up backups older than $KEEP_DAYS days..."
    find "$BACKUP_DIR" -name "backup_*.sql*" -type f -mtime +$KEEP_DAYS -exec rm -f {} \; 2>/dev/null
    
    # Count remaining backups
    BACKUP_COUNT=$(find "$BACKUP_DIR" -name "backup_*.sql*" -type f | wc -l)
    log_message "📊 Total backups: $BACKUP_COUNT"
    
    # Log backup to database (if possible)
    if pg_isready -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
        psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "
            INSERT INTO backup_history (backup_name, backup_type, notes) 
            VALUES ('$ENCRYPTED_FILE', 'auto', 'Encrypted backup with GPG AES256')
            ON CONFLICT DO NOTHING;
        " >/dev/null 2>&1 || true
    fi
    
else
    log_message "❌ Backup failed for: $BACKUP_FILE"
    secure_delete "$TEMP_BACKUP"
    exit 1
fi

log_message "🎉 Secure backup process completed successfully"
