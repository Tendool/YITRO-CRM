import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function checkData() {
  try {
    const contacts = await prisma.contact.count();
    const accounts = await prisma.account.count();
    const deals = await prisma.activeDeal.count();
    const users = await prisma.authUser.count();
    const sessions = await prisma.authSession.count();
    
    console.log('=== Database Content ===');
    console.log('Contacts:', contacts);
    console.log('Accounts:', accounts);
    console.log('Deals:', deals);
    console.log('Users:', users);
    console.log('Active Sessions:', sessions);
    
    if (contacts > 0) {
      const sampleContact = await prisma.contact.findFirst();
      console.log('\nSample Contact:', sampleContact?.firstName, sampleContact?.lastName);
    }
    
    if (users > 0) {
      const sampleUser = await prisma.authUser.findFirst();
      console.log('Sample User:', sampleUser?.email);
    }
    
  } catch (error) {
    console.error('Database error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkData();
