#!/usr/bin/env node
/**
 * DealHub CRM Platform - Startup Script
 *
 * This script starts the CRM server with all necessary configurations.
 * It handles database connections, server setup, and error handling.
 */

// Check if user wants development mode
const args = process.argv.slice(2);
if (args.includes('dev') || args.includes('development')) {
  console.log('🚀 Starting development environment...');
  console.log('Frontend will be available at: http://localhost:8080');
  console.log('API will be available at: http://localhost:3001');
  console.log('');
  
  // Use the existing development setup
  import('child_process').then(({ spawn }) => {
    const devProcess = spawn('npm', ['run', 'dev:full'], { 
      stdio: 'inherit',
      shell: true 
    });
    
    process.on('SIGTERM', () => {
      devProcess.kill();
      process.exit(0);
    });
    
    process.on('SIGINT', () => {
      devProcess.kill();
      process.exit(0);
    });
  });
} else {
  // Production mode
  console.log('🚀 Starting production server...');
  
  // Load environment variables before importing the application
  import('dotenv').then(({ config }) => {
    config();
    import("./dist/server/node-build.mjs");
  });
}
