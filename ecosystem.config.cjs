module.exports = {
  apps: [{
    name: 'start',
    script: './start.js',
    cwd: '/home/ec2-user/Uploaded_YITRO-NEW',
    env: {
      NODE_ENV: 'production',
      PORT: 3000,
      DATABASE_URL: 'file:/home/ec2-user/Uploaded_YITRO-NEW/data/production.db',
      DOMAIN: 'https://crm.yitroglobal.com',
      SMTP_HOST: 'smtp.gmail.com',
      SMTP_PORT: 587,
      SMTP_USER: 'admin@yitro.com',
      SMTP_PASS: 'your-app-password',
      FROM_EMAIL: 'noreply@crm.yitroglobal.com'
    }
  }]
}
