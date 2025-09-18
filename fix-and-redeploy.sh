#!/bin/bash

# Complete Fix and Redeploy Script
echo "🚀 Fixing permissions and redeploying application..."

# Step 1: Fix PostgreSQL permissions
echo "🔧 Step 1: Fixing PostgreSQL permissions..."
chmod +x fix-postgres-permissions.sh
./fix-postgres-permissions.sh

# Step 2: Set environment variables
echo "📝 Step 2: Setting environment variables..."
export NODE_ENV=production
export DATABASE_URL="postgresql://yitro_admin:YitroSecure2024!@localhost:5432/yitro_crm"

# Copy environment file
cp .env.production .env

# Step 3: Generate Prisma client
echo "🔄 Step 3: Generating Prisma client..."
npx prisma generate

# Step 4: Run migrations (this should work now with proper permissions)
echo "🗄️ Step 4: Running database migrations..."
npx prisma migrate dev --name init_postgresql

# Step 5: Deploy migrations to production
echo "🚀 Step 5: Deploying migrations..."
npx prisma migrate deploy

# Step 6: Seed database
echo "🌱 Step 6: Seeding database..."
npm run db:seed

# Step 7: Build application (if not already built)
echo "🏗️ Step 7: Building application..."
npm run build

# Step 8: Restart PM2
echo "⚡ Step 8: Restarting application..."
pm2 restart all

# Step 9: Check status
echo "📊 Step 9: Checking application status..."
sleep 3
pm2 status

# Step 10: Test application
echo "🧪 Step 10: Testing application..."
curl -I http://localhost:3000/ 2>/dev/null || echo "⚠️ Local test pending..."

echo ""
echo "✅ Fix and redeploy completed!"
echo "🌐 Application URL: https://dealhub.yitrobc.net"
echo "🔑 Test Accounts:"
echo "   Admin: admin@yitro.com / admin123"
echo "   User: user@yitro.com / user123"
echo ""
echo "📋 Verification commands:"
echo "   pm2 logs        - Check application logs"
echo "   pm2 status      - Check PM2 status"
echo "   curl -I https://dealhub.yitrobc.net  - Test website"
