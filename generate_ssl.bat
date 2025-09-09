@echo off
RE# Tạo certificate signing request
openssl req -new -key server.key -out server.csr -subj "/C=VN/ST=HoChiMinh/L=HoChiMinh/O=TN Group/OU=IT Department/CN=erp.tngroup.com/emailAddress=lamvantruyen@gmail.com"================================================
REM ERP TN Group - SSL Certificate Generator
REM Tạo self-signed certificates cho HTTPS
REM ================================================

echo 🔐 Generating SSL certificates for ERP TN Group...

cd ssl

REM Tạo private key
openssl genrsa -out server.key 2048

REM Tạo certificate signing request
openssl req -new -key server.key -out server.csr -subj "/C=VN/ST=HoChiMinh/L=HoChiMinh/O=TN Group/OU=IT Department/CN=erp.tngroup.com/emailAddress=admin@tngroup.com"

REM Tạo self-signed certificate (valid 365 days)
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

REM Tạo DH parameters (for better security)
openssl dhparam -out dhparam.pem 2048

REM Set proper permissions (Windows)
icacls server.key /grant:r "%USERNAME%":(R)
icacls server.crt /grant:r "%USERNAME%":(R)

echo ✅ SSL certificates generated successfully!
echo 📁 Location: ssl/
echo 📄 Files created:
echo    - server.key (Private key)
echo    - server.crt (Certificate)  
echo    - server.csr (Certificate request)
echo    - dhparam.pem (DH parameters)
echo.
echo ⚠️  For production, replace with certificates from a trusted CA
echo.

cd ..
pause
