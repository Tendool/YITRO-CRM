#!/bin/bash

# Check Current Application Status
echo "🔍 Checking current application status..."

echo "📊 PM2 Status:"
pm2 status

echo ""
echo "🌐 Testing HTTP endpoints:"
echo "Testing localhost:3000..."
curl -I http://localhost:3000/ 2>/dev/null && echo "✅ Local HTTP works" || echo "❌ Local HTTP failed"

echo "Testing with curl for HTML content..."
curl -s http://localhost:3000/ | head -20

echo ""
echo "📋 Checking processes:"
netstat -tlnp | grep :3000 || echo "No process on port 3000"

echo ""
echo "📁 Checking build files:"
if [ -d "dist" ]; then
    echo "✅ dist/ directory exists:"
    ls -la dist/
    if [ -d "dist/spa" ]; then
        echo "✅ Frontend build exists:"
        ls -la dist/spa/ | head -10
    else
        echo "❌ No frontend build (dist/spa)"
    fi
else
    echo "❌ No dist/ directory found"
fi

echo ""
echo "📝 PM2 Logs (last 20 lines):"
pm2 logs --lines 20 || echo "No PM2 logs available"

echo ""
echo "🔧 If app is not working, run one of these fixes:"
echo "   ./fix-vite-and-build.sh  - Fix Vite and rebuild"
echo "   ./quick-start-dev.sh     - Start in development mode"
