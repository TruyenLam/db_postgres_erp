@echo off
REM ================================================
REM ERP TN Group - Backup Commands
REM ================================================

echo ================================================
echo         ERP TN Group - Backup Commands
echo ================================================
echo.

:menu
echo 1. Test Manual Backup (run backup script now)
echo 2. View Backup Logs
echo 3. List All Backups
echo 4. Check Cron Status
echo 5. View Container Logs
echo 6. Force Backup (exec into container)
echo 7. Exit
echo.
set /p choice=Choose option (1-7): 

if "%choice%"=="1" goto test_backup
if "%choice%"=="2" goto view_logs
if "%choice%"=="3" goto list_backups
if "%choice%"=="4" goto cron_status
if "%choice%"=="5" goto container_logs
if "%choice%"=="6" goto force_backup
if "%choice%"=="7" goto exit

echo Invalid option!
pause
goto menu

:test_backup
echo.
echo Testing manual backup...
docker-compose exec postgres /usr/local/bin/backup_script.sh
echo.
pause
goto menu

:view_logs
echo.
echo ================================================
echo              Backup Logs
echo ================================================
docker-compose exec postgres cat /var/log/backup.log
echo.
pause
goto menu

:list_backups
echo.
echo ================================================
echo              Available Backups
echo ================================================
dir volumes\backups\backup_*.* /O-D
echo.
echo Container backup files:
docker-compose exec postgres ls -la /backups/backup_*
echo.
pause
goto menu

:cron_status
echo.
echo ================================================
echo              Cron Status
echo ================================================
docker-compose exec postgres service cron status
echo.
echo Cron jobs:
docker-compose exec postgres crontab -l -u postgres
echo.
pause
goto menu

:container_logs
echo.
echo ================================================
echo              Container Logs
echo ================================================
docker-compose logs postgres
echo.
pause
goto menu

:force_backup
echo.
echo Executing backup directly in container...
docker-compose exec postgres bash -c "su - postgres -c '/usr/local/bin/backup_script.sh'"
echo.
pause
goto menu

:exit
echo Goodbye!
exit
