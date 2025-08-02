#!/bin/bash

# GibbonEdu Docker Startup Script
set -e

echo "🚀 Starting GibbonEdu Docker Environment..."

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  No .env file found. Copying from example..."
    cp .env.example .env
    echo "✅ Created .env file. Please edit it with your configuration before starting."
    exit 1
fi

# Load environment variables
source .env

# Validate required variables
required_vars=("DB_ROOT_PASSWORD" "DB_NAME" "DB_USER" "DB_PASSWORD" "GIBBON_URL")
missing_vars=()

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "❌ Missing required environment variables:"
    for var in "${missing_vars[@]}"; do
        echo "  - $var"
    done
    exit 1
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p logs/nginx logs/php mysql/data uploads sessions

# Set permissions
echo "🔐 Setting permissions..."
chmod 755 logs/nginx logs/php mysql/data uploads sessions
chmod -R 755 ../

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Build and start services
echo "🏗️  Building and starting services..."
docker-compose up --build -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker-compose exec -T db mysqladmin ping -h localhost --silent; then
        echo "✅ Database is ready!"
        break
    fi
    
    attempt=$((attempt + 1))
    echo "Waiting... ($attempt/$max_attempts)"
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Database failed to start. Check logs with 'docker-compose logs db'"
    exit 1
fi

# Wait for application to be ready
echo "⏳ Waiting for application to be ready..."
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -f http://localhost/health >/dev/null 2>&1; then
        echo "✅ Application is ready!"
        break
    fi
    
    attempt=$((attempt + 1))
    echo "Waiting... ($attempt/$max_attempts)"
    sleep 3
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Application failed to start. Check logs with 'docker-compose logs app'"
    exit 1
fi

# Run database migrations if needed
echo "🔄 Checking for database updates..."
if [ -f "../gibbon.sql" ]; then
    echo "📊 Importing database schema..."
    docker-compose exec -T db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} < ../gibbon.sql
    echo "✅ Database schema imported."
fi

# Display status
echo ""
echo "🎉 GibbonEdu Docker Environment is ready!"
echo ""
echo "📊 Services Status:"
docker-compose ps
echo ""
echo "🌐 Access GibbonEdu at: http://${GIBBON_URL}"
echo ""
echo "📋 Useful Commands:"
echo "  View logs:     docker-compose logs -f [service]"
echo "  Stop services: docker-compose down"
echo "  Restart:       docker-compose restart"
echo "  Update:        docker-compose pull && docker-compose up -d"
echo ""
echo "📁 Project location: /workspace/gibbon-core"
echo "🐳 Docker files:     /workspace/docker"

