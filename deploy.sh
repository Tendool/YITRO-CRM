#!/bin/bash

# DealHub CRM Platform - Production Deployment Script
# For deployment on dealhub.yitrobc.net

set -e

echo "🚀 Starting DealHub CRM deployment..."

# Check if we're on the server
if [ ! -f "/etc/hostname" ] || [ "$(hostname)" != "your-server-name" ]; then
    echo "⚠️  This script should be run on the production server"
fi

# Create necessary directories
echo "📁 Creating directories..."
sudo mkdir -p /var/www/dealhub
sudo mkdir -p /var/www/dealhub/data
sudo mkdir -p /var/log/dealhub

# Set ownership
sudo chown -R $USER:$USER /var/www/dealhub
sudo chown -R $USER:$USER /var/log/dealhub

# Install dependencies
echo "📦 Installing dependencies..."
npm ci --production

# Build the application
echo "🔨 Building application..."
npm run build

# Set up environment variables
echo "⚙️  Setting up environment..."
cat > .env.production << EOL
DATABASE_URL="file:/var/www/dealhub/data/production.db"
NODE_ENV=production
PORT=3000
JWT_SECRET="$(openssl rand -base64 32)"
DOMAIN="https://dealhub.yitrobc.net"
EOL

# Copy environment file
cp .env.production .env

# Set up database
echo "🗄️  Setting up database..."
npx prisma generate
npx prisma migrate deploy

# Create database directory and set permissions
sudo mkdir -p /var/www/dealhub/data
sudo chown -R $USER:$USER /var/www/dealhub/data
sudo chmod 755 /var/www/dealhub/data

# Set up PM2 ecosystem
echo "🔄 Setting up PM2..."
cat > ecosystem.config.js << EOL
module.exports = {
  apps: [
    {
      name: 'dealhub-crm',
      script: './start.js',
      instances: 1,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      log_file: '/var/log/dealhub/combined.log',
      out_file: '/var/log/dealhub/out.log',
      error_file: '/var/log/dealhub/error.log',
      time: true
    }
  ]
};
EOL

# Start or restart the application
echo "🏃 Starting application..."
if pm2 list | grep -q "dealhub-crm"; then
    pm2 restart dealhub-crm
else
    pm2 start ecosystem.config.js
fi

# Save PM2 configuration
pm2 save
pm2 startup

echo "✅ DealHub CRM deployed successfully!"
echo "🌐 Application should be available at: https://dealhub.yitrobc.net"
echo "📊 Monitor with: pm2 monit"
echo "📝 Check logs with: pm2 logs dealhub-crm"
