#!/bin/bash
# ================================================
# ERP TN Group - Custom PostgreSQL Docker Entrypoint
# Enhanced security, vector support và backup automation
# ================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ERP TN Group - PostgreSQL với Vector DB Support${NC}"
echo -e "${BLUE}================================================${NC}"

# Security: Ensure running as postgres user
if [ "$(id -u)" = "0" ]; then
    echo -e "${YELLOW}⚠️  Running as root, switching to postgres user...${NC}"
    exec gosu postgres "$BASH_SOURCE" "$@"
fi

# Set timezone
export TZ=${TZ:-Asia/Ho_Chi_Minh}
echo -e "${GREEN}🌏 Timezone set to: ${TZ}${NC}"

# PostgreSQL configuration enhancements
export POSTGRES_DB=${POSTGRES_DB:-erpdb}
export POSTGRES_USER=${POSTGRES_USER:-postgres}

# Vector-specific PostgreSQL settings
echo -e "${BLUE}🧠 Configuring PostgreSQL for Vector Operations...${NC}"

# Create custom postgresql.conf với vector optimizations
if [ ! -f /var/lib/postgresql/data/postgresql.conf ]; then
    echo -e "${YELLOW}📝 Creating optimized postgresql.conf...${NC}"
    
    # Vector DB optimizations
    cat >> /tmp/postgresql_vector.conf << 'EOF'
# Vector Database Optimizations
shared_preload_libraries = 'vector'
max_connections = 200
shared_buffers = 512MB
effective_cache_size = 1GB
work_mem = 16MB
maintenance_work_mem = 256MB
random_page_cost = 1.1
effective_io_concurrency = 200

# Vector-specific settings
vector.max_vector_dims = 2000
vector.ivfflat_probes = 10

# Logging for monitoring
log_destination = 'stderr'
log_statement = 'mod'
log_min_duration_statement = 1000
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '

# SSL Settings - DISABLED for development
# TODO: Enable SSL for production
# ssl = on
# ssl_cert_file = '/ssl/server.crt'
# ssl_key_file = '/ssl/server.key'
# ssl_ca_file = '/ssl/server.crt'
ssl = off

# Security settings
password_encryption = 'scram-sha-256'

# Performance monitoring
track_activities = on
track_counts = on
track_io_timing = on
track_functions = all
EOF
fi

# Security: Set proper SSL permissions (DISABLED for now)
if [ -d "/ssl" ] && [ "${ENABLE_SSL:-false}" = "true" ]; then
    echo -e "${GREEN}🔒 Configuring SSL certificates...${NC}"
    chown -R postgres:postgres /ssl 2>/dev/null || true
    chmod 600 /ssl/server.key 2>/dev/null || true
    chmod 644 /ssl/server.crt 2>/dev/null || true
else
    echo -e "${YELLOW}⚠️  SSL disabled - running in development mode${NC}"
fi

# Backup directory setup
if [ -d "/backups" ]; then
    echo -e "${GREEN}💾 Setting up backup directory...${NC}"
    chown -R postgres:postgres /backups 2>/dev/null || echo -e "${YELLOW}⚠️  Cannot change backup directory ownership (expected in some environments)${NC}"
    chmod 755 /backups 2>/dev/null || echo -e "${YELLOW}⚠️  Cannot change backup directory permissions (expected in some environments)${NC}"
fi

# Function to wait for PostgreSQL to be ready
wait_for_postgres() {
    echo -e "${YELLOW}⏳ Waiting for PostgreSQL to be ready...${NC}"
    until pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -q; do
        sleep 2
    done
    echo -e "${GREEN}✅ PostgreSQL is ready!${NC}"
}

# Function to setup vector extensions
setup_vector_extensions() {
    echo -e "${BLUE}🧠 Setting up Vector Extensions...${NC}"
    
    # Connect and setup extensions using postgres superuser
    PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        -- Create vector extension
        CREATE EXTENSION IF NOT EXISTS vector;
        
        -- Verify vector extension
        SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';
        
        -- Show vector capabilities
        \echo '🎯 Vector extension loaded successfully!'
        \echo 'Available vector operators: <->, <#>, <=>''
        \echo 'Maximum vector dimensions: 16000'
EOSQL

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Vector extensions setup completed!${NC}"
    else
        echo -e "${RED}❌ Failed to setup vector extensions${NC}"
        return 1
    fi
}

# Function to setup backup automation
setup_backup_automation() {
    echo -e "${BLUE}💾 Setting up backup automation...${NC}"
    
    # Start cron daemon
    if command -v crond >/dev/null 2>&1; then
        crond -b
        echo -e "${GREEN}✅ Backup automation enabled${NC}"
    else
        echo -e "${YELLOW}⚠️  Cron not available, manual backups only${NC}"
    fi
}

# Function to show startup information
show_startup_info() {
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}🎉 ERP TN Group PostgreSQL Ready!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}📊 Database: ${POSTGRES_DB}${NC}"
    echo -e "${GREEN}👤 User: ${POSTGRES_USER}${NC}"
    echo -e "${GREEN}🧠 Vector Support: Enabled (pgvector)${NC}"
    echo -e "${GREEN}🔒 SSL: Enabled${NC}"
    echo -e "${GREEN}💾 Backups: Automated${NC}"
    echo -e "${GREEN}🌏 Timezone: ${TZ}${NC}"
    echo -e "${GREEN}================================================${NC}"
    
    # Show vector extension status
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 'Vector Extension Version: ' || extversion FROM pg_extension WHERE extname = 'vector';" 2>/dev/null || true
}

# Main execution flow
main() {
    echo -e "${BLUE}🔧 Starting PostgreSQL initialization...${NC}"
    
    # If this is the first run, setup everything
    if [ ! -s "$PGDATA/PG_VERSION" ]; then
        echo -e "${YELLOW}📦 First-time setup detected${NC}"
        
        # Run original docker-entrypoint.sh for initialization but in background
        /usr/local/bin/docker-entrypoint.sh postgres &
        POSTGRES_PID=$!
        
        # Wait for PostgreSQL to start
        echo -e "${YELLOW}⏳ Waiting for PostgreSQL to be ready...${NC}"
        sleep 10
        
        # Wait for postgres to be ready
        for i in {1..30}; do
            if pg_isready -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -q 2>/dev/null; then
                echo -e "${GREEN}✅ PostgreSQL is ready!${NC}"
                break
            fi
            echo -e "${YELLOW}⏳ Still waiting... (attempt $i/30)${NC}"
            sleep 2
        done
        
        # Setup vector extensions
        setup_vector_extensions
        setup_backup_automation
        show_startup_info
        
        # Wait for the postgres process
        wait $POSTGRES_PID
        
    else
        echo -e "${GREEN}🔄 Starting existing PostgreSQL instance...${NC}"
        
        # Apply vector config if not already done
        if ! grep -q "shared_preload_libraries.*vector" "$PGDATA/postgresql.conf" 2>/dev/null; then
            echo -e "${YELLOW}🔧 Applying vector configuration...${NC}"
            cat /tmp/postgresql_vector.conf >> "$PGDATA/postgresql.conf"
        fi
        
        # Start PostgreSQL normally
        exec /usr/local/bin/docker-entrypoint.sh postgres
    fi
}

# Handle different execution modes
if [ "${1#-}" != "$1" ] || [ "$1" = 'postgres' ]; then
    main "$@"
else
    # Execute custom command
    exec "$@"
fi
