#!/bin/bash

# Application Deployment Script for PostgreSQL
# Run this AFTER PostgreSQL is installed and configured
# Usage: bash deploy-app.sh

echo "🚀 Deploying application with PostgreSQL..."

# Set environment variables
export NODE_ENV=production
export DATABASE_URL="postgresql://yitro_admin:YitroSecure2024!@localhost:5432/yitro_crm"

# Copy production environment file
echo "📝 Setting up environment variables..."
cp .env.production .env

# Install/update dependencies
echo "📦 Installing dependencies..."
npm install

# Generate Prisma client for PostgreSQL
echo "🔄 Generating Prisma client for PostgreSQL..."
npx prisma generate

# Run database migrations
echo "🗄️ Running database migrations..."
npx prisma migrate deploy

# Seed database with initial data
echo "🌱 Seeding database with test accounts..."
npm run db:seed

# Build the application
echo "🏗️ Building application..."
npm run build

# Stop existing PM2 processes
echo "⏹️ Stopping existing processes..."
pm2 stop all || echo "No processes to stop"

# Start application with PM2
echo "🚀 Starting application with PM2..."
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Show PM2 status
echo "📊 PM2 Status:"
pm2 status

echo ""
echo "✅ Deployment completed successfully!"
echo "🌐 Application URL: https://dealhub.yitrobc.net"
echo "🔑 Test Accounts:"
echo "   Admin: admin@yitro.com / admin123"
echo "   User: user@yitro.com / user123"
echo ""
echo "📊 Check logs with: pm2 logs"
echo "🔄 Restart with: pm2 restart all"
