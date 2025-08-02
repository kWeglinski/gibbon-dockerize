

#!/bin/bash

# GibbonEdu Docker Health Check Script
set -e

echo "🏥 Starting health checks..."

# Load environment variables
source .env

# Check database health
echo "📊 Checking database health..."
if ! docker-compose exec -T db mysqladmin ping -h localhost --silent; then
    echo "❌ Database is not healthy"
    exit 1
fi

# Check application health
echo "🌐 Checking application health..."
if ! curl -f http://localhost/health >/dev/null 2>&1; then
    echo "❌ Application is not healthy"
    exit 1
fi

# Check Nginx health
echo "🔌 Checking Nginx health..."
if ! curl -f http://localhost/ >/dev/null 2>&1; then
    echo "❌ Nginx is not healthy"
    exit 1
fi

# Check Redis health (if enabled)
if [ "${REDIS_HOST:-redis}" != "false" ]; then
    echo "🔴 Checking Redis health..."
    if ! docker-compose exec -T redis redis-cli ping >/dev/null 2>&1; then
        echo "❌ Redis is not healthy"
        exit 1
    fi
fi

echo "✅ All services are healthy!"



