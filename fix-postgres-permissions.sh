#!/bin/bash

# Fix PostgreSQL Permissions for yitro_admin user
echo "🔧 Fixing PostgreSQL permissions..."

# Connect to PostgreSQL and fix permissions
sudo -u postgres psql <<EOF
-- Connect to the yitro_crm database
\c yitro_crm;

-- Grant all privileges on schema public to yitro_admin
GRANT ALL ON SCHEMA public TO yitro_admin;

-- Grant usage and create privileges on schema public
GRANT USAGE, CREATE ON SCHEMA public TO yitro_admin;

-- Grant all privileges on all existing tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO yitro_admin;

-- Grant all privileges on all existing sequences
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO yitro_admin;

-- Grant all privileges on all existing functions
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO yitro_admin;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO yitro_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO yitro_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO yitro_admin;

-- Make yitro_admin owner of the database
ALTER DATABASE yitro_crm OWNER TO yitro_admin;

-- Verify permissions
\du yitro_admin
\dp

\q
EOF

echo "✅ PostgreSQL permissions fixed!"
echo "🧪 Testing database connection..."

# Test connection as yitro_admin
export PGPASSWORD='YitroSecure2024!'
psql -h localhost -U yitro_admin -d yitro_crm -c "SELECT 'Connection successful!' as status;"

if [ $? -eq 0 ]; then
    echo "✅ Database connection test passed!"
else
    echo "❌ Database connection test failed!"
fi

unset PGPASSWORD

