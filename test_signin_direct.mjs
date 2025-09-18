// test_signin_direct.mjs
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function testSigninDirect() {
  try {
    console.log('=== Testing Signin Logic Directly ===');
    
    // 1. Get the admin user
    const user = await prisma.authUser.findFirst({
      where: { email: 'admin@yitrobc.net' }
    });
    
    if (!user) {
      console.log('❌ Admin user not found');
      return;
    }
    
    console.log('✅ Found user:', user.email);
    console.log('User active:', user.isActive);
    console.log('Email verified:', user.emailVerified);
    
    // 2. Test password verification
    const testPassword = 'admain123';
    const passwordMatch = await bcrypt.compare(testPassword, user.passwordHash);
    console.log('Password match for "admain123":', passwordMatch);
    
    if (!passwordMatch) {
      // Try with different common passwords
      const commonPasswords = ['admin123', 'password', 'admin', 'yitro123'];
      for (const pwd of commonPasswords) {
        const match = await bcrypt.compare(pwd, user.passwordHash);
        if (match) {
          console.log(`✅ Password match found: "${pwd}"`);
          break;
        }
      }
    }
    
    // 3. Clear old sessions and create a new one
    console.log('\n=== Testing Session Creation ===');
    
    // Clear old sessions for this user
    await prisma.authSession.deleteMany({
      where: { userId: user.id }
    });
    console.log('🧹 Cleared old sessions');
    
    // Create new session (simulating successful signin)
    const newSession = await prisma.authSession.create({
      data: {
        userId: user.id,
        tokenHash: `token-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 hours
        isActive: true,
        ipAddress: '127.0.0.1',
        userAgent: 'test-signin'
      }
    });
    
    console.log('✅ New session created:', newSession.id.substring(0, 12) + '...');
    console.log('Session expires at:', newSession.expiresAt);
    
    // 4. Update user's last login
    await prisma.authUser.update({
      where: { id: user.id },
      data: { lastLogin: new Date() }
    });
    
    console.log('✅ Updated user last login');
    
    // 5. Verify session exists and is active
    const activeSessions = await prisma.authSession.findMany({
      where: {
        userId: user.id,
        isActive: true,
        expiresAt: { gt: new Date() }
      }
    });
    
    console.log(`✅ Active sessions for user: ${activeSessions.length}`);
    
    // 6. Test the actual API call
    console.log('\n=== Testing API Call ===');
    console.log('Now test this curl command:');
    console.log(`curl -X POST http://localhost:3000/api/auth/signin \\`);
    console.log(`  -H "Content-Type: application/json" \\`);
    console.log(`  -d '{"email":"admin@yitrobc.net","password":"admain123"}' \\`);
    console.log(`  -v`);
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

testSigninDirect();
