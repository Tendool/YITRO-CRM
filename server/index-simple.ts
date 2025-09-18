// Simple server implementation using native sqlite3 and express
import express from 'express';
import cors from 'cors';
import sqlite3 from 'sqlite3';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

const app = express();
const db = new sqlite3.Database('./dev.db');

// Middleware
app.use(cors());
app.use(express.json());

// Helper function to promisify database queries
const dbQuery = (query, params = []) => {
  return new Promise((resolve, reject) => {
    db.all(query, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
};

const dbGet = (query, params = []) => {
  return new Promise((resolve, reject) => {
    db.get(query, params, (err, row) => {
      if (err) reject(err);
      else resolve(row);
    });
  });
};

const dbRun = (query, params = []) => {
  return new Promise((resolve, reject) => {
    db.run(query, params, function(err) {
      if (err) reject(err);
      else resolve({ id: this.lastID, changes: this.changes });
    });
  });
};

// Authentication endpoints
app.post('/api/auth/signin', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email and password are required' 
      });
    }

    // Find user by email
    const user = await dbGet('SELECT * FROM auth_users WHERE email = ?', [email.toLowerCase()]);

    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Invalid credentials' 
      });
    }

    // Verify password
    const passwordMatch = await bcrypt.compare(password, user.passwordHash);
    if (!passwordMatch) {
      return res.status(401).json({ 
        success: false, 
        message: 'Invalid credentials' 
      });
    }

    // Clear old sessions for this user
    await dbRun('UPDATE auth_sessions SET isActive = 0 WHERE userId = ? AND isActive = 1', [user.id]);

    // Create new session
    const tokenData = {
      userId: user.id,
      email: user.email,
      role: user.role,
      timestamp: Date.now()
    };
    
    const token = jwt.sign(tokenData, process.env.JWT_SECRET || 'default-secret', {
      expiresIn: '24h'
    });

    const sessionId = 'sess_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    await dbRun(`
      INSERT INTO auth_sessions (id, userId, tokenHash, expiresAt, ipAddress, userAgent, isActive)
      VALUES (?, ?, ?, ?, ?, ?, 1)
    `, [sessionId, user.id, token, expiresAt.toISOString(), req.ip, req.get('User-Agent')]);

    // Update user's last login
    await dbRun('UPDATE auth_users SET lastLogin = ? WHERE id = ?', [new Date().toISOString(), user.id]);

    res.json({
      success: true,
      message: 'Signed in successfully',
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        displayName: user.displayName
      },
      token: token
    });

  } catch (error) {
    console.error('Signin error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Internal server error' 
    });
  }
});

// Get current user info
app.get('/api/auth/me', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'No token provided' });
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default-secret');
    
    const user = await dbGet('SELECT id, email, role, displayName FROM auth_users WHERE id = ?', [decoded.userId]);
    
    if (!user) {
      return res.status(401).json({ success: false, message: 'User not found' });
    }

    res.json({
      success: true,
      user: user
    });

  } catch (error) {
    console.error('Auth verification error:', error);
    res.status(401).json({ success: false, message: 'Invalid token' });
  }
});

// Get dashboard metrics
app.get('/api/dashboard/metrics', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default-secret');
    
    const user = await dbGet('SELECT * FROM auth_users WHERE id = ?', [decoded.userId]);
    
    if (!user) {
      return res.status(401).json({ success: false, message: 'User not found' });
    }

    // Get metrics based on user role
    let whereClause = '';
    let params = [];
    
    if (user.role !== 'admin') {
      // For regular users, only show their own data
      whereClause = ' WHERE createdBy = ?';
      params = [user.id];
    }
    
    const [leadCount, accountCount, dealCount, contactCount] = await Promise.all([
      dbGet(`SELECT COUNT(*) as count FROM leads${whereClause}`, params),
      dbGet(`SELECT COUNT(*) as count FROM accounts${whereClause}`, params), 
      dbGet(`SELECT COUNT(*) as count FROM active_deals${whereClause}`, params),
      dbGet(`SELECT COUNT(*) as count FROM contacts${whereClause}`, params)
    ]);

    // Get recent activities
    const activities = await dbQuery(`
      SELECT 'lead' as type, firstName || ' ' || lastName as name, status, createdAt 
      FROM leads${whereClause}
      UNION ALL
      SELECT 'account' as type, accountName as name, status, createdAt 
      FROM accounts${whereClause}
      UNION ALL  
      SELECT 'deal' as type, dealName as name, stage as status, createdAt
      FROM active_deals${whereClause}
      ORDER BY createdAt DESC LIMIT 10
    `, params);

    res.json({
      success: true,
      metrics: {
        leads: leadCount.count,
        accounts: accountCount.count,
        deals: dealCount.count,
        contacts: contactCount.count
      },
      recentActivities: activities,
      userRole: user.role
    });

  } catch (error) {
    console.error('Metrics error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch metrics' });
  }
});

// Create user (admin only)
app.post('/api/admin/users', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default-secret');
    
    const adminUser = await dbGet('SELECT * FROM auth_users WHERE id = ?', [decoded.userId]);
    
    if (!adminUser || adminUser.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Admin access required' });
    }

    const { email, displayName, password, role = 'user' } = req.body;
    
    if (!email || !displayName || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email, display name and password are required' 
      });
    }

    // Check if user already exists
    const existingUser = await dbGet('SELECT id FROM auth_users WHERE email = ?', [email.toLowerCase()]);
    if (existingUser) {
      return res.status(400).json({ success: false, message: 'User already exists' });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);
    const userId = 'user_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);

    // Create user
    await dbRun(`
      INSERT INTO auth_users (id, email, displayName, passwordHash, role, emailVerified, createdAt, updatedAt)
      VALUES (?, ?, ?, ?, ?, 1, ?, ?)
    `, [userId, email.toLowerCase(), displayName, passwordHash, role, new Date().toISOString(), new Date().toISOString()]);

    res.json({
      success: true,
      message: 'User created successfully',
      user: {
        id: userId,
        email: email.toLowerCase(),
        displayName: displayName,
        role: role
      }
    });

  } catch (error) {
    console.error('User creation error:', error);
    res.status(500).json({ success: false, message: 'Failed to create user' });
  }
});

// List all users (admin only)
app.get('/api/admin/users', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default-secret');
    
    const adminUser = await dbGet('SELECT * FROM auth_users WHERE id = ?', [decoded.userId]);
    
    if (!adminUser || adminUser.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Admin access required' });
    }

    const users = await dbQuery(`
      SELECT id, email, displayName, role, emailVerified, createdAt, lastLogin
      FROM auth_users
      ORDER BY createdAt DESC
    `);

    res.json({
      success: true,
      users: users
    });

  } catch (error) {
    console.error('User listing error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch users' });
  }
});

export function createServerSimple() {
  return app;
}