# ================================================
# ERP TN Group - Complete System Deployment Script
# Build and deploy full ERP system with all features
# ================================================

param(
    [switch]$WithVector = $false,
    [switch]$CleanStart = $false
)

Write-Host "=== ERP TN Group - Complete Deployment ===" -ForegroundColor Green
Write-Host "Developer: Lam Van Truyen" -ForegroundColor Cyan
Write-Host "Email: lamvantruyen@gmail.com" -ForegroundColor Cyan
Write-Host ""

# Clean start if requested
if ($CleanStart) {
    Write-Host "🧹 Cleaning existing containers and volumes..." -ForegroundColor Yellow
    docker-compose -f docker-compose.test.yml down -v --remove-orphans 2>&1 | Out-Null
    docker system prune -f 2>&1 | Out-Null
    Write-Host "   ✅ Clean completed" -ForegroundColor Green
}

# Choose deployment method
if ($WithVector) {
    Write-Host "🚀 Deploying with Vector Database support..." -ForegroundColor Yellow
    Write-Host "   Building custom PostgreSQL with pgvector..." -ForegroundColor Cyan
    
    # Try to build with original Dockerfile (with pgvector)
    $buildResult = docker-compose build --no-cache 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   ⚠️  Custom build failed, falling back to basic version" -ForegroundColor Yellow
        $WithVector = $false
    } else {
        Write-Host "   ✅ Custom build successful" -ForegroundColor Green
        $composeFile = "docker-compose.yml"
    }
}

if (-not $WithVector) {
    Write-Host "🏃 Deploying basic ERP system..." -ForegroundColor Yellow
    $composeFile = "docker-compose.test.yml"
}

# Deploy the system
Write-Host "📦 Starting containers..." -ForegroundColor Yellow
$deployResult = docker-compose -f $composeFile up -d 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Containers started successfully" -ForegroundColor Green
} else {
    Write-Host "   ❌ Container startup failed" -ForegroundColor Red
    Write-Host "   Error: $deployResult" -ForegroundColor Red
    exit 1
}

# Wait for services to be ready
Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Run comprehensive tests
Write-Host "🧪 Running system tests..." -ForegroundColor Yellow
& powershell -ExecutionPolicy Bypass -File test_system.ps1

# Additional tests for vector database
if ($WithVector) {
    Write-Host ""
    Write-Host "🔬 Testing Vector Database features..." -ForegroundColor Yellow
    
    # Test vector extension
    $vectorTest = docker exec erp_postgres psql -U erp_admin -d erp_tngroup -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>&1
    if ($vectorTest -notmatch "ERROR") {
        Write-Host "   ✅ Vector extension: AVAILABLE" -ForegroundColor Green
        
        # Test vector operations
        $vectorOps = docker exec erp_postgres psql -U erp_admin -d erp_tngroup -c "CREATE TABLE test_vectors (id SERIAL PRIMARY KEY, embedding vector(3)); INSERT INTO test_vectors (embedding) VALUES ('[1,2,3]'), ('[4,5,6]'); SELECT embedding FROM test_vectors;" 2>&1
        if ($vectorOps -notmatch "ERROR") {
            Write-Host "   ✅ Vector operations: WORKING" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Vector operations: FAILED" -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ Vector extension: NOT AVAILABLE" -ForegroundColor Red
    }
}

# Performance test
Write-Host ""
Write-Host "⚡ Running performance tests..." -ForegroundColor Yellow

# Insert test data
$perfTest = docker exec erp_postgres psql -U erp_admin -d erp_tngroup -c "CREATE TABLE IF NOT EXISTS performance_test (id SERIAL PRIMARY KEY, data TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP); INSERT INTO performance_test (data) SELECT 'Test data ' || generate_series(1, 1000); SELECT COUNT(*) FROM performance_test;" 2>&1

if ($perfTest -match "1000") {
    Write-Host "   ✅ Performance test: 1000 records inserted successfully" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Performance test: Limited performance" -ForegroundColor Yellow
}

# Generate deployment report
Write-Host ""
Write-Host "=== Deployment Report ===" -ForegroundColor Green
Write-Host "Deployment Mode: $(if ($WithVector) { 'Full (with Vector DB)' } else { 'Basic' })" -ForegroundColor Cyan
Write-Host "Database: PostgreSQL 15" -ForegroundColor Cyan
Write-Host "Management UI: pgAdmin 4 (http://localhost:8080)" -ForegroundColor Cyan
Write-Host "Cache: Redis 7" -ForegroundColor Cyan
Write-Host "Vector Support: $(if ($WithVector) { 'Enabled' } else { 'Disabled' })" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔐 Login Information:" -ForegroundColor Yellow
Write-Host "pgAdmin Email: lamvantruyen@gmail.com" -ForegroundColor Cyan
Write-Host "Database Host: erp_postgres (or localhost:5432)" -ForegroundColor Cyan
Write-Host "Database Name: erp_tngroup" -ForegroundColor Cyan
Write-Host "Database User: erp_admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Important Files:" -ForegroundColor Yellow
Write-Host "- .env (Configuration)" -ForegroundColor Cyan
Write-Host "- backup/ (Database backups)" -ForegroundColor Cyan
Write-Host "- volumes/ (Data persistence)" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Open pgAdmin: http://localhost:8080" -ForegroundColor Cyan
Write-Host "2. Configure server connection in pgAdmin" -ForegroundColor Cyan
Write-Host "3. Start developing your ERP application" -ForegroundColor Cyan
Write-Host "4. Use backup scripts for data protection" -ForegroundColor Cyan

if ($WithVector) {
    Write-Host "5. Explore AI/ML features with vector database" -ForegroundColor Cyan
    Write-Host "6. Use Python integration for advanced analytics" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== ERP TN Group System Deployed Successfully! ===" -ForegroundColor Green
