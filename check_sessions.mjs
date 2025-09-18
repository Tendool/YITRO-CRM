import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function checkSessions() {
  try {
    const sessions = await prisma.authSession.findMany({
      include: { user: true },
      orderBy: { createdAt: 'desc' },
      take: 5
    });
    
    console.log('=== Recent Sessions ===');
    console.log('Total sessions found:', sessions.length);
    
    sessions.forEach((session, index) => {
      console.log(`Session ${index + 1}:`, {
        id: session.id.substring(0, 8) + '...',
        user: session.user.email,
        isActive: session.isActive,
        expiresAt: session.expiresAt,
        createdAt: session.createdAt
      });
    });
    
    // Check for active sessions
    const activeSessions = await prisma.authSession.count({
      where: { isActive: true }
    });
    console.log('\nActive sessions:', activeSessions);
    
  } catch (error) {
    console.error('Session check error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkSessions();
