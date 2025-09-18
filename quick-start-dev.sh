#!/bin/bash

# Quick Fix: Run in Development Mode (No Build Required)
echo "🚀 Quick fix: Starting in development mode..."

# Stop PM2
echo "⏹️ Stopping PM2..."
pm2 stop all

# Set environment for development with PostgreSQL
echo "📝 Setting development environment..."
export NODE_ENV=development
export DATABASE_URL="postgresql://yitro_admin:YitroSecure2024!@localhost:5432/yitro_crm"

# Start development server in background
echo "🚀 Starting development server..."
nohup npm run dev > dev.log 2>&1 &

# Wait for server to start
echo "⏳ Waiting for server to start..."
sleep 10

# Check if dev server is running
echo "🔍 Checking development server..."
if curl -s http://localhost:8080/ > /dev/null; then
    echo "✅ Development server is running on port 8080"
    echo "🌐 Access your app at: http://216.48.190.58:8080"
    echo "🔑 Test accounts:"
    echo "   Admin: admin@yitro.com / admin123"
    echo "   User: user@yitro.com / user123"
else
    echo "❌ Development server failed to start"
    echo "📋 Check logs: tail -f dev.log"
fi

echo ""
echo "📋 Management commands:"
echo "   tail -f dev.log  - View development logs"
echo "   pkill -f 'npm run dev'  - Stop development server"
echo "   pm2 start ecosystem.config.js  - Switch back to production"
