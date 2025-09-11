# ================================================
# ERP TN Group - Secure PostgreSQL với Auto Backup + Vector DB
# Enhanced security, backup capabilities và AI/ML support
# ================================================

FROM postgres:16-alpine

# Install build dependencies cho pgvector và security tools
RUN apk update && apk add --no-cache \
    dcron \
    gzip \
    gnupg \
    openssl \
    shadow \
    tzdata \
    # Try to install pgvector from package manager first
    postgresql16-contrib \
    && rm -rf /var/cache/apk/*

# Install pgvector extension (install only required components)
RUN apk add --no-cache --virtual .build-deps \
        build-base \
        git \
        postgresql16-dev && \
    cd /tmp && \
    git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git && \
    cd pgvector && \
    make USE_PGXS=1 PG_CONFIG=/usr/local/bin/pg_config OPTFLAGS="" && \
    # Install only the shared library and SQL files (ignore LLVM errors)
    make USE_PGXS=1 PG_CONFIG=/usr/local/bin/pg_config install-lib install-sql || \
    (cp vector.so /usr/local/lib/postgresql/ && \
     cp sql/vector.sql /usr/local/share/postgresql/extension/ && \
     cp sql/vector--*.sql /usr/local/share/postgresql/extension/ && \
     cp vector.control /usr/local/share/postgresql/extension/) && \
    cd / && \
    rm -rf /tmp/pgvector && \
    apk del .build-deps

# Security: Create non-root user for backup processes
RUN addgroup -g 2000 backup && \
    adduser -D -u 2000 -G backup backup

# Copy backup scripts
COPY volumes/init/backup_script.sh /usr/local/bin/
COPY volumes/init/setup_backup.sh /usr/local/bin/

# Set permissions với security
RUN chmod +x /usr/local/bin/backup_script.sh \
    && chmod +x /usr/local/bin/setup_backup.sh \
    && chown backup:backup /usr/local/bin/backup_script.sh

# Tạo secure cron job cho backup hàng ngày
RUN echo "0 2 * * * backup /usr/local/bin/backup_script.sh >/dev/null 2>&1" > /etc/crontab \
    && chmod 644 /etc/crontab

# Copy custom entrypoint với security enhancements
COPY docker-entrypoint-custom.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-custom.sh

# Security: Set timezone
ENV TZ=Asia/Ho_Chi_Minh

# Security: Disable unnecessary services
RUN rm -rf /tmp/* /var/tmp/* \
    && find /var/log -type f -exec truncate -s 0 {} \;

# Security: Set proper file permissions
RUN chmod 700 /var/lib/postgresql/data || true

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD pg_isready -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres}

ENTRYPOINT ["/usr/local/bin/docker-entrypoint-custom.sh"]
CMD ["postgres"]
