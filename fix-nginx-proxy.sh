#!/bin/bash

# Fix Nginx Proxy 502 Bad Gateway Issue
echo "🔧 Diagnosing and fixing nginx 502 Bad Gateway..."

# Step 1: Check what's running on ports
echo "📊 Step 1: Checking running processes and ports..."
echo "Processes on port 3000:"
netstat -tlnp | grep :3000 || echo "❌ Nothing on port 3000"

echo "Processes on port 8080:"
netstat -tlnp | grep :8080 || echo "❌ Nothing on port 8080"

echo "All Node processes:"
ps aux | grep node || echo "❌ No Node processes"

# Step 2: Check PM2 status
echo ""
echo "📊 Step 2: PM2 Status:"
pm2 status

# Step 3: Check PM2 logs for errors
echo ""
echo "📝 Step 3: PM2 Logs (last 20 lines):"
pm2 logs --lines 20 || echo "No PM2 logs"

# Step 4: Test local connectivity
echo ""
echo "🧪 Step 4: Testing local connectivity..."
curl -I http://localhost:3000/ 2>/dev/null && echo "✅ Port 3000 responds" || echo "❌ Port 3000 not responding"
curl -I http://localhost:8080/ 2>/dev/null && echo "✅ Port 8080 responds" || echo "❌ Port 8080 not responding"

# Step 5: Check nginx configuration
echo ""
echo "🔍 Step 5: Checking nginx configuration..."
if [ -f "/etc/nginx/sites-available/dealhub.yitrobc.net" ]; then
    echo "✅ Nginx config found:"
    grep -E "(listen|server_name|proxy_pass)" /etc/nginx/sites-available/dealhub.yitrobc.net
elif [ -f "/etc/nginx/nginx.conf" ]; then
    echo "✅ Checking main nginx config:"
    grep -A 10 -B 5 "dealhub.yitrobc.net" /etc/nginx/nginx.conf || echo "No dealhub config found"
else
    echo "❌ Nginx config not found"
fi

# Step 6: Restart application on correct port
echo ""
echo "⚡ Step 6: Restarting application..."
pm2 stop all
pm2 delete all

# Start with explicit port configuration
export NODE_ENV=production
export PORT=3000
export DATABASE_URL="postgresql://yitro_admin:YitroSecure2024!@localhost:5432/yitro_crm"

pm2 start ecosystem.config.js
pm2 save

# Step 7: Verify application is running
echo ""
echo "🔍 Step 7: Verifying application..."
sleep 5
netstat -tlnp | grep :3000 && echo "✅ Application on port 3000" || echo "❌ Application not on port 3000"

# Step 8: Test again
echo ""
echo "🧪 Step 8: Testing after restart..."
curl -I http://localhost:3000/ && echo "✅ Local test passed" || echo "❌ Local test failed"

echo ""
echo "🔧 If still failing, check nginx config to ensure it proxies to port 3000"
echo "   sudo nano /etc/nginx/sites-available/dealhub.yitrobc.net"
echo "   Look for: proxy_pass http://localhost:3000;"
