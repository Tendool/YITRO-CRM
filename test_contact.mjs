import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function testContact() {
  try {
    console.log('=== Creating Test Contact ===');
    
    // Create a test contact
    const testContact = await prisma.contact.create({
      data: {
        firstName: 'Test',
        lastName: 'User',
        emailAddress: 'test@example.com',
        createdBy: 'user-1726749483562-87cc33il', // The user ID we found
        updatedBy: 'user-1726749483562-87cc33il',
        owner: 'admin@yitrobc.net'
      }
    });
    
    console.log('Test contact created:', testContact.firstName, testContact.lastName);
    console.log('Contact ID:', testContact.id);
    
    // Verify it exists
    const count = await prisma.contact.count();
    console.log('Total contacts now:', count);
    
  } catch (error) {
    console.error('Test contact creation error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

testContact();
