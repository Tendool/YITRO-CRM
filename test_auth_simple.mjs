// Test database connection without Prisma
import sqlite3 from 'sqlite3';
import bcrypt from 'bcrypt';

const db = new sqlite3.Database('./dev.db');

async function testAuth() {
  console.log('=== Testing Database and Auth ===');
  
  try {
    // Test database connection
    const users = await new Promise((resolve, reject) => {
      db.all('SELECT email, role, emailVerified, displayName FROM auth_users', (err, rows) => {
        if (err) reject(err);
        else resolve(rows);
      });
    });
    
    console.log('Users in database:');
    users.forEach(user => {
      console.log(`- ${user.email} (${user.role}) - verified: ${user.emailVerified}`);
    });
    
    // Test password verification for admin user
    const adminUser = await new Promise((resolve, reject) => {
      db.get('SELECT * FROM auth_users WHERE email = ?', ['admin@yitro.com'], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });
    
    if (adminUser) {
      console.log('\nTesting admin user password:');
      const testPasswords = ['admin123', 'password', 'admin'];
      
      for (const pwd of testPasswords) {
        const match = await bcrypt.compare(pwd, adminUser.passwordHash);
        if (match) {
          console.log(`✅ Password "${pwd}" works for admin@yitro.com`);
          break;
        } else {
          console.log(`❌ Password "${pwd}" doesn't work`);
        }
      }
    }
    
    // Check counts for metrics
    const leadCount = await new Promise((resolve, reject) => {
      db.get('SELECT COUNT(*) as count FROM leads', (err, row) => {
        if (err) reject(err);
        else resolve(row.count);
      });
    });
    
    const accountCount = await new Promise((resolve, reject) => {
      db.get('SELECT COUNT(*) as count FROM accounts', (err, row) => {
        if (err) reject(err);
        else resolve(row.count);
      });
    });
    
    const dealCount = await new Promise((resolve, reject) => {
      db.get('SELECT COUNT(*) as count FROM active_deals', (err, row) => {
        if (err) reject(err);
        else resolve(row.count);
      });
    });
    
    console.log('\n=== Current Metrics ===');
    console.log(`Leads: ${leadCount}`);
    console.log(`Accounts: ${accountCount}`);
    console.log(`Active Deals: ${dealCount}`);
    
  } catch (error) {
    console.error('Test failed:', error);
  } finally {
    db.close();
  }
}

testAuth();