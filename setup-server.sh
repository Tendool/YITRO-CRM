#!/bin/bash

# DealHub CRM - Server Setup Script
# Run this on the production server: root@216.48.190.58

set -e

echo "🖥️  Setting up DealHub CRM server environment..."

# Update system
echo "🔄 Updating system packages..."
apt update && apt upgrade -y

# Install Node.js 18.x
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt install -y nodejs

# Install PM2 globally
echo "🔄 Installing PM2..."
npm install -g pm2

# Install Nginx
echo "🌐 Installing Nginx..."
apt install -y nginx

# Install SSL certificate tools
echo "🔐 Installing SSL tools..."
apt install -y certbot python3-certbot-nginx

# Create application user
echo "👤 Creating application user..."
if ! id "dealhub" &>/dev/null; then
    useradd -m -s /bin/bash dealhub
    usermod -aG sudo dealhub
fi

# Create application directories
echo "📁 Creating application directories..."
mkdir -p /var/www/dealhub
mkdir -p /var/log/dealhub
mkdir -p /var/www/dealhub/data

# Set permissions
chown -R dealhub:dealhub /var/www/dealhub
chown -R dealhub:dealhub /var/log/dealhub
chmod 755 /var/www/dealhub
chmod 755 /var/log/dealhub
chmod 755 /var/www/dealhub/data

# Configure Nginx
echo "⚙️  Configuring Nginx..."
cat > /etc/nginx/sites-available/dealhub << EOL
server {
    listen 80;
    server_name dealhub.yitrobc.net;

    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name dealhub.yitrobc.net;

    # SSL configuration will be added by certbot
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 90;
        proxy_send_timeout 90;
    }

    # Handle static files
    location /assets/ {
        proxy_pass http://localhost:3000;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOL

# Enable the site
ln -sf /etc/nginx/sites-available/dealhub /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Start and enable services
echo "🏃 Starting services..."
systemctl start nginx
systemctl enable nginx

# Configure firewall
echo "🔥 Configuring firewall..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# Get SSL certificate
echo "🔐 Setting up SSL certificate..."
certbot --nginx -d dealhub.yitrobc.net --non-interactive --agree-tos --email admin@yitrobc.net

# Set up automatic SSL renewal
echo "⏰ Setting up SSL renewal..."
crontab -l | { cat; echo "0 12 * * * /usr/bin/certbot renew --quiet"; } | crontab -

echo "✅ Server setup completed!"
echo "🌐 Your server is ready for DealHub CRM deployment"
echo "📋 Next steps:"
echo "1. Clone your application code to /var/www/dealhub"
echo "2. Run the deploy.sh script as the dealhub user"
echo "3. Your application will be available at https://dealhub.yitrobc.net"
