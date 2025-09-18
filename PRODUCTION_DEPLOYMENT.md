# Production Deployment Guide - Dockerless Setup

## 🎯 Deploy to https://dealhub.yitrobc.net/

This guide provides step-by-step instructions to deploy the Yitro CRM Platform to your server without Docker containers, using SQLite database and serving on your custom domain.

## 📋 Prerequisites

- Ubuntu/Debian server with root access
- Domain `dealhub.yitrobc.net` pointing to your server IP
- SSL certificate for HTTPS (Let's Encrypt recommended)
- Minimum 2GB RAM, 20GB storage

## 🚀 Quick Deployment (Automated)

### Option 1: One-Command Deployment

```bash
# Upload your project to the server and run:
sudo chmod +x deploy-production.sh
sudo ./deploy-production.sh
```

This script automatically:

- Installs Node.js 20.x and PM2
- Sets up application directories
- Installs dependencies and builds the app
- Configures Nginx reverse proxy
- Sets up SSL and firewall
- Starts the application

## 📖 Manual Deployment (Step-by-Step)

### Step 1: Prepare Your Server

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install curl and basic tools
sudo apt install -y curl wget git build-essential
```

### Step 2: Install Node.js 20.x

```bash
# Add NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Install Node.js
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x
```

### Step 3: Install PM2 Process Manager

```bash
# Install PM2 globally
sudo npm install -g pm2

# Verify installation
pm2 --version
```

### Step 4: Create Application Directories

```bash
# Create main application directory
sudo mkdir -p /var/www/dealhub-crm

# Create backup directory
sudo mkdir -p /var/backups/dealhub-crm

# Create log directory
sudo mkdir -p /var/log/dealhub-crm

# Set ownership
sudo chown -R $USER:$USER /var/www/dealhub-crm
```

### Step 5: Upload and Setup Application

```bash
# Clone or upload your repository to the server
# If using git:
cd /var/www/dealhub-crm
git clone https://github.com/your-repo/dealhub-crm.git .

# Or upload files via SCP:
# scp -r ./project/* user@server:/var/www/dealhub-crm/

# Install dependencies
npm install --production

# Generate Prisma client
npx prisma generate

# Create and migrate database
npx prisma migrate deploy

# Build the application
npm run build
```

### Step 6: Configure Environment

```bash
# Create production environment file
cat > /var/www/dealhub-crm/.env << 'EOF'
NODE_ENV=production
PORT=3000
DATABASE_URL="file:./database.db"
JWT_SECRET="your-super-secure-jwt-secret-key-here-minimum-64-characters-long"
EOF

# Set proper permissions
chmod 600 /var/www/dealhub-crm/.env
```

### Step 7: Create PM2 Configuration

```bash
# Create PM2 ecosystem file
cat > /var/www/dealhub-crm/ecosystem.config.js << 'EOF'
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
    node_args: '--max-old-space-size=1024',
    restart_delay: 4000,
    max_restarts: 10,
    min_uptime: '10s'
  }]
};
EOF
```

### Step 8: Start Application with PM2

```bash
cd /var/www/dealhub-crm

# Start the application
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 to start on system boot
pm2 startup systemd

# Follow the instructions shown by PM2 startup command
```

### Step 9: Install and Configure Nginx

```bash
# Install Nginx
sudo apt install -y nginx

