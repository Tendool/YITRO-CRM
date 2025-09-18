@echo off
echo Starting Yitro CRM Development Environment...
echo.
echo Checking prerequisites...

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if npm is available
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: npm is not available
    pause
    exit /b 1
)

echo Node.js and npm are available ✓
echo.

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo Installing dependencies...
    npm install
    if %errorlevel% neq 0 (
        echo Error: Failed to install dependencies
        pause
        exit /b 1
    )
    echo Dependencies installed ✓
    echo.
)

REM Set environment variables for Windows
set NODE_ENV=development
set PORT=8080
set API_PORT=3001
set DATABASE_URL=file:./dev.db
set JWT_SECRET=dev-secret-key-for-testing

echo Starting development servers...
echo Frontend: http://localhost:8080
echo API: http://localhost:3001
echo.
echo Alternative: You can also use "npm start dev" from now on
echo.
echo Test accounts:
echo   Admin: admin@yitro.com / admin123
echo   User: user@yitro.com / admin123
echo.
echo Press Ctrl+C to stop both servers
echo.

REM Start both servers concurrently
npm run dev:full