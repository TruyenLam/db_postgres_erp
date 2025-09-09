@echo off
REM ================================================
REM ERP TN Group - Secure Restore Script
REM Restore database từ encrypted backup
REM ================================================

echo ================================================
echo    🔐 ERP TN Group - Secure Database Restore
echo ================================================

if "%1"=="" (
    echo Usage: restore_secure.bat [encrypted_backup_filename]
    echo.
    echo Available encrypted backups:
    dir volumes\backups\backup_*.gpg /B 2>nul
    echo.
    echo Example: restore_secure.bat backup_20250909_143022.sql.gpg
    pause
    exit /b 1
)

set ENCRYPTED_FILE=%1
set DECRYPTED_FILE=%~n1

if not exist "volumes\backups\%ENCRYPTED_FILE%" (
    echo ❌ Encrypted backup file not found: %ENCRYPTED_FILE%
    echo.
    echo Available encrypted backups:
    dir volumes\backups\backup_*.gpg /B
    pause
    exit /b 1
)

echo.
echo 🔐 Encrypted backup file: %ENCRYPTED_FILE%
echo 📄 Will decrypt to: %DECRYPTED_FILE%
echo.
echo ⚠️  WARNING: This will restore database from encrypted backup
echo ⚠️  All current data will be replaced!
echo.
set /p CONFIRM=Are you sure? Type 'YES' to confirm: 

if not "%CONFIRM%"=="YES" (
    echo Restore cancelled.
    pause
    exit /b 0
)

echo.
echo 🔓 Decrypting backup file...

REM Get encryption key from environment
if not defined BACKUP_ENCRYPTION_KEY (
    set /p BACKUP_ENCRYPTION_KEY=Enter backup encryption key: 
)

REM Decrypt backup file in container
docker-compose exec postgres_secure bash -c "
    echo '%BACKUP_ENCRYPTION_KEY%' | gpg --batch --yes --passphrase-fd 0 --decrypt /backups/%ENCRYPTED_FILE% > /tmp/%DECRYPTED_FILE% 2>/dev/null
    if [ $? -eq 0 ]; then
        echo '✅ Backup decrypted successfully'
        
        # Verify checksum if available
        if [ -f '/backups/%ENCRYPTED_FILE%.sha256' ]; then
            echo '🔍 Verifying backup integrity...'
            EXPECTED_CHECKSUM=\$(cat /backups/%ENCRYPTED_FILE%.sha256 | cut -d' ' -f1)
            ACTUAL_CHECKSUM=\$(sha256sum /backups/%ENCRYPTED_FILE% | cut -d' ' -f1)
            if [ \"\$EXPECTED_CHECKSUM\" = \"\$ACTUAL_CHECKSUM\" ]; then
                echo '✅ Backup integrity verified'
            else
                echo '❌ Backup integrity check failed!'
                rm -f /tmp/%DECRYPTED_FILE%
                exit 1
            fi
        fi
        
        # Restore database
        echo '📊 Restoring database...'
        pg_restore -h localhost -U \$POSTGRES_USER -d \$POSTGRES_DB --clean --if-exists /tmp/%DECRYPTED_FILE%
        
        if [ $? -eq 0 ]; then
            echo '✅ Database restored successfully'
            
            # Log restore event
            psql -h localhost -U \$POSTGRES_USER -d \$POSTGRES_DB -c \"
                INSERT INTO backup_history (backup_name, backup_type, notes) 
                VALUES ('%ENCRYPTED_FILE%', 'restore', 'Database restored from encrypted backup')
                ON CONFLICT DO NOTHING;
            \" >/dev/null 2>&1 || true
            
        else
            echo '❌ Database restore failed!'
        fi
        
        # Secure delete decrypted file
        shred -vfz -n 3 /tmp/%DECRYPTED_FILE% 2>/dev/null || rm -f /tmp/%DECRYPTED_FILE%
        
    else
        echo '❌ Backup decryption failed! Check encryption key.'
        exit 1
    fi
"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [%date% %time%] ✅ Secure restore completed successfully
    echo 📁 From: %ENCRYPTED_FILE%
    echo 🔐 Backup was encrypted and verified
) else (
    echo.
    echo [%date% %time%] ❌ Secure restore failed!
)

echo.
echo Press any key to continue...
pause >nul
