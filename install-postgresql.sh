#!/bin/bash

# PostgreSQL Installation Script for Ubuntu Server 216.48.190.58
# Run this script as root: sudo bash install-postgresql.sh

echo "🚀 Installing PostgreSQL on Ubuntu Server..."
echo "📍 Server: 216.48.190.58 (dealhub.yitrobc.net)"

# Update system
echo "📦 Updating system packages..."
apt update -y

# Install PostgreSQL
echo "🗄️ Installing PostgreSQL..."
apt install -y postgresql postgresql-contrib

# Start PostgreSQL service
echo "⚡ Starting PostgreSQL..."
systemctl start postgresql
systemctl enable postgresql

# Create database and user
echo "👤 Creating database and user..."
sudo -u postgres psql <<EOF
CREATE DATABASE yitro_crm;
CREATE USER yitro_admin WITH PASSWORD 'YitroSecure2024!';
GRANT ALL PRIVILEGES ON DATABASE yitro_crm TO yitro_admin;
ALTER USER yitro_admin CREATEDB;
\q
EOF

# Test connection
echo "🧪 Testing database connection..."
sudo -u postgres psql -d yitro_crm -c "SELECT 'PostgreSQL is working!' as status;"

echo "✅ PostgreSQL installation completed!"
echo ""
echo "📝 Database Details:"
echo "   Database: yitro_crm"
echo "   User: yitro_admin"
echo "   Password: YitroSecure2024!"
echo "   Connection: postgresql://yitro_admin:YitroSecure2024!@localhost:5432/yitro_crm"
