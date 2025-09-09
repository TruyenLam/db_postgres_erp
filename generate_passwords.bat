@echo off
REM ================================================
REM ERP TN Group - Password Generator
REM Tạo passwords mạnh cho hệ thống
REM ================================================

setlocal enabledelayedexpansion

echo ================================================
echo      🔐 ERP TN Group - Password Generator
echo ================================================
echo.

echo Tạo passwords mạnh cho hệ thống ERP TN Group...
echo.

REM Function to generate random password
call :generate_password DB_PASSWORD 16
call :generate_password ADMIN_PASSWORD 16
call :generate_password REDIS_PASSWORD 12
call :generate_password BACKUP_KEY 32

echo 📋 PASSWORDS ĐÃ TẠO:
echo ================================================
echo.
echo 🗄️  Database Password:
echo POSTGRES_PASSWORD=%DB_PASSWORD%
echo PGPASSWORD=%DB_PASSWORD%
echo.
echo 👤 Admin Password:
echo PGADMIN_DEFAULT_PASSWORD=%ADMIN_PASSWORD%
echo.
echo 💾 Redis Password:
echo REDIS_PASSWORD=%REDIS_PASSWORD%
echo.
echo 🔐 Backup Encryption Key:
echo BACKUP_ENCRYPTION_KEY=%BACKUP_KEY%
echo.
echo ================================================

echo.
set /p auto_update=Bạn có muốn tự động cập nhật vào file .env? (Y/n): 
if /i not "%auto_update%"=="n" (
    if exist ".env" (
        echo.
        echo 📝 Updating .env file...
        
        REM Backup original .env
        copy ".env" ".env.backup.%date:~-4,4%%date:~-10,2%%date:~-7,2%" >nul
        
        REM Update passwords in .env file
        powershell -Command "(Get-Content .env) -replace 'POSTGRES_PASSWORD=.*', 'POSTGRES_PASSWORD=%DB_PASSWORD%' | Set-Content .env"
        powershell -Command "(Get-Content .env) -replace 'PGPASSWORD=.*', 'PGPASSWORD=%DB_PASSWORD%' | Set-Content .env"
        powershell -Command "(Get-Content .env) -replace 'PGADMIN_DEFAULT_PASSWORD=.*', 'PGADMIN_DEFAULT_PASSWORD=%ADMIN_PASSWORD%' | Set-Content .env"
        powershell -Command "(Get-Content .env) -replace 'REDIS_PASSWORD=.*', 'REDIS_PASSWORD=%REDIS_PASSWORD%' | Set-Content .env"
        powershell -Command "(Get-Content .env) -replace 'BACKUP_ENCRYPTION_KEY=.*', 'BACKUP_ENCRYPTION_KEY=%BACKUP_KEY%' | Set-Content .env"
        
        echo ✅ Passwords updated in .env file
        echo 💾 Original .env backed up as .env.backup.*
    ) else (
        echo ❌ .env file not found. Run setup_environment.bat first.
    )
)

echo.
echo 🔒 BẢO MẬT QUAN TRỌNG:
echo ▶ Lưu trữ passwords này an toàn
echo ▶ Không chia sẻ qua email/chat
echo ▶ Sử dụng password manager
echo ▶ Thay đổi định kỳ
echo.

set /p save_file=Bạn có muốn lưu passwords vào file text? (y/N): 
if /i "%save_file%"=="y" (
    set filename=passwords_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.txt
    set filename=!filename: =0!
    
    echo ERP TN Group - Generated Passwords > !filename!
    echo Generated: %date% %time% >> !filename!
    echo. >> !filename!
    echo Database Password: %DB_PASSWORD% >> !filename!
    echo Admin Password: %ADMIN_PASSWORD% >> !filename!
    echo Redis Password: %REDIS_PASSWORD% >> !filename!
    echo Backup Key: %BACKUP_KEY% >> !filename!
    
    echo 💾 Passwords saved to: !filename!
    echo ⚠️  Xóa file này sau khi setup xong!
)

echo.
pause
goto :eof

:generate_password
setlocal
set length=%2
set chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*
set password=
set /a count=0

:loop
set /a "rand=%random% %% 66"
call set "char=%%chars:~%rand%,1%%"
set "password=%password%%char%"
set /a count+=1
if %count% lss %length% goto loop

endlocal & set "%1=%password%"
goto :eof
