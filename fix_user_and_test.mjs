// fix_user_and_test.mjs
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function fixUserAndTest() {
  try {
    console.log('=== Fixing User Data and Testing Signin ===');
    
    // 1. Get the current admin user
    const user = await prisma.authUser.findFirst({
      where: { email: 'admin@yitrobc.net' }
    });
    
    if (!user) {
      console.log('❌ No admin user found');
      return;
    }
    
    console.log('Current user state:');
    console.log(`- Email: ${user.email}`);
    console.log(`- Active: ${user.isActive}`);
    console.log(`- Email Verified: ${user.emailVerified}`);
    console.log(`- Role: ${user.role}`);
    
    // 2. Fix the user data - ensure isActive is properly set
    const updatedUser = await prisma.authUser.update({
      where: { id: user.id },
      data: {
        isActive: true,
        emailVerified: true,
        role: user.role || 'ADMIN'
      }
    });
    
    console.log('\n✅ User data updated');
    
    // 3. Test both passwords to confirm which one works
    const passwords = ['admin123', 'admain123'];
    let correctPassword = null;
    
    for (const pwd of passwords) {
      const match = await bcrypt.compare(pwd, user.passwordHash);
      if (match) {
        correctPassword = pwd;
        console.log(`✅ Correct password confirmed: "${pwd}"`);
        break;
      }
    }
    
    if (!correctPassword) {
      console.log('❌ Neither password works. Let\'s reset it to "admin123"');
      
      const newHash = await bcrypt.hash('admin123', 10);
      await prisma.authUser.update({
        where: { id: user.id },
        data: { passwordHash: newHash }
      });
      
      correctPassword = 'admin123';
      console.log('✅ Password reset to "admin123"');
    }
    
    // 4. Clear old sessions and test the API
    await prisma.authSession.deleteMany({
      where: { userId: user.id }
    });
    
    console.log('\n=== API Test Instructions ===');
    console.log('Now test the signin API with:');
    console.log('');
    console.log('curl -X POST http://localhost:3000/api/auth/signin \\');
    console.log('  -H "Content-Type: application/json" \\');
    console.log(`  -d '{"email":"admin@yitrobc.net","password":"${correctPassword}"}' \\`);
    console.log('  -i');
    console.log('');
    console.log('Also test with the user account:');
    console.log('curl -X POST http://localhost:3000/api/auth/signin \\');
    console.log('  -H "Content-Type: application/json" \\');
    console.log(`  -d '{"email":"user@yitro.com","password":"user123"}' \\`);
    console.log('  -i');
    console.log('');
    
    // 5. Check if we have the regular user too
    const regularUser = await prisma.authUser.findFirst({
      where: { email: 'user@yitro.com' }
    });
    
    if (regularUser) {
      // Fix regular user too
      await prisma.authUser.update({
        where: { id: regularUser.id },
        data: {
          isActive: true,
          emailVerified: true,
          role: regularUser.role || 'USER'
        }
      });
      console.log('✅ Regular user data also updated');
    } else {
      console.log('❌ Regular user not found - you may need to create it');
    }
    
  } catch (error) {
    console.error('❌ Fix failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

fixUserAndTest();