# Create Nginx configuration for your domain
sudo tee /etc/nginx/sites-available/dealhub-crm << 'EOF'
server {
    listen 80;
    server_name dealhub.yitrobc.net;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name dealhub.yitrobc.net;

    # SSL Configuration (update paths to your certificates)
    ssl_certificate /etc/ssl/certs/dealhub.yitrobc.net.crt;
    ssl_certificate_key /etc/ssl/private/dealhub.yitrobc.net.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;

    # Main proxy configuration
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

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Static files caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # API requests
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/dealhub-crm /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Start and enable Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### Step 10: Setup SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d dealhub.yitrobc.net

# Setup automatic renewal
sudo crontab -e
# Add this line:
# 0 12 * * * /usr/bin/certbot renew --quiet
```

### Step 11: Configure Firewall

```bash
# Install and configure UFW firewall
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Check firewall status
sudo ufw status
```

### Step 12: Final Configuration

```bash
# Set proper ownership and permissions
sudo chown -R www-data:www-data /var/www/dealhub-crm
sudo chmod -R 755 /var/www/dealhub-crm

# Restart all services
sudo systemctl restart nginx
pm2 restart dealhub-crm

# Check everything is running
pm2 status
sudo systemctl status nginx
```

## 🔧 Management Commands

### Application Management

```bash
# Check application status
pm2 status

# View real-time logs
pm2 logs dealhub-crm

# Restart application
pm2 restart dealhub-crm

# Stop application
pm2 stop dealhub-crm

# Monitor resources
pm2 monit
```

### Server Management

```bash
# Check Nginx status
sudo systemctl status nginx

# Restart Nginx
sudo systemctl restart nginx

# Check SSL certificate
sudo certbot certificates

# Renew SSL certificate
sudo certbot renew

# View Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Database Management

```bash
cd /var/www/dealhub-crm

# Create database backup
cp database.db "/var/backups/dealhub-crm/db-backup-$(date +%Y%m%d-%H%M%S).db"

# Run database migrations
npx prisma migrate deploy

# Reset database (CAUTION: This will delete all data!)
rm database.db
npx prisma migrate deploy
npm run db:seed
```

## 📊 Monitoring and Logs

### Log Locations

- **Application Logs**: `/var/log/dealhub-crm/`
- **Nginx Logs**: `/var/log/nginx/`
- **System Logs**: `journalctl -u nginx` or `journalctl -f`

### Health Checks

```bash
# Check if application is responding
curl -I https://dealhub.yitrobc.net/api/ping

# Check local application
curl -I http://localhost:3000/api/ping

# Check SSL certificate
openssl s_client -connect dealhub.yitrobc.net:443 -servername dealhub.yitrobc.net
```

## 🔄 Updates and Maintenance

### Updating the Application

```bash
cd /var/www/dealhub-crm

# Backup current version
sudo tar -czf "/var/backups/dealhub-crm/app-backup-$(date +%Y%m%d-%H%M%S).tar.gz" .

# Pull latest changes (if using git)
git pull origin main

# Or upload new files via SCP

# Install new dependencies
npm install --production

# Rebuild application
npm run build

# Run any new migrations
npx prisma migrate deploy

# Restart application
pm2 restart dealhub-crm
```

### Automated Backups

```bash
# Create backup script
sudo tee /usr/local/bin/backup-dealhub.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/dealhub-crm"
DATE=$(date +%Y%m%d-%H%M%S)

# Create application backup
tar -czf "$BACKUP_DIR/app-$DATE.tar.gz" -C /var/www/dealhub-crm .

# Create database backup
cp /var/www/dealhub-crm/database.db "$BACKUP_DIR/db-$DATE.db"

# Keep only last 7 backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.db" -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

# Make script executable
sudo chmod +x /usr/local/bin/backup-dealhub.sh

# Add to crontab for daily backups at 2 AM
echo "0 2 * * * /usr/local/bin/backup-dealhub.sh" | sudo crontab -
```

## 🛠️ Troubleshooting

### Common Issues

#### Application Won't Start

```bash
# Check PM2 logs
pm2 logs dealhub-crm

# Check if port 3000 is available
sudo netstat -tulpn | grep :3000

# Restart application
pm2 restart dealhub-crm
```

#### Nginx Issues

```bash
# Test Nginx configuration
sudo nginx -t

# Check Nginx status
sudo systemctl status nginx

# Restart Nginx
sudo systemctl restart nginx
```

#### SSL Certificate Issues

```bash
# Check certificate status
sudo certbot certificates

# Renew certificate manually
sudo certbot renew --force-renewal -d dealhub.yitrobc.net
```

#### Database Issues

```bash
# Check database file permissions
ls -la /var/www/dealhub-crm/database.db

# Regenerate Prisma client
cd /var/www/dealhub-crm
npx prisma generate

# Reset database (CAUTION!)
rm database.db
npx prisma migrate deploy
```

## 🔐 Security Considerations

1. **Regular Updates**: Keep system packages, Node.js, and dependencies updated
2. **SSL Certificate**: Ensure HTTPS is working and certificates are renewed
3. **Firewall**: Only open necessary ports (22, 80, 443)
4. **Backups**: Regular automated backups of application and database
5. **Monitoring**: Set up monitoring for application health and server resources
6. **Strong Passwords**: Use strong JWT secrets and system passwords

## 📞 Support

If you encounter issues during deployment:

1. Check the logs in `/var/log/dealhub-crm/`
2. Verify all services are running: `pm2 status` and `sudo systemctl status nginx`
3. Test connectivity: `curl -I https://dealhub.yitrobc.net/api/ping`
4. Check DNS resolution: `nslookup dealhub.yitrobc.net`

## 🎉 Success!

Once deployment is complete, your CRM application will be available at:

**🌍 https://dealhub.yitrobc.net/**

### Default Login Credentials

- **Admin**: `admin@yitro.com` / `admin123`
- **User**: `user@yitro.com` / `user123`

Remember to change these credentials after first login!

---

_This deployment guide ensures a robust, scalable, and secure production setup without Docker containers._
