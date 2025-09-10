# ================================================
# ERP TN Group - Git Release Script  
# Tạo tags và releases mới
# ================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$version,
    [string]$message = "🎉 New release"
)

Write-Host "🏷️ Git Release Script - ERP TN Group" -ForegroundColor Green
Write-Host "Creating release: v$version" -ForegroundColor Cyan
Write-Host ""

# Create and push tag
Write-Host "🏷️ Creating tag v$version..." -ForegroundColor Yellow
git tag -a "v$version" -m "$message - v$version

🏢 ERP TN Group PostgreSQL System
👤 Developer: Lam Van Truyen
📧 Email: lamvantruyen@gmail.com
📅 Release Date: $(Get-Date -Format 'MMMM dd, yyyy')"

Write-Host "🌐 Pushing tag to GitHub..." -ForegroundColor Yellow  
git push origin "v$version"

Write-Host ""
Write-Host "✅ Release v$version created successfully!" -ForegroundColor Green
Write-Host "🌐 Repository: https://github.com/TruyenLam/db_postgres_erp.git" -ForegroundColor Cyan
Write-Host "🏷️ Tag: v$version" -ForegroundColor Cyan
Write-Host ""

# Show all tags
Write-Host "📋 All releases:" -ForegroundColor Cyan
git tag -l
