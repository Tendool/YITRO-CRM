# DealHub CRM - Deployment Guide

This is a full-stack CRM application optimized for deployment on a VPS server with SQLite database.

## Project Structure

```
├── client/           # React Frontend (Vite + TypeScript)
├── server/           # Express Backend API
├── shared/           # Shared types and utilities
├── prisma/           # Database schema and migrations (SQLite)
├── data/             # SQLite database files
├── deploy.sh         # Production deployment script
├── setup-server.sh   # Server environment setup
└── init-db.sh        # Database initialization
```

## Quick Start

### Local Development

```bash
# Install dependencies
npm install

# Initialize database
npm run init:db

# Development mode
npm run dev        # Starts both frontend and backend
```

### Production Deployment

```bash
# 1. Set up server environment (run once)
sudo bash setup-server.sh

# 2. Deploy application
npm run deploy
```

## Environment Variables

The application uses these environment variables:

```env
DATABASE_URL="file:./data/production.db"
NODE_ENV=production
PORT=3000
JWT_SECRET="your-jwt-secret-key"
DOMAIN="https://dealhub.yitrobc.net"
```

## Frontend (Built to dist/spa)

- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS + Radix UI
- **State Management**: React Query + Context
- **Location**: `./client/`

## Backend (Port 3000)

- **Framework**: Express.js + TypeScript
- **Database**: SQLite with Prisma ORM
- **Authentication**: JWT + bcrypt
- **Location**: `./server/`

## Server Requirements

- **OS**: Ubuntu 20.04+ or similar Linux distribution
- **Node.js**: Version 18.x or higher
- **Memory**: Minimum 1GB RAM
- **Storage**: At least 5GB available space
- **Domain**: Configured to point to server IP

## Production Setup

### 1. Server Preparation (root@216.48.190.58)

```bash
# Download and run server setup script
wget https://your-repo/setup-server.sh
chmod +x setup-server.sh
sudo ./setup-server.sh
```

This script will:

- Install Node.js 18.x
- Install PM2 for process management
- Install and configure Nginx
- Set up SSL certificates with Let's Encrypt
- Configure firewall rules
- Create application directories

### 2. Application Deployment

```bash
# Clone your repository
git clone https://your-repo.git /var/www/dealhub
cd /var/www/dealhub

# Deploy the application
npm run deploy
```

The deployment script will:

- Install production dependencies
- Build the application
- Set up SQLite database
- Configure PM2 process manager
- Start the application

### 3. Nginx Configuration

The setup script automatically configures Nginx with:

- SSL termination
- Reverse proxy to Node.js application
- Security headers
- Gzip compression
- Static file serving

## Database Management

### SQLite Database

The application uses SQLite for simplicity and performance:

```bash
# Initialize database
npm run init:db

# Run migrations
npx prisma migrate deploy

# Seed test data
npm run db:seed

# Reset database
rm -f ./data/production.db && npm run init:db
```

### Database Location

- **Development**: `./data/dev.db`
- **Production**: `/var/www/dealhub/data/production.db`

## Process Management

The application runs under PM2 for reliability:

```bash
# Check status
pm2 list

# View logs
pm2 logs dealhub-crm

# Restart application
pm2 restart dealhub-crm

# Monitor performance
pm2 monit
```

## SSL Certificate

SSL certificates are automatically managed by Let's Encrypt:

```bash
# Check certificate status
sudo certbot certificates

# Renew certificates manually
sudo certbot renew

# Auto-renewal is configured via cron
```

## Build Commands

```bash
# Frontend only
npm run build:client

# Backend only
npm run build:server

# Both (production)
npm run build

# Database setup
npm run init:db

# Start production server
npm run start:production
```

## Monitoring and Logs

### Application Logs

```bash
# PM2 logs
pm2 logs dealhub-crm

# System logs
tail -f /var/log/dealhub/combined.log
```

### System Monitoring

```bash
# Check application status
pm2 list

# Monitor system resources
htop

# Check Nginx status
sudo systemctl status nginx
```

## Health Checks

- **Application**: `https://dealhub.yitrobc.net/api/ping`
- **Database**: SQLite file accessibility
- **SSL**: Certificate validity

## Backup and Recovery

### Database Backup

```bash
# Create backup
cp /var/www/dealhub/data/production.db /var/backups/dealhub-$(date +%Y%m%d).db

# Restore backup
cp /var/backups/dealhub-YYYYMMDD.db /var/www/dealhub/data/production.db
pm2 restart dealhub-crm
```

### Application Backup

```bash
# Full application backup
tar -czf /var/backups/dealhub-app-$(date +%Y%m%d).tar.gz -C /var/www dealhub
```

## Troubleshooting

### Common Issues

1. **Application won't start**

   ```bash
   # Check PM2 logs
   pm2 logs dealhub-crm

   # Check database permissions
   ls -la /var/www/dealhub/data/
   ```

2. **Database connection errors**

   ```bash
   # Verify database file exists
   ls -la ./data/production.db

   # Reinitialize database
   npm run init:db
   ```

3. **SSL certificate issues**

   ```bash
   # Check certificate status
   sudo certbot certificates

   # Renew certificate
   sudo certbot renew --nginx
   ```

4. **Nginx configuration**

   ```bash
   # Test configuration
   sudo nginx -t

   # Reload configuration
   sudo systemctl reload nginx
   ```

## Security Considerations

- SSL/TLS encryption enabled
- Security headers configured
- Firewall rules in place
- Regular security updates recommended
- Database file permissions restricted
- JWT tokens with secure secrets

## Performance Optimization

- Gzip compression enabled
- Static file caching
- PM2 cluster mode available
- Database indexes optimized
- Nginx reverse proxy caching

For support, contact the development team or refer to the application logs.
