#!/bin/bash

# Fix Vite Issue and Rebuild Frontend
echo "🔧 Fixing Vite dependency and rebuilding frontend..."

# Step 1: Install Vite explicitly
echo "📦 Step 1: Installing Vite explicitly..."
npm install vite@^6.2.2 --save-dev

# Step 2: Install other critical build dependencies
echo "📦 Step 2: Installing build dependencies..."
npm install @vitejs/plugin-react-swc --save-dev
npm install typescript --save-dev

# Step 3: Verify Vite installation
echo "🔍 Step 3: Verifying Vite installation..."
if [ -f "./node_modules/.bin/vite" ]; then
    echo "✅ Vite found at ./node_modules/.bin/vite"
    ./node_modules/.bin/vite --version
else
    echo "❌ Vite still not found!"
    echo "📋 Checking node_modules/.bin/ contents:"
    ls -la ./node_modules/.bin/ | grep vite || echo "No vite executable found"
fi

# Step 4: Try alternative Vite installation
if [ ! -f "./node_modules/.bin/vite" ]; then
    echo "🔄 Step 4: Trying alternative Vite installation..."
    npm uninstall vite
    npm install vite@latest --save-dev
    npm install @vitejs/plugin-react-swc@latest --save-dev
fi

# Step 5: Build frontend with explicit path
echo "🏗️ Step 5: Building frontend..."
if [ -f "./node_modules/.bin/vite" ]; then
    ./node_modules/.bin/vite build
elif command -v npx > /dev/null; then
    npx vite build
else
    echo "❌ Cannot find vite, trying npm run build:client..."
    npm run build:client
fi

# Step 6: Build server
echo "🏗️ Step 6: Building server..."
npm run build:server

# Step 7: Restart PM2 to pick up new build
echo "⚡ Step 7: Restarting PM2..."
pm2 restart all

# Step 8: Verify build output
echo "📁 Step 8: Verifying build output..."
if [ -d "dist/spa" ]; then
    echo "✅ Frontend build found in dist/spa"
    ls -la dist/spa/
else
    echo "❌ Frontend build not found"
fi

if [ -d "dist/server" ]; then
    echo "✅ Server build found in dist/server"
    ls -la dist/server/
else
    echo "❌ Server build not found"
fi

# Step 9: Test application
echo "🧪 Step 9: Testing application..."
sleep 3
curl -I http://localhost:3000/ || echo "⚠️ Application test pending..."

echo ""
echo "✅ Vite fix and rebuild completed!"
echo "🌐 Test your application: https://dealhub.yitrobc.net"
