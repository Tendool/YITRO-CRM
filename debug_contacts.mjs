import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function debugContacts() {
  try {
    console.log('=== Contact Debug ===');
    
    // Check all contacts (including deleted ones if any)
    const allContacts = await prisma.contact.findMany({
      select: {
        id: true,
        firstName: true,
        lastName: true,
        owner: true,
        createdBy: true,
        createdAt: true,
        updatedAt: true
      },
      orderBy: { createdAt: 'desc' }
    });
    
    console.log('Total contacts found:', allContacts.length);
    
    if (allContacts.length > 0) {
      console.log('Recent contacts:');
      allContacts.slice(0, 5).forEach(contact => {
        console.log(`- ${contact.firstName} ${contact.lastName}, Owner: ${contact.owner}, CreatedBy: ${contact.createdBy}, Created: ${contact.createdAt}`);
      });
    } else {
      console.log('No contacts found in database');
    }
    
    // Check accounts for comparison
    const accounts = await prisma.account.findMany({
      select: {
        id: true,
        accountName: true,
        createdBy: true,
        createdAt: true
      }
    });
    
    console.log('\nAccounts:');
    accounts.forEach(account => {
      console.log(`- ${account.accountName}, CreatedBy: ${account.createdBy}, Created: ${account.createdAt}`);
    });
    
  } catch (error) {
    console.error('Debug error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

debugContacts();
