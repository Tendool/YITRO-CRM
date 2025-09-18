# DealHub CRM Platform

A comprehensive Customer Relationship Management system built with React, Express.js, and SQLite, optimized for deployment on `dealhub.yitrobc.net`.

## 🚀 Features

- **Complete CRM Functionality**: Manage contacts, accounts, deals, and activities
- **User Profile Management**: Role-based access control
- **Real-time Dashboard**: Metrics and analytics
- **Professional Reports**: Export and analysis tools
- **Dark/Light Mode**: Modern UI with theme switching
- **Responsive Design**: Mobile-friendly interface
- **SQLite Database**: Lightweight and efficient data storage

## 🛠️ Technology Stack

- **Frontend**: React 18, TypeScript, Vite, Tailwind CSS, Radix UI
- **Backend**: Express.js, TypeScript, Prisma ORM
- **Database**: SQLite
- **Authentication**: JWT + bcrypt
- **Deployment**: PM2, Nginx, Let's Encrypt SSL

## 📋 Quick Start

### Local Development

```bash
# Clone repository
git clone <repository-url>
cd dealhub-crm

# Install dependencies
npm install

# Initialize database
npm run init:db

# Start development server
npm run dev
```

Access the application at `http://localhost:8080`

### Production Deployment

#### Server Setup (Run once on root@216.48.190.58)

```bash
# Download and run server setup
wget <repository-url>/setup-server.sh
chmod +x setup-server.sh
sudo ./setup-server.sh
```

#### Application Deployment

```bash
# Clone to production directory
git clone <repository-url> /var/www/dealhub
cd /var/www/dealhub

# Deploy application
npm run deploy
```

The application will be available at `https://dealhub.yitrobc.net`

## 📁 Project Structure

```
dealhub-crm/
├── client/              # React frontend application
│   ├── components/      # Reusable UI components
│   ├── pages/          # Application pages
│   ├── services/       # API services
│   └── hooks/          # Custom React hooks
├── server/             # Express.js backend
│   ├── routes/         # API route handlers
│   ├���─ lib/            # Utility libraries
│   └── db/             # Database utilities
├── shared/             # Shared types and models
├── prisma/             # Database schema and migrations
├── data/               # SQLite database files
├── deploy.sh           # Production deployment script
├── setup-server.sh     # Server environment setup
└── init-db.sh          # Database initialization
```

## 🔧 Available Scripts

```bash
# Development
npm run dev              # Start development server
npm run dev:server       # Start backend only

# Building
npm run build            # Build both frontend and backend
npm run build:client     # Build frontend only
npm run build:server     # Build backend only

# Production
npm run start            # Start production server
npm run start:production # Start with production environment

# Database
npm run init:db          # Initialize SQLite database
npm run migrate          # Run database migrations
npm run db:seed          # Seed database with test data

# Deployment
npm run deploy           # Deploy to production
npm run setup:server     # Setup server environment

# Testing & Quality
npm run test             # Run tests
npm run typecheck        # TypeScript type checking
npm run format.fix       # Fix code formatting
```

## 🗄️ Database Management

The application uses SQLite for data storage:

```bash
# Initialize database
npm run init:db

# Run migrations
npx prisma migrate deploy

# View database
npx prisma studio

# Reset database
rm -f ./data/production.db && npm run init:db
```

## 🔐 Environment Configuration

Create a `.env` file for local development:

```env
DATABASE_URL="file:./data/production.db"
NODE_ENV=production
PORT=3000
JWT_SECRET="your-secure-jwt-secret"
DOMAIN="https://dealhub.yitrobc.net"
```

## 🌐 Production Environment

### Server Specifications

- **Server**: root@216.48.190.58
- **Domain**: https://dealhub.yitrobc.net
- **OS**: Ubuntu 20.04+
- **Node.js**: 18.x
- **Process Manager**: PM2
- **Web Server**: Nginx
- **SSL**: Let's Encrypt

### Monitoring

```bash
# Check application status
pm2 list

# View logs
pm2 logs dealhub-crm

# Monitor performance
pm2 monit

# Check Nginx status
sudo systemctl status nginx
```

## 🔒 Security Features

- SSL/TLS encryption with Let's Encrypt
- Security headers configuration
- JWT-based authentication
- Firewall configuration
- Secure database file permissions
- Regular security updates

## 📊 Performance

- Nginx reverse proxy with caching
- Gzip compression enabled
- Static file optimization
- PM2 cluster mode ready
- Optimized database queries

## 🐛 Troubleshooting

### Common Issues

1. **Application won't start**

   ```bash
   pm2 logs dealhub-crm
   npm run init:db
   ```

2. **Database errors**

   ```bash
   ls -la ./data/
   npx prisma migrate deploy
   ```

3. **SSL certificate issues**
   ```bash
   sudo certbot certificates
   sudo certbot renew
   ```

### Log Files

- Application logs: `/var/log/dealhub/`
- Nginx logs: `/var/log/nginx/`
- PM2 logs: `~/.pm2/logs/`

## 📝 API Documentation

The API is available at `https://dealhub.yitrobc.net/api/` with the following endpoints:

- `GET /api/contacts` - List contacts
- `GET /api/accounts` - List accounts
- `GET /api/deals` - List deals
- `GET /api/activities` - List activities
- `GET /api/leads` - List leads
- `POST /api/auth/signin` - User authentication

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `npm test`
5. Submit a pull request

## 📄 License

This project is proprietary software for Yitro Business Consulting.

## 🆘 Support

For support and questions:

- Check the [Deployment Guide](./DEPLOYMENT.md)
- Review application logs
- Contact the development team

---

**DealHub CRM Platform** - Professional CRM solution for modern businesses.
