# ================================================
# ERP TN Group - Test All Features Script
# Testing script for all ERP system components
# ================================================

Write-Host "=== ERP TN Group System Test ===" -ForegroundColor Green
Write-Host "Developer: Lam Van Truyen" -ForegroundColor Cyan
Write-Host "Email: lamvantruyen@gmail.com" -ForegroundColor Cyan
Write-Host ""

# Test 1: Database Connection
Write-Host "1. Testing Database Connection..." -ForegroundColor Yellow
$dbTest = docker exec erp_postgres psql -U erp_admin -d erp_tngroup -c "\l" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Database connection: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "   ❌ Database connection: FAILED" -ForegroundColor Red
    Write-Host "   Error: $dbTest" -ForegroundColor Red
}

# Test 2: Database Query
Write-Host "2. Testing Database Query..." -ForegroundColor Yellow
$queryTest = docker exec erp_postgres psql -U erp_admin -d erp_tngroup -c "SELECT COUNT(*) FROM test_erp;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Database query: SUCCESS" -ForegroundColor Green
    Write-Host "   Result: $queryTest" -ForegroundColor Cyan
} else {
    Write-Host "   ❌ Database query: FAILED" -ForegroundColor Red
}

# Test 3: Backup Creation
Write-Host "3. Testing Backup Creation..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "backup/test_backup_$timestamp.sql"
docker exec erp_postgres pg_dump -U erp_admin -d erp_tngroup > $backupFile 2>&1
if (Test-Path $backupFile) {
    $fileSize = (Get-Item $backupFile).Length
    Write-Host "   ✅ Backup creation: SUCCESS" -ForegroundColor Green
    Write-Host "   File: $backupFile ($fileSize bytes)" -ForegroundColor Cyan
} else {
    Write-Host "   ❌ Backup creation: FAILED" -ForegroundColor Red
}

# Test 4: Container Health
Write-Host "4. Testing Container Health..." -ForegroundColor Yellow
$containers = @("erp_postgres", "erp_pgadmin", "erp_redis")
foreach ($container in $containers) {
    $status = docker inspect --format="{{.State.Health.Status}}" $container 2>&1
    if ($status -eq "healthy" -or $status -eq "null") {
        Write-Host "   ✅ $container : HEALTHY" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  $container : $status" -ForegroundColor Yellow
    }
}

# Test 5: Network Connectivity
Write-Host "5. Testing Network Connectivity..." -ForegroundColor Yellow
$pgadminTest = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 10 2>&1
if ($pgadminTest.StatusCode -eq 200) {
    Write-Host "   ✅ pgAdmin web interface: ACCESSIBLE" -ForegroundColor Green
} else {
    Write-Host "   ❌ pgAdmin web interface: NOT ACCESSIBLE" -ForegroundColor Red
}

# Test 6: Volume Persistence
Write-Host "6. Testing Volume Persistence..." -ForegroundColor Yellow
$volumes = docker volume ls --filter name=db_postgresql --format "{{.Name}}" 2>&1
if ($volumes -match "postgres_data") {
    Write-Host "   ✅ PostgreSQL data volume: EXISTS" -ForegroundColor Green
} else {
    Write-Host "   ❌ PostgreSQL data volume: MISSING" -ForegroundColor Red
}

# Test 7: Log Access
Write-Host "7. Testing Log Access..." -ForegroundColor Yellow
$logs = docker logs erp_postgres --tail 5 2>&1
if ($logs -match "database system is ready") {
    Write-Host "   ✅ PostgreSQL logs: ACCESSIBLE" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  PostgreSQL logs: Check manually" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "=== Test Summary ===" -ForegroundColor Green
Write-Host "Database: PostgreSQL 15"
Write-Host "Management: pgAdmin 4 (http://localhost:8080)"
Write-Host "Cache: Redis 7"
Write-Host "Backup: Available in ./backup/"
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Access pgAdmin at http://localhost:8080"
Write-Host "2. Login with: lamvantruyen@gmail.com"
Write-Host "3. Add server connection:"
Write-Host "   - Host: erp_postgres"
Write-Host "   - Port: 5432"
Write-Host "   - Database: erp_tngroup"
Write-Host "   - Username: erp_admin"
Write-Host "   - Password: [from .env file]"
Write-Host ""
Write-Host "=== ERP TN Group System Ready! ===" -ForegroundColor Green
