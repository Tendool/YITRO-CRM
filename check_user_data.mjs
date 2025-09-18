import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function checkUserData() {
  try {
    console.log('=== User Data Association Check ===');
    
    // Check contacts with owners
    const contactsWithOwners = await prisma.contact.findMany({
      where: { 
        owner: { not: null }
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        owner: true,
        createdBy: true
      },
      take: 3
    });
    
    console.log('Contacts with owners:', contactsWithOwners.length);
    contactsWithOwners.forEach(contact => {
      console.log('- Contact:', contact.firstName, contact.lastName, 'Owner:', contact.owner, 'CreatedBy:', contact.createdBy);
    });
    
    // Check if createdBy matches existing users
    const users = await prisma.authUser.findMany({
      select: { id: true, email: true }
    });
    
    console.log('\nAll users:');
    users.forEach(user => {
      console.log('- User:', user.email, 'ID:', user.id.substring(0, 8) + '...');
    });
    
  } catch (error) {
    console.error('User data check error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkUserData();
