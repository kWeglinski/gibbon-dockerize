


# GibbonEdu Docker Setup

A production-ready Docker configuration for GibbonEdu, designed to be easily swappable with newer versions of the application.

## 📁 Directory Structure

```
/workspace/
├── gibbon-core/          # GibbonEdu application code (DO NOT MODIFY)
└── docker/               # Docker configuration files
    ├── docker-compose.yml     # Main orchestration file
    ├── Dockerfile             # PHP-FPM application container
    ├── php.ini               # PHP configuration
    ├── nginx/                # Nginx web server configuration
    │   ├── nginx.conf        # Main Nginx configuration
    │   └── conf.d/           # Site-specific configurations
    │       ├── default.conf  # Main site configuration
    │       └── gibbon.conf   # Gibbon-specific rules
    ├── mysql/                # Database initialization scripts
    │   └── init.sql         # Database setup and tables
    ├── .env.example         # Environment variables template
    ├── startup.sh           # Startup and initialization script
    ├── backup.sh            # Backup and restore utilities
    └── healthcheck.sh       # Health monitoring script
```

## 🚀 Quick Start

1. **Navigate to the docker directory:**
   ```bash
   cd /workspace/docker
   ```

2. **Configure environment variables:**
   ```bash
   cp .env.example .env
   nano .env  # Edit with your configuration
   ```

3. **Start the environment:**
   ```bash
   ./startup.sh
   ```

4. **Access GibbonEdu:**
   Open your browser and navigate to `http://gibbon.local` (or your configured URL)

## ⚙️ Configuration

### Environment Variables (.env)

| Variable | Description | Default |
|----------|-------------|---------|
| `GIBBON_URL` | GibbonEdu access URL | `gibbon.local` |
| `TIMEZONE` | System timezone | `UTC` |
| `DB_ROOT_PASSWORD` | MySQL root password | Required |
| `DB_NAME` | Database name | `gibbon` |
| `DB_USER` | Database username | `gibbon_user` |
| `DB_PASSWORD` | Database password | Required |
| `REDIS_HOST` | Redis host (false to disable) | `redis` |
| `SECRET_KEY` | Application secret key | Auto-generated |

### Required Configuration

Before starting, ensure you set these required variables in `.env`:
- `DB_ROOT_PASSWORD`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
- `GIBBON_URL`

## 🐳 Services Overview

### 1. Database (MySQL)
- **Image:** `mysql:8.0`
- **Port:** `3306` (internal)
- **Data Persistence:** Volume-mounted `/var/lib/mysql`
- **Initialization:** Database creation and user setup

### 2. Application (PHP-FPM)
- **Image:** Custom build based on `php:8.1-fpm-alpine`
- **Port:** `9000` (internal)
- **Features:**
  - PHP 8.1 with required extensions
  - OPCache enabled for performance
  - Non-root user security
  - Health monitoring

### 3. Web Server (Nginx)
- **Image:** `nginx:alpine`
- **Ports:** `80`, `443` (external)
- **Features:**
  - Gzip compression
  - Security headers
  - Static file caching
  - PHP processing

### 4. Cache (Redis)
- **Image:** `redis:alpine`
- **Port:** `6379` (internal)
- **Purpose:** Session storage and caching

## 📊 Management Commands

### Start/Stop Services
```bash
# Start all services
./startup.sh

# Stop all services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs -f [service]
```

### Backup and Restore
```bash
# Create backup
./backup.sh

# List backups
ls -la backups/

# Restore from backup (manual process)
tar -xzf backups/gibbon_backup_YYYYMMDD_HHMMSS.tar.gz
```

### Health Monitoring
```bash
# Check all services health
./healthcheck.sh

# Individual service checks
docker-compose ps
curl http://localhost/health
```

## 🔧 Customization

### Adding Custom PHP Extensions
Edit the `Dockerfile` to add additional extensions:
```dockerfile
RUN docker-php-ext-install [extension_name]
```

### Custom Nginx Configuration
Edit files in `nginx/conf.d/` to add custom rules or modify existing ones.

### Database Initialization
Custom SQL scripts can be added to `mysql/` directory and will be executed on first run.

## 🛡️ Security Features

- **Non-root user execution** in application container
- **File permission isolation** between services
- **Network segmentation** with dedicated bridge network
- **SSL/TLS ready** configuration (add certificates for HTTPS)
- **Security headers** in Nginx configuration
- **Database user isolation** with limited privileges

## 📈 Performance Optimizations

- **OPCache** for PHP bytecode caching
- **Gzip compression** for static assets
- **Static file caching** with appropriate headers
- **Redis caching** for sessions and data
- **Database connection pooling**

## 🔄 Updating GibbonEdu

1. **Stop current services:**
   ```bash
   docker-compose down
   ```

2. **Update GibbonEdu code:**
   ```bash
   cd /workspace/gibbon-core
   git pull origin main  # Or update to newer version
   ```

3. **Restart services:**
   ```bash
   cd /workspace/docker
   ./startup.sh
   ```

## 🐛 Troubleshooting

### Common Issues

1. **Database connection errors:**
   - Check database logs: `docker-compose logs db`
   - Verify credentials in `.env`
   - Ensure database is ready: `./healthcheck.sh`

2. **PHP application errors:**
   - Check PHP logs: `docker-compose logs app`
   - Verify file permissions
   - Check PHP configuration

3. **Nginx errors:**
   - Check Nginx logs: `docker-compose logs web`
   - Verify configuration syntax
   - Check file permissions for static files

### Log Locations
- **Application logs:** `docker-compose logs app`
- **Database logs:** `docker-compose logs db`
- **Web server logs:** `docker-compose logs web`
- **Redis logs:** `docker-compose logs redis`

## 📋 Production Considerations

### SSL/TLS Setup
1. Add SSL certificates to `nginx/ssl/`
2. Update `.env` with `SSL_ENABLED=true`
3. Configure URLs for HTTPS

### Resource Limits
- Adjust memory limits in `php.ini` based on available resources
- Set appropriate CPU shares in `docker-compose.yml`
- Configure database connection pooling

### Monitoring and Logging
- Set up log rotation for container logs
- Implement monitoring for resource usage
- Configure backup automation

## 🤝 Contributing

This Docker setup is designed to be:
- **Version-agnostic** - Works with GibbonEdu versions that support PHP 8.1+
- **Production-ready** - Includes security, performance, and monitoring features
- **Easy to maintain** - Clear separation of concerns and documentation

## 📄 License

This Docker setup is provided as-is for use with GibbonEdu. Please ensure compliance with GibbonEdu's license terms.

---

**Note:** This Docker setup is designed to work with the GibbonEdu application code located in `/workspace/gibbon-core`. Do not modify files in that directory. All customizations should be done through the Docker configuration files in `/workspace/docker/`.


