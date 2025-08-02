
#!/bin/bash

# GibbonEdu Docker Backup Script
set -e

echo "💾 Starting GibbonEdu Backup..."

# Load environment variables
source .env

# Create backup directory with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="backups/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

# Backup database
echo "📊 Backing up database..."
docker-compose exec -T db mysqldump -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} > "$BACKUP_DIR/database.sql"

# Backup uploads directory
echo "📁 Backing up uploads..."
docker-compose exec -T app tar -czf "$BACKUP_DIR/uploads.tar.gz" -C /var/www/html uploads

# Backup configuration files
echo "⚙️  Backing up configuration..."
cp .env "$BACKUP_DIR/"
docker-compose exec -T app tar -czf "$BACKUP_DIR/config.tar.gz" -C /var/www/html gibbon.php config*

# Create backup manifest
echo "📋 Creating backup manifest..."
cat > "$BACKUP_DIR/manifest.txt" << EOF
GibbonEdu Backup Manifest
========================
Backup Date: $(date)
Backup Version: Docker
Services Status:
$(docker-compose ps)

Files Included:
- database.sql (MySQL dump)
- uploads.tar.gz (User files)
- config.tar.gz (Configuration files)
- .env (Environment variables)

Backup Size: $(du -sh "$BACKUP_DIR" | cut -f1)
EOF

# Compress backup
echo "🗜️  Compressing backup..."
tar -czf "backups/gibbon_backup_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" .
rm -rf "$BACKUP_DIR"

# Clean old backups (keep last 7 days)
echo "🧹 Cleaning old backups..."
find backups/ -name "gibbon_backup_*.tar.gz" -mtime +7 -delete

echo "✅ Backup completed: backups/gibbon_backup_$TIMESTAMP.tar.gz"
echo "📁 Backup size: $(du -sh backups/gibbon_backup_$TIMESTAMP.tar.gz | cut -f1)"


