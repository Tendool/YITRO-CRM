#!/bin/bash

# Fix Application Crash - Missing Dependencies
echo "🔧 Fixing application crash due to missing dependencies..."

# Step 1: Stop PM2 completely
echo "⏹️ Step 1: Stopping PM2..."
pm2 stop all
pm2 delete all
pm2 kill

# Step 2: Fix missing dependencies
echo "📦 Step 2: Installing missing dependencies..."
npm install cors
npm install express
npm install @prisma/client
npm install dotenv

# Step 3: Reinstall all dependencies to be safe
echo "📦 Step 3: Reinstalling all dependencies..."
rm -rf node_modules package-lock.json
npm cache clean --force
npm install

# Step 4: Generate Prisma client
echo "🔄 Step 4: Generating Prisma client..."
npx prisma generate

# Step 5: Set environment variables
echo "📝 Step 5: Setting environment variables..."
export NODE_ENV=production
export PORT=3000
export DATABASE_URL="postgresql://yitro_admin:YitroSecure2024!@localhost:5432/yitro_crm"

# Copy production environment
cp .env.production .env

# Step 6: Try running without build first (development mode)
echo "🚀 Step 6: Starting in development mode first..."
nohup npm run dev > dev-server.log 2>&1 &
DEV_PID=$!

# Wait and test development server
echo "⏳ Waiting 10 seconds for dev server..."
sleep 10

if curl -s http://localhost:8080/ > /dev/null; then
    echo "✅ Development server works! Now building for production..."
    
    # Kill dev server
    kill $DEV_PID 2>/dev/null || pkill -f "npm run dev"
    
    # Step 7: Build application properly
    echo "🏗️ Step 7: Building application..."
    npm run build
    
    # Step 8: Start with PM2
    echo "🚀 Step 8: Starting with PM2..."
    pm2 start start.js --name "dealhub-crm" --env production
    pm2 save
    
else
    echo "❌ Development server failed. Checking logs..."
    tail -20 dev-server.log
    kill $DEV_PID 2>/dev/null || pkill -f "npm run dev"
    
    # Try direct start without build
    echo "🚀 Trying direct start without build..."
    pm2 start start.js --name "dealhub-crm"
    pm2 save
fi

# Step 9: Check status
echo "📊 Step 9: Checking final status..."
sleep 5
pm2 status

echo "🔍 Checking ports:"
netstat -tlnp | grep :3000 && echo "✅ Port 3000 active" || echo "❌ Port 3000 not active"
netstat -tlnp | grep :8080 && echo "✅ Port 8080 active" || echo "❌ Port 8080 not active"

echo "🧪 Testing connectivity:"
curl -I http://localhost:3000/ 2>/dev/null && echo "✅ Port 3000 responds" || echo "❌ Port 3000 no response"
curl -I http://localhost:8080/ 2>/dev/null && echo "✅ Port 8080 responds" || echo "❌ Port 8080 no response"

echo ""
echo "✅ Fix completed!"
echo "🌐 Test: curl https://dealhub.yitrobc.net"
echo "📊 Monitor: pm2 logs"
