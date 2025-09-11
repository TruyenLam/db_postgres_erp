# 🔒 SSL Configuration Notes
# ================================================
# SSL hiện tại đã được DISABLE để development
# Cần enable lại cho production environment
# ================================================

## 📋 TODO: Enable SSL for Production

### 1. SSL Certificate Requirements:
- File `/ssl/server.crt` - SSL certificate
- File `/ssl/server.key` - Private key (permissions: 0600)
- File `/ssl/dhparam.pem` - Diffie-Hellman parameters

### 2. Steps to Enable SSL:

#### A. Fix SSL file permissions:
```bash
# In docker-entrypoint-custom.sh
chown postgres:postgres /ssl/server.key
chmod 600 /ssl/server.key
chmod 644 /ssl/server.crt
```

#### B. Update PostgreSQL configuration:
```bash
# In postgresql_vector.conf
ssl = on
ssl_cert_file = '/ssl/server.crt'
ssl_key_file = '/ssl/server.key'
ssl_ca_file = '/ssl/server.crt'
ssl_protocols = 'TLSv1.2,TLSv1.3'
ssl_ciphers = 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256'
```

#### C. Environment variable control:
```bash
# In .env file
ENABLE_SSL=true
```

#### D. Update docker-entrypoint-custom.sh:
```bash
# Change condition from
if [ -d "/ssl" ] && [ "${ENABLE_SSL:-false}" = "true" ]; then
# To enable SSL by default in production
```

### 3. Current SSL Status:
- ❌ SSL DISABLED (development mode)
- ✅ Password encryption: scram-sha-256
- ✅ SSL certificates present in /ssl/ directory
- ⚠️  Need to fix file permissions for production

### 4. Production Checklist:
- [ ] Generate/verify SSL certificates
- [ ] Set proper file permissions (0600 for private key)
- [ ] Update ENABLE_SSL=true in environment
- [ ] Test SSL connections
- [ ] Update nginx configuration for SSL passthrough
- [ ] Verify pgAdmin works with SSL

### 5. Current Files:
- `ssl/server.crt` - SSL certificate (exists)
- `ssl/server.key` - Private key (exists, needs permission fix)
- `ssl/dhparam.pem` - DH parameters (exists)

### 6. Security Impact:
- **Development**: OK to run without SSL
- **Production**: MUST enable SSL for security
- **Data in transit**: Currently unencrypted (local development)

### 7. Quick Enable Command (when ready):
```bash
# 1. Fix permissions
docker-compose exec postgres chmod 600 /ssl/server.key

# 2. Set environment
echo "ENABLE_SSL=true" >> .env

# 3. Rebuild and restart
docker-compose down
docker-compose build postgres
docker-compose up -d
```

## 🚨 Security Warning:
**DO NOT USE IN PRODUCTION WITHOUT SSL!**
Current configuration is only suitable for:
- Local development
- Testing environments
- Internal networks with proper firewall rules

For production deployment, SSL must be enabled to protect:
- Database connections
- Administrative access
- Data transmission
- Authentication credentials
