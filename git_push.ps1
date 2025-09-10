# ================================================
# ERP TN Group - Git Push Script
# Quick script để update repository
# ================================================

param(
    [string]$message = "📝 Update ERP TN Group system"
)

Write-Host "🚀 Git Push Script - ERP TN Group" -ForegroundColor Green
Write-Host "Developer: Lam Van Truyen" -ForegroundColor Cyan
Write-Host ""

# Check git status
Write-Host "🔍 Checking git status..." -ForegroundColor Yellow
git status

# Add all changes
Write-Host "📦 Adding changes..." -ForegroundColor Yellow
git add .

# Commit with provided message
Write-Host "💾 Committing changes..." -ForegroundColor Yellow
git commit -m $message

# Push to GitHub
Write-Host "🌐 Pushing to GitHub..." -ForegroundColor Yellow
git push origin main

Write-Host ""
Write-Host "✅ Successfully pushed to: https://github.com/TruyenLam/db_postgres_erp.git" -ForegroundColor Green
Write-Host ""

# Show recent commits
Write-Host "📝 Recent commits:" -ForegroundColor Cyan
git log --oneline -5
