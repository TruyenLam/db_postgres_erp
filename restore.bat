@echo off
REM ================================================
REM ERP TN Group - Database Restore Script
REM ================================================

echo [%date% %time%] ERP TN Group - Database Restore

if "%1"=="" (
    echo Usage: restore.bat [backup_filename]
    echo.
    echo Available backups:
    dir volumes\backups\backup_*.sql /B
    echo.
    echo Example: restore.bat backup_20250909_143022.sql
    pause
    exit /b 1
)

set BACKUP_FILE=%1

if not exist "volumes\backups\%BACKUP_FILE%" (
    echo ❌ Backup file not found: %BACKUP_FILE%
    echo.
    echo Available backups:
    dir volumes\backups\backup_*.sql /B
    pause
    exit /b 1
)

echo.
echo ⚠️  WARNING: This will restore database from backup file: %BACKUP_FILE%
echo ⚠️  All current data will be replaced!
echo.
set /p CONFIRM=Are you sure? Type 'YES' to confirm: 

if not "%CONFIRM%"=="YES" (
    echo Restore cancelled.
    pause
    exit /b 0
)

echo [%date% %time%] Starting restore from: %BACKUP_FILE%

REM Restore database
docker-compose exec -T postgres psql -U erp_admin erp_tngroup < volumes\backups\%BACKUP_FILE%

if %ERRORLEVEL% EQU 0 (
    echo [%date% %time%] ✅ Restore completed successfully from: %BACKUP_FILE%
) else (
    echo [%date% %time%] ❌ Restore failed!
)

echo.
echo Press any key to continue...
pause >nul
