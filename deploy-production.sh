#!/bin/bash

# Production Deployment Script for dealhub.yitrobc.net
# This script deploys the CRM application without Docker

set -e

echo "🚀 Starting production deployment to dealhub.yitrobc.net"
echo "======================================================="

# Configuration
APP_DIR="/var/www/dealhub-crm"
BACKUP_DIR="/var/backups/dealhub-crm"
SERVICE_NAME="dealhub-crm"

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "❌ Please run this script as root (use sudo)"
        exit 1
    fi
}

# Function to install Node.js if not present
install_nodejs() {
    if ! command -v node &> /dev/null; then
        echo "📦 Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        apt-get install -y nodejs
    else
        echo "✅ Node.js is already installed"
    fi
}

# Function to install PM2 if not present
install_pm2() {
    if ! command -v pm2 &> /dev/null; then
        echo "📦 Installing PM2 process manager..."
        npm install -g pm2
    else
        echo "✅ PM2 is already installed"
    fi
}

# Function to create application directory
setup_directories() {
    echo "📁 Setting up directories..."
    mkdir -p $APP_DIR
    mkdir -p $BACKUP_DIR
    mkdir -p /var/log/dealhub-crm
}

# Function to backup existing installation
backup_existing() {
    if [ -d "$APP_DIR" ] && [ "$(ls -A $APP_DIR)" ]; then
        echo "💾 Backing up existing installation..."
        tar -czf "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz" -C $APP_DIR .
    fi
}

# Main deployment function
deploy_app() {
    echo "🔧 Deploying application..."
    
    # Copy application files
    cp -r ./* $APP_DIR/
    cd $APP_DIR
    
    # Install dependencies
    echo "📦 Installing dependencies..."
    npm install --production
    
    # Generate Prisma client
    echo "🔧 Generating Prisma client..."
    npx prisma generate
    
    # Run database migrations
    echo "🗄️ Running database migrations..."
    npx prisma migrate deploy
    
    # Build the application
    echo "🏗️ Building application..."
    npm run build
    
    # Set proper permissions
    chown -R www-data:www-data $APP_DIR
    chmod -R 755 $APP_DIR
}

# Function to setup PM2 ecosystem
setup_pm2() {
    echo "⚙️ Setting up PM2 configuration..."
    
    cat > $APP_DIR/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'dealhub-crm',
    script: './start.js',
    cwd: '/var/www/dealhub-crm',
    instances: 1,
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    log_file: '/var/log/dealhub-crm/combined.log',
    out_file: '/var/log/dealhub-crm/out.log',
    error_file: '/var/log/dealhub-crm/error.log',
    max_memory_restart: '1G',
    node_args: '--max-old-space-size=1024'
  }]
};
EOF
}

# Function to start the application
start_app() {
    echo "🚀 Starting application with PM2..."
    cd $APP_DIR
    
    # Stop existing process if running
    pm2 stop dealhub-crm 2>/dev/null || true
    pm2 delete dealhub-crm 2>/dev/null || true
    
    # Start the application
    pm2 start ecosystem.config.js
    
    # Save PM2 configuration
    pm2 save
    
    # Setup PM2 to start on boot
    pm2 startup systemd -u www-data --hp /var/www
}

# Function to setup reverse proxy (nginx)
setup_nginx() {
    echo "🌐 Setting up Nginx reverse proxy..."
    
    # Install nginx if not present
    if ! command -v nginx &> /dev/null; then
        apt-get update
        apt-get install -y nginx
    fi
    
    # Create nginx configuration
    cat > /etc/nginx/sites-available/dealhub-crm << 'EOF'
server {
    listen 80;
    server_name dealhub.yitrobc.net;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name dealhub.yitrobc.net;

    # SSL Configuration (update paths to your SSL certificates)
    ssl_certificate /etc/ssl/certs/dealhub.yitrobc.net.crt;
    ssl_certificate_key /etc/ssl/private/dealhub.yitrobc.net.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Proxy to Node.js app
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_redirect off;
    }

    # Static files caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

    # Enable the site
    ln -sf /etc/nginx/sites-available/dealhub-crm /etc/nginx/sites-enabled/
    
    # Remove default nginx site if it exists
    rm -f /etc/nginx/sites-enabled/default
    
    # Test nginx configuration
    nginx -t
    
    # Restart nginx
    systemctl restart nginx
    systemctl enable nginx
}

# Function to setup firewall
setup_firewall() {
    echo "🔒 Setting up firewall..."
    
    # Install ufw if not present
    if ! command -v ufw &> /dev/null; then
        apt-get install -y ufw
    fi
    
    # Configure firewall
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 'Nginx Full'
    ufw --force enable
}

# Main execution
main() {
    echo "🔍 Checking system requirements..."
    check_root
    
    echo "📦 Installing system dependencies..."
    apt-get update
    install_nodejs
    install_pm2
    
    echo "📁 Setting up application structure..."
    setup_directories
    backup_existing
    
    echo "🚀 Deploying application..."
    deploy_app
    setup_pm2
    start_app
    
    echo "🌐 Setting up web server..."
    setup_nginx
    setup_firewall
    
    echo ""
    echo "✅ Deployment completed successfully!"
    echo "🌍 Your CRM application is now running at: https://dealhub.yitrobc.net"
    echo ""
    echo "📊 Useful commands:"
    echo "   • Check app status: pm2 status"
    echo "   • View logs: pm2 logs dealhub-crm"
    echo "   • Restart app: pm2 restart dealhub-crm"
    echo "   • Check nginx: systemctl status nginx"
    echo ""
    echo "⚠️  Important notes:"
    echo "   • Make sure to install SSL certificates for HTTPS"
    echo "   • Update DNS records to point dealhub.yitrobc.net to this server"
    echo "   • Consider setting up automated backups"
}

# Run the main function
main "$@"
