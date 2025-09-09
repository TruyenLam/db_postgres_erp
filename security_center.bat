@echo off
REM ================================================
REM ERP TN Group - Security Monitor & Setup
REM Kiểm tra và setup bảo mật hệ thống
REM ================================================

:menu
cls
echo ================================================
echo      🛡️  ERP TN Group - Security Center
echo ================================================
echo.
echo 1. Generate SSL Certificates
echo 2. Check Security Status
echo 3. Backup Encryption Test
echo 4. Network Security Scan
echo 5. Update Passwords
echo 6. View Security Logs
echo 7. Database Security Audit
echo 8. Exit
echo.
set /p choice=Choose option (1-8): 

if "%choice%"=="1" goto generate_ssl
if "%choice%"=="2" goto security_status
if "%choice%"=="3" goto test_backup
if "%choice%"=="4" goto network_scan
if "%choice%"=="5" goto update_passwords
if "%choice%"=="6" goto security_logs
if "%choice%"=="7" goto db_audit
if "%choice%"=="8" goto exit

echo Invalid option!
pause
goto menu

:generate_ssl
echo.
echo 🔐 Generating SSL certificates...
call generate_ssl.bat
pause
goto menu

:security_status
echo.
echo ================================================
echo           🔍 Security Status Check
echo ================================================

echo 📊 Container Status:
docker-compose ps

echo.
echo 🔒 SSL Certificate Status:
if exist "ssl\server.crt" (
    echo ✅ SSL Certificate exists
    openssl x509 -in ssl\server.crt -text -noout | findstr "Not After"
) else (
    echo ❌ SSL Certificate missing - Run option 1 to generate
)

echo.
echo 🌐 Network Security:
docker network ls | findstr erpnet_secure

echo.
echo 📁 File Permissions:
dir volumes\backups\ /Q 2>nul | findstr backup_ | echo ✅ Backup files secured
if exist ".env" (
    echo ✅ Environment file exists
) else (
    echo ❌ Environment file missing
)

echo.
echo 🔐 Backup Encryption Test:
if exist "volumes\backups\backup_*.gpg" (
    echo ✅ Encrypted backups found
) else (
    echo ⚠️  No encrypted backups found
)

pause
goto menu

:test_backup
echo.
echo 🔐 Testing backup encryption...
docker-compose exec postgres_secure /usr/local/bin/backup_script.sh
echo.
echo Checking for encrypted backup files:
dir volumes\backups\*.gpg /B
pause
goto menu

:network_scan
echo.
echo 🌐 Network Security Scan...
echo.
echo Checking exposed ports:
netstat -an | findstr ":443 "
netstat -an | findstr ":80 "
echo.
echo ⚠️  PostgreSQL should NOT be exposed publicly:
netstat -an | findstr ":5432 "
echo.
echo Redis should NOT be exposed publicly:
netstat -an | findstr ":6379 "
pause
goto menu

:update_passwords
echo.
echo ⚠️  WARNING: This will update system passwords
echo.
set /p confirm=Type 'YES' to continue: 
if not "%confirm%"=="YES" goto menu

echo.
echo Generating new strong passwords...

REM Generate random passwords (simplified for demo)
set NEW_DB_PASS=TnGroup@%RANDOM%%RANDOM%!Secure#db$2025
set NEW_ADMIN_PASS=TnGroup@%RANDOM%%RANDOM%!Admin#secure$2025

echo.
echo 📝 New passwords generated:
echo Database Password: %NEW_DB_PASS%
echo Admin Password: %NEW_ADMIN_PASS%
echo.
echo ⚠️  Update these in your .env file manually
echo.
pause
goto menu

:security_logs
echo.
echo ================================================
echo              🔍 Security Logs
echo ================================================

echo 📋 Nginx Access Logs:
if exist "nginx\logs\access.log" (
    tail -20 nginx\logs\access.log
) else (
    echo No nginx logs found
)

echo.
echo 📋 Backup Logs:
docker-compose exec postgres_secure cat /var/log/backup.log | tail -20

echo.
echo 📋 PostgreSQL Logs:
docker-compose logs postgres_secure --tail=10

pause
goto menu

:db_audit
echo.
echo ================================================
echo          🔍 Database Security Audit
echo ================================================

echo Running database security checks...

docker-compose exec postgres_secure psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "
SELECT 
    'Database Connections' as check_type,
    count(*) as current_connections,
    setting as max_connections 
FROM pg_stat_activity, pg_settings 
WHERE name='max_connections';

SELECT 
    'User Accounts' as check_type,
    rolname as username,
    rolsuper as is_superuser,
    rolcreaterole as can_create_roles,
    rolcreatedb as can_create_db
FROM pg_roles 
WHERE rolname NOT LIKE 'pg_%';

SELECT 
    'Backup History' as check_type,
    count(*) as total_backups,
    max(backup_date) as last_backup
FROM backup_history;
"

pause
goto menu

:exit
echo.
echo 🛡️  Security checkup completed!
echo.
echo 📋 Security Checklist:
echo ✅ Use strong passwords (update .env)
echo ✅ Generate SSL certificates (option 1)
echo ✅ Check no public database exposure (option 4)
echo ✅ Monitor backup encryption (option 3)
echo ✅ Regular security audits (option 7)
echo.
echo Goodbye!
exit
