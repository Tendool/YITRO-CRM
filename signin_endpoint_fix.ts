// signin_endpoint_fix.ts - Template for fixing signin endpoint

import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

const prisma = new PrismaClient();

// This should be part of your server/index.ts signin route
export async function signinHandler(req: any, res: any) {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email and password are required' 
      });
    }

    // 1. Find user by email
    const user = await prisma.authUser.findUnique({
      where: { email: email.toLowerCase() }
    });

    if (!user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Invalid credentials' 
      });
    }

    // 2. Check if user is active
    if (!user.isActive) {
      return res.status(401).json({ 
        success: false, 
        message: 'Account is inactive' 
      });
    }

    // 3. Verify password
    const passwordMatch = await bcrypt.compare(password, user.passwordHash);
    if (!passwordMatch) {
      return res.status(401).json({ 
        success: false, 
        message: 'Invalid credentials' 
      });
    }

    // 4. Clear old sessions for this user (optional - for single session per user)
    await prisma.authSession.updateMany({
      where: { 
        userId: user.id,
        isActive: true 
      },
      data: { isActive: false }
    });

    // 5. Create new session
    const tokenData = {
      userId: user.id,
      email: user.email,
      role: user.role,
      timestamp: Date.now()
    };
    
    const token = jwt.sign(tokenData, process.env.JWT_SECRET || 'default-secret', {
      expiresIn: '24h'
    });

    const session = await prisma.authSession.create({
      data: {
        userId: user.id,
        tokenHash: token, // In production, hash this token
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 hours
        isActive: true,
        ipAddress: req.ip || req.connection.remoteAddress || 'unknown',
        userAgent: req.headers['user-agent'] || 'unknown'
      }
    });

    // 6. Update user's last login
    await prisma.authUser.update({
      where: { id: user.id },
      data: { lastLogin: new Date() }
    });

    // 7. Set session cookie (important!)
    res.cookie('auth_token', token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 24 * 60 * 60 * 1000 // 24 hours
    });

    // 8. Return success response
    return res.status(200).json({
      success: true,
      message: 'Signed in successfully',
      user: {
        id: user.id,
        email: user.email,
        role: user.role
      },
      token: token // Only include if using token-based auth in frontend
    });

  } catch (error) {
    console.error('Signin error:', error);
    return res.status(500).json({ 
      success: false, 
      message: 'Internal server error' 
    });
  }
}

// Middleware to verify authentication for protected routes
export async function verifyAuth(req: any, res: any, next: any) {
  try {
    const token = req.cookies?.auth_token || req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ 
        success: false, 
        message: 'No authentication token provided' 
      });
    }

    // Verify JWT
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'default-secret') as any;
    
    // Check if session is still active in database
    const session = await prisma.authSession.findFirst({
      where: {
        tokenHash: token,
        isActive: true,
        expiresAt: { gt: new Date() }
      },
      include: { user: true }
    });

    if (!session || !session.user.isActive) {
      return res.status(401).json({ 
        success: false, 
        message: 'Invalid or expired session' 
      });
    }

    // Add user to request object
    req.user = session.user;
    next();

  } catch (error) {
    console.error('Auth verification error:', error);
    return res.status(401).json({ 
      success: false, 
      message: 'Invalid authentication token' 
    });
  }
}
