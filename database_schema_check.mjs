// database_schema_check.mjs
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function checkDatabaseSchema() {
  console.log('=== Database Schema Check ===');
  
  try {
    // Check AuthUser table structure
    console.log('1. Checking AuthUser table...');
    const users = await prisma.authUser.findMany();
    console.log('Users found:', users.length);
    
    if (users.length > 0) {
      console.log('Sample user structure:');
      const user = users[0];
      Object.keys(user).forEach(key => {
        console.log(`  ${key}: ${typeof user[key]} = ${user[key]}`);
      });
    }

    // Check AuthSession table structure  
    console.log('\n2. Checking AuthSession table...');
    const sessions = await prisma.authSession.findMany({
      include: { user: true }
    });
    console.log('Sessions found:', sessions.length);
    
    if (sessions.length > 0) {
      console.log('Sample session structure:');
      const session = sessions[0];
      Object.keys(session).forEach(key => {
        if (key !== 'user') {
          console.log(`  ${key}: ${typeof session[key]} = ${session[key]}`);
        }
      });
    }

    // Check for orphaned sessions
    console.log('\n3. Checking for data integrity issues...');
    const orphanedSessions = await prisma.authSession.findMany({
      where: {
        user: null
      }
    });
    console.log('Orphaned sessions:', orphanedSessions.length);

    // Check for expired sessions
    const expiredSessions = await prisma.authSession.findMany({
      where: {
        expiresAt: {
          lt: new Date()
        }
      }
    });
    console.log('Expired sessions:', expiredSessions.length);

    // Check for inactive sessions
    const inactiveSessions = await prisma.authSession.findMany({
      where: {
        isActive: false
      }
    });
    console.log('Inactive sessions:', inactiveSessions.length);

    console.log('\n4. Database file info...');
    console.log('DATABASE_URL:', process.env.DATABASE_URL);
    
    // Try to get some database stats
    const userCount = await prisma.authUser.count();
    const sessionCount = await prisma.authSession.count();
    const contactCount = await prisma.contact.count().catch(() => 0);
    const accountCount = await prisma.account.count().catch(() => 0);
    
    console.log('\nDatabase contents:');
    console.log(`- Users: ${userCount}`);
    console.log(`- Sessions: ${sessionCount}`);
    console.log(`- Contacts: ${contactCount}`);
    console.log(`- Accounts: ${accountCount}`);

  } catch (error) {
    console.error('Schema check failed:', error.message);
    
    // Try to identify the specific issue
    if (error.message.includes('Unknown argument')) {
      console.log('\n❌ Schema mismatch detected!');
      console.log('Your Prisma schema doesn\'t match your database structure.');
      console.log('Run: npm run db:push to sync the schema');
    }
    
    if (error.message.includes('Table') && error.message.includes('doesn\'t exist')) {
      console.log('\n❌ Missing tables detected!');
      console.log('Run: npx prisma db push --force-reset');
    }
  } finally {
    await prisma.$disconnect();
  }
}

checkDatabaseSchema();
