import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function monitorAuth() {
  try {
    console.log('=== Authentication Monitoring ===');
    
    // Check current sessions
    const sessions = await prisma.authSession.findMany({
      include: { user: true },
      orderBy: { createdAt: 'desc' },
      take: 10
    });
    
    console.log('Total sessions (including expired):', sessions.length);
    
    sessions.forEach(session => {
      const isExpired = new Date(session.expiresAt) < new Date();
      console.log({
        user: session.user.email,
        isActive: session.isActive,
        isExpired: isExpired,
        expiresAt: session.expiresAt,
        createdAt: session.createdAt
      });
    });
    
    // Check the auth user's last login
    const users = await prisma.authUser.findMany({
      select: {
        email: true,
        lastLogin: true,
        createdAt: true
      }
    });
    
    console.log('\nUser login info:');
    users.forEach(user => {
      console.log(`${user.email}: Last login = ${user.lastLogin || 'Never'}`);
    });
    
  } catch (error) {
    console.error('Auth monitoring error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

monitorAuth();
