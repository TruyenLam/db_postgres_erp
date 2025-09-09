# ================================================
# ERP TN Group - Quick System Test
# ================================================

Write-Host "=== ERP TN Group Quick Test ===" -ForegroundColor Green

# Test database performance
Write-Host "Testing database performance..." -ForegroundColor Yellow
docker exec erp_postgres psql -U erp_admin -d erp_tngroup -c "SELECT version();"

# Test large data insert
Write-Host "Testing large data operations..." -ForegroundColor Yellow
docker exec erp_postgres psql -U erp_admin -d erp_tngroup -c "CREATE TABLE IF NOT EXISTS perf_test (id SERIAL, data TEXT);"
docker exec erp_postgres psql -U erp_admin -d erp_tngroup -c "INSERT INTO perf_test (data) SELECT 'row_' || i FROM generate_series(1,100) i;"
docker exec erp_postgres psql -U erp_admin -d erp_tngroup -c "SELECT COUNT(*) as total_records FROM perf_test;"

Write-Host "=== Test Complete ===" -ForegroundColor Green
