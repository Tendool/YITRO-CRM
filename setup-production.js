#!/usr/bin/env node

/**
 * Production Setup Helper for VS Code
 * This script helps you configure your Yitro CRM for production
 */

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

console.log("🚀 Yitro CRM - Production Setup Helper");
console.log("=====================================\n");

// Generate JWT Secret
const jwtSecret = crypto.randomBytes(64).toString("hex");

console.log("✅ Generated JWT Secret for production security");
console.log("📋 Copy these values for your production environment:\n");

console.log("🔐 JWT SECRET:");
console.log(jwtSecret);
console.log("");

// Create environment template
const envTemplate = `# Yitro CRM Production Environment Variables
# Copy these to your deployment platform (Netlify, Vercel, etc.)

# Database Configuration (Replace with your Neon database URL)
DATABASE_URL="postgresql://username:password@ep-xxx-xxx.region.aws.neon.tech/yitro_crm?sslmode=require"

# Security Configuration (Generated below)
STACK_SECRET_SERVER_KEY="${jwtSecret}"

# Application Configuration
NODE_ENV="production"
FRONTEND_URL="https://your-app-name.netlify.app"

# SMTP Email Configuration (Replace with your Gmail details)
SMTP_SERVICE="gmail"
SMTP_USER="your-email@gmail.com"
SMTP_PASSWORD="your-16-character-gmail-app-password"
`;

// Write to file
const envPath = path.join(process.cwd(), ".env.production");
fs.writeFileSync(envPath, envTemplate);

console.log("📝 Created .env.production file with your configuration template");
console.log("");

console.log("📋 NEXT STEPS:");
console.log("");
console.log("1. 🗄️  SET UP NEON DATABASE:");
console.log("   - Go to: https://console.neon.tech/");
console.log('   - Create project: "yitro-crm-production"');
console.log("   - Copy connection string");
console.log("");

console.log("2. 📧 SET UP GMAIL SMTP:");
console.log("   - Enable 2FA on Gmail: https://myaccount.google.com/security");
console.log('   - Generate App Password for "Yitro CRM"');
console.log("   - Copy 16-character password");
console.log("");

console.log("3. ⚙️  CONFIGURE ENVIRONMENT:");
console.log("   - Edit .env.production file");
console.log("   - Replace placeholder values with real credentials");
console.log("");

console.log("4. 🧪 TEST CONFIGURATION:");
console.log("   - Run: npm run test-config");
console.log("");

console.log("5. 🚀 DEPLOY:");
console.log("   - Push to GitHub");
console.log("   - Deploy to Netlify/Vercel");
console.log("   - Add environment variables to deployment platform");
console.log("");

console.log("🔐 JWT Secret (save this securely):");
console.log(jwtSecret);
console.log("");

console.log(
  "✅ Setup helper completed! Check .env.production file for next steps.",
);
