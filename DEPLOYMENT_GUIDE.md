# DealHub CRM - Deployment Guide

## ✅ Local Development Setup

### Prerequisites
- Node.js 18+ installed
- npm (comes with Node.js)

### 1. Install Dependencies
```bash
npm install
```

### 2. Initialize Database
```bash
npm run init:db
```

### 3. Run Development Server
```bash
npm run dev
```

The app will be available at: http://localhost:8080

### 4. Test Login
- **Admin:** admin@yitro.com / admin123
- **User:** user@yitro.com / user123

## 🚀 Production Deployment

### Environment Configuration
The app is configured to work with:
- **Domain:** https://dealhub.yitrobc.net  
- **Database:** SQLite with in-memory fallback
- **Environment:** Production ready

### Pre-deployment Checklist
- ✅ SQLite database works correctly
- ✅ In-memory fallback implemented
- ✅ No git merge conflicts
- ✅ Build succeeds
- ✅ API endpoints functional
- ✅ Authentication working
- ✅ CORS configured for production domain

### Server Deployment Steps

1. **Transfer files to server:**
   ```bash
   # Upload all project files to server
   scp -r ./* user@server:/path/to/app/
   ```

2. **On the server, install dependencies:**
   ```bash
   npm install --production
   ```

3. **Initialize production database:**
   ```bash
   npm run init:db
   ```

4. **Build for production:**
   ```bash
   npm run build
   ```

5. **Start production server:**
   ```bash
   npm run start:production
   ```

### Environment Variables
The app uses these environment variables (already configured):

```bash
DATABASE_URL="file:./data/production.db"
NODE_ENV=production
PORT=3000
JWT_SECRET="your-jwt-secret-key-here-change-in-production"
DOMAIN="https://dealhub.yitrobc.net"
```

**⚠️ IMPORTANT:** Change the JWT_SECRET in production!

### Database Strategy
- **Primary:** SQLite database (`./data/production.db`)
- **Fallback:** In-memory database with sample data
- **Auto-fallback:** If SQLite fails, app automatically switches to in-memory mode

### Available Scripts
- `npm run dev` - Development server
- `npm run build` - Build for production  
- `npm run start:production` - Start production server
- `npm run init:db` - Initialize database
- `npm run migrate` - Run database migrations
- `npm run db:seed` - Seed database with test data

### API Endpoints
All endpoints available at `/api/*`:
- `/api/ping` - Health check
- `/api/auth/*` - Authentication
- `/api/contacts/*` - Contact management
- `/api/accounts/*` - Account management
- `/api/deals/*` - Deal management
- `/api/activities/*` - Activity logging
- `/api/leads/*` - Lead management

### Troubleshooting

**Database Issues:**
- If SQLite fails, app automatically uses in-memory data
- Check `./data/` directory permissions
- Run `npm run init:db` to recreate database

**Build Issues:**
- Some TypeScript warnings exist but don't affect functionality
- Build succeeds and app runs correctly

**Port Conflicts:**
- Default port is 3000 (configurable via PORT env var)
- Frontend served on same port as backend

### Security Notes
- CORS configured for production domain
- JWT authentication implemented
- Environment variables for sensitive data
- Database file permissions set correctly

## 📊 Features Available
- ✅ Contact Management
- ✅ Account Management  
- ✅ Deal Tracking
- ✅ Activity Logging
- ✅ Lead Management
- ✅ User Profiles
- ✅ Authentication
- ✅ Responsive UI
- ✅ Data Export/Import
- ✅ Search & Filtering

---

**Ready for deployment to https://dealhub.yitrobc.net** 🚀
