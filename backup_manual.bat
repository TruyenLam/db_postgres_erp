@echo off
REM ================================================
REM ERP TN Group - Manual Backup Script
REM ================================================

echo [%date% %time%] Starting manual backup...

REM Tạo backup với timestamp
set BACKUP_DATE=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set BACKUP_DATE=%BACKUP_DATE: =0%

echo Creating backup: backup_manual_%BACKUP_DATE%.sql

REM Chạy pg_dump thông qua Docker
docker-compose exec -T postgres pg_dump -U erp_admin erp_tngroup > volumes\backups\backup_manual_%BACKUP_DATE%.sql

if %ERRORLEVEL% EQU 0 (
    echo [%date% %time%] ✅ Backup completed successfully: backup_manual_%BACKUP_DATE%.sql
    
    REM Hiển thị kích thước file backup
    for %%A in (volumes\backups\backup_manual_%BACKUP_DATE%.sql) do echo File size: %%~zA bytes
    
    REM Liệt kê các file backup gần nhất
    echo.
    echo Recent backups:
    dir volumes\backups\backup_*.sql /O-D /B | head -10
) else (
    echo [%date% %time%] ❌ Backup failed!
)

echo.
echo Press any key to continue...
pause >nul
