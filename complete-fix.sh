#!/bin/bash

# Complete Fix for PM2 Config and React Mounting
echo "🔧 Complete fix for PM2 and React mounting..."

# Step 1: Fix PM2 configuration
echo "⚙️ Step 1: Using CommonJS ecosystem config..."
pm2 stop all 2>/dev/null || echo "No processes to stop"
pm2 delete all 2>/dev/null || echo "No processes to delete"

# Step 2: Set environment variables correctly
echo "📝 Step 2: Setting environment variables..."
export NODE_ENV=production
export PORT=3000
export DATABASE_URL='postgresql://yitro_admin:YitroSecure2024!@localhost:5432/yitro_crm'
export JWT_SECRET='XgkpTh2CVqEKKocfu1VoFZ14UQy3lirPUL/LgHDDw1o='
export DOMAIN='https://dealhub.yitrobc.net'

# Step 3: Start with the .cjs config file
echo "🚀 Step 3: Starting PM2 with CommonJS config..."
pm2 start ecosystem.config.cjs
pm2 save

# Step 4: Wait and check status
echo "⏳ Step 4: Waiting for startup..."
sleep 10
pm2 status

# Step 5: Test connectivity
echo "🧪 Step 5: Testing application..."
echo "Local test:"
curl -I http://localhost:3000/ 2>/dev/null && echo "✅ Local responds" || echo "❌ Local not responding"

echo "External test:"
curl -s https://dealhub.yitrobc.net | head -20

# Step 6: Check logs for any remaining errors
echo "📝 Step 6: Checking recent logs..."
pm2 logs --lines 10

echo ""
echo "🌐 Test your application: https://dealhub.yitrobc.net"
echo "🔑 Login credentials: admin@yitro.com / admin123"
echo ""
echo "🔍 If React still not mounting, check browser console:"
echo "   1. Open https://dealhub.yitrobc.net in browser"
echo "   2. Press F12 for Developer Tools"
echo "   3. Check Console tab for JavaScript errors"
