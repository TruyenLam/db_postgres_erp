@echo off
REM ================================================
REM ERP TN Group - Environment Setup Script
REM Thiết lập môi trường development/production
REM ================================================

echo ================================================
echo    🚀 ERP TN Group - Environment Setup
echo ================================================
echo.

REM Kiểm tra xem .env đã tồn tại chưa
if exist ".env" (
    echo ⚠️  File .env đã tồn tại!
    echo.
    set /p overwrite=Bạn có muốn ghi đè? (y/N): 
    if /i not "%overwrite%"=="y" (
        echo Setup cancelled.
        pause
        exit /b 0
    )
)

echo 📋 Copying .env.example to .env...
copy ".env.example" ".env" >nul

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to copy .env.example
    echo Make sure .env.example exists in current directory
    pause
    exit /b 1
)

echo ✅ .env file created successfully!
echo.

echo 🔐 QUAN TRỌNG: Cần thay đổi các thông tin sau trong file .env:
echo.
echo 1. POSTGRES_PASSWORD (Database password)
echo 2. PGADMIN_DEFAULT_EMAIL (Your email)
echo 3. PGADMIN_DEFAULT_PASSWORD (Admin interface password)
echo 4. REDIS_PASSWORD (Redis password)
echo 5. BACKUP_ENCRYPTION_KEY (Backup encryption key)
echo.

set /p edit_now=Bạn có muốn mở file .env để chỉnh sửa ngay? (Y/n): 
if /i not "%edit_now%"=="n" (
    echo 📝 Opening .env file for editing...
    start notepad .env
    echo.
    echo ⏳ Vui lòng chỉnh sửa các passwords và thông tin cần thiết...
    echo 💾 Nhớ SAVE file sau khi chỉnh sửa!
    echo.
    pause
)

echo.
echo 🔍 Tiếp theo, bạn cần:
echo.
echo 1. 🔐 Generate SSL certificates:
echo    .\generate_ssl.bat
echo.
echo 2. 🛡️  Build secure containers:
echo    docker-compose build --no-cache
echo.
echo 3. 🚀 Start services:
echo    docker-compose up -d
echo.
echo 4. 🔍 Check security:
echo    .\security_center.bat
echo.

set /p continue_setup=Bạn có muốn tiếp tục với SSL certificate generation? (Y/n): 
if /i not "%continue_setup%"=="n" (
    echo.
    echo 🔐 Generating SSL certificates...
    call generate_ssl.bat
)

echo.
echo 🎉 Environment setup completed!
echo.
echo 📋 Next Steps:
echo 1. Review and update .env file with your specific settings
echo 2. Run: docker-compose up -d
echo 3. Access pgAdmin at: https://localhost/
echo 4. Run security check: .\security_center.bat
echo.

pause
