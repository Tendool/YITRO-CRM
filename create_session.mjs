import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function createTestSession() {
  try {
    console.log('=== Creating Test Session ===');
    
    // Get the user
    const user = await prisma.authUser.findFirst();
    if (!user) {
      console.log('No user found');
      return;
    }
    
    // Create a session manually
    const session = await prisma.authSession.create({
      data: {
        userId: user.id,
        tokenHash: 'test-token-hash',
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 hours
        isActive: true,
        ipAddress: '127.0.0.1',
        userAgent: 'test-agent'
      }
    });
    
    console.log('Test session created:', session.id);
    
    // Update user's last login
    await prisma.authUser.update({
      where: { id: user.id },
      data: { lastLogin: new Date() }
    });
    
    console.log('User last login updated');
    
  } catch (error) {
    console.error('Session creation error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

createTestSession();
