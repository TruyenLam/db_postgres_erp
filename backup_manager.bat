@echo off
REM ================================================
REM ERP TN Group - Backup Management Script
REM ================================================

:menu
cls
echo ================================================
echo         ERP TN Group - Backup Management
echo ================================================
echo.
echo 1. Manual Backup
echo 2. List All Backups
echo 3. Restore Database
echo 4. Cleanup Old Backups (older than 30 days)
echo 5. View Backup Status
echo 6. Exit
echo.
set /p choice=Choose option (1-6): 

if "%choice%"=="1" goto manual_backup
if "%choice%"=="2" goto list_backups
if "%choice%"=="3" goto restore_menu
if "%choice%"=="4" goto cleanup
if "%choice%"=="5" goto status
if "%choice%"=="6" goto exit

echo Invalid option!
pause
goto menu

:manual_backup
echo.
echo Starting manual backup...
call backup_manual.bat
pause
goto menu

:list_backups
echo.
echo ================================================
echo              Available Backups
echo ================================================
dir volumes\backups\backup_*.sql /O-D
echo.
pause
goto menu

:restore_menu
echo.
echo Available backups:
dir volumes\backups\backup_*.sql /B
echo.
set /p backup_file=Enter backup filename: 
if not "%backup_file%"=="" call restore.bat %backup_file%
pause
goto menu

:cleanup
echo.
echo Cleaning up backups older than 30 days...
forfiles /p volumes\backups /s /m backup_*.sql /d -30 /c "cmd /c echo Deleting @file && del @path"
echo Cleanup completed.
pause
goto menu

:status
echo.
echo ================================================
echo              Backup Service Status
echo ================================================
docker-compose ps postgres-backup
echo.
echo Recent backup logs:
docker-compose logs --tail=20 postgres-backup
echo.
pause
goto menu

:exit
echo Goodbye!
exit
