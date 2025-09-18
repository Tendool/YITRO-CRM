# Yitro CRM Development Environment Startup Script
# PowerShell version for Windows

Write-Host "Starting Yitro CRM Development Environment..." -ForegroundColor Green
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

try {
    $nodeVersion = node --version
    Write-Host "Node.js version: $nodeVersion ✓" -ForegroundColor Green
} catch {
    Write-Host "Error: Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

try {
    $npmVersion = npm --version
    Write-Host "npm version: $npmVersion ✓" -ForegroundColor Green
} catch {
    Write-Host "Error: npm is not available" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Install dependencies if needed
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to install dependencies" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "Dependencies installed ✓" -ForegroundColor Green
    Write-Host ""
}

# Set environment variables
$env:NODE_ENV = "development"
$env:PORT = "8080"
$env:API_PORT = "3001"
$env:DATABASE_URL = "file:./dev.db"
$env:JWT_SECRET = "dev-secret-key-for-testing"

Write-Host "Development Environment Configuration:" -ForegroundColor Cyan
Write-Host "  Frontend: http://localhost:8080" -ForegroundColor White
Write-Host "  API: http://localhost:3001" -ForegroundColor White
Write-Host "  Database: SQLite (./dev.db)" -ForegroundColor White
Write-Host ""
Write-Host "💡 Alternative: You can also use 'npm start dev' from now on" -ForegroundColor Yellow
Write-Host ""
Write-Host "Test accounts:" -ForegroundColor Cyan
Write-Host "  Admin: admin@yitro.com / admin123" -ForegroundColor White
Write-Host "  User: user@yitro.com / admin123" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop both servers" -ForegroundColor Yellow
Write-Host ""

# Start both servers
npm run dev:full