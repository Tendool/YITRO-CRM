#!/bin/bash

# DealHub CRM - Database Initialization Script

set -e

echo "🗄️  Initializing DealHub CRM database..."

# Create data directory if it doesn't exist
DATA_DIR="./data"
if [ ! -d "$DATA_DIR" ]; then
    echo "📁 Creating data directory..."
    mkdir -p "$DATA_DIR"
fi

# Set environment for local development if not set
if [ -z "$DATABASE_URL" ]; then
    export DATABASE_URL="file:./data/production.db"
fi

echo "📊 Database URL: $DATABASE_URL"

# Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate

# Run database migrations
echo "🚀 Running database migrations..."
npx prisma migrate deploy

# Check if database is empty and seed if needed
echo "🌱 Checking if database needs seeding..."
if [ -f "server/db/setup-test-accounts.ts" ]; then
    echo "🌱 Seeding database with test data..."
    npm run db:seed
else
    echo "ℹ️  No seed data found, skipping seeding"
fi

# Set proper permissions for database file
if [ -f "./data/production.db" ]; then
    chmod 644 ./data/production.db
    echo "✅ Database permissions set"
fi

echo "✅ Database initialization completed!"
echo "📊 Database location: $DATABASE_URL"
