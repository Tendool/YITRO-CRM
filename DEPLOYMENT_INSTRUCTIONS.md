# Deployment Instructions for dealhub.yitrobc.net

## Server Details

- **Host**: Your server IP address
- **Domain**: https://dealhub.yitrobc.net
- **Database**: SQLite (serverless)
- **Deployment**: Dockerless Node.js with PM2

## Quick Deployment Steps

### 1. Make deployment script executable

```bash
chmod +x deploy-production.sh
```

### 2. Deploy to server (Automated)

```bash
sudo ./deploy-production.sh
```

## Manual Deployment Process

For detailed step-by-step manual deployment instructions, see:

**📖 [PRODUCTION_DEPLOYMENT.md](./PRODUCTION_DEPLOYMENT.md)**

### Summary of Manual Steps:

1. **Prepare Server**: Install Node.js 20.x and PM2
2. **Setup Directories**: Create application and backup directories
3. **Upload Application**: Transfer files to `/var/www/dealhub-crm`
4. **Install Dependencies**: `npm install --production`
5. **Build Application**: `npm run build`
6. **Configure PM2**: Setup process management
7. **Install Nginx**: Configure reverse proxy
8. **Setup SSL**: Install Let's Encrypt certificates
9. **Configure Firewall**: Setup UFW security rules

## Post-Deployment Verification

### Check if everything is running

```bash
# Check application status
pm2 status

# View application logs
pm2 logs dealhub-crm

# Check Nginx status
sudo systemctl status nginx

# Test application endpoint
curl -I https://dealhub.yitrobc.net/api/ping
```

### Access the application

- **Production URL**: https://dealhub.yitrobc.net
- **Admin Panel**: Login with admin credentials
- **API Health**: https://dealhub.yitrobc.net/api/ping

### Default Test Accounts

- **Admin**: admin@yitro.com / admin123
- **User**: user@yitro.com / user123

_Note: Change these credentials after first login_

## Management Commands

### Application Management

```bash
# View real-time logs
pm2 logs dealhub-crm

# Restart application
pm2 restart dealhub-crm

# Stop application
pm2 stop dealhub-crm

# Monitor resources
pm2 monit
```

### Database Management

```bash
cd /var/www/dealhub-crm

# Backup database
cp database.db "/var/backups/dealhub-crm/db-$(date +%Y%m%d-%H%M%S).db"

# Run migrations
npx prisma migrate deploy

# Seed test data
npm run db:seed
```

### Server Management

```bash
# Restart web server
sudo systemctl restart nginx

# Check SSL certificate
sudo certbot certificates

# Renew SSL certificate
sudo certbot renew
```

## Troubleshooting

### Application Issues

```bash
# Check if Node.js application is running
curl -I http://localhost:3000/api/ping

# View detailed logs
pm2 logs dealhub-crm --lines 100

# Check database file
ls -la /var/www/dealhub-crm/database.db
```

### Web Server Issues

```bash
# Test Nginx configuration
sudo nginx -t

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Check if ports are open
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
```

### SSL Issues

```bash
# Check SSL certificate status
sudo certbot certificates

# Test SSL connection
openssl s_client -connect dealhub.yitrobc.net:443 -servername dealhub.yitrobc.net
```

## Updates and Maintenance

### Updating the Application

```bash
cd /var/www/dealhub-crm

# Backup current version
sudo tar -czf "/var/backups/dealhub-crm/app-$(date +%Y%m%d-%H%M%S).tar.gz" .

# Upload new version or pull from git
# git pull origin main

# Install dependencies and rebuild
npm install --production
npm run build

# Restart application
pm2 restart dealhub-crm
```

### System Maintenance

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Node.js if needed
# Follow Node.js update procedures

# Clean old log files
sudo logrotate -f /etc/logrotate.conf

# Check disk space
df -h
```

## Backup Strategy

### Automated Backups

The deployment script sets up automated daily backups:

- **Database**: SQLite file copied daily
- **Application**: Full application archive daily
- **Retention**: 7 days of backups kept
- **Location**: `/var/backups/dealhub-crm/`

### Manual Backup

```bash
# Create full backup
sudo /usr/local/bin/backup-dealhub.sh

# List available backups
ls -la /var/backups/dealhub-crm/
```

## Security Checklist

- ✅ SSL certificate installed and working
- ✅ Firewall configured (UFW) - only SSH, HTTP, HTTPS open
- ✅ Strong JWT secret configured
- ✅ Application running as www-data user
- ✅ Database file permissions secured
- ✅ Nginx security headers configured
- ✅ Automated security updates enabled

## Performance Monitoring

### Key Metrics to Monitor

```bash
# CPU and memory usage
htop

# Application performance
pm2 monit

# Disk usage
df -h

# Network connections
ss -tuln
```

### Log Monitoring

```bash
# Real-time application logs
pm2 logs dealhub-crm --lines 50

# Nginx access logs
sudo tail -f /var/log/nginx/access.log

# System logs
journalctl -f -u nginx
```

## Support

For additional support:

1. **Check Logs**: Application and server logs for error details
2. **Verify Configuration**: Ensure all configuration files are correct
3. **Test Connectivity**: Verify network, DNS, and SSL configuration
4. **Review Documentation**: [PRODUCTION_DEPLOYMENT.md](./PRODUCTION_DEPLOYMENT.md)

## Success Indicators

✅ **Application Status**: `pm2 status` shows "online"  
✅ **Web Server**: `systemctl status nginx` shows "active (running)"  
✅ **SSL Certificate**: `certbot certificates` shows valid certificate  
✅ **API Response**: `curl -I https://dealhub.yitrobc.net/api/ping` returns 200  
✅ **Database**: SQLite file exists and is accessible  
✅ **Login**: Can access admin panel with test credentials

**🎉 Deployment Complete!**

Your CRM application is now live at: **https://dealhub.yitrobc.net**

---

_For comprehensive deployment instructions, see [PRODUCTION_DEPLOYMENT.md](./PRODUCTION_DEPLOYMENT.md)_
