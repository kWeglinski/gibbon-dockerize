# GibbonEdu Docker Setup

A production‑ready Docker configuration for **GibbonEdu**, providing an easy way to run the application with all required services (MySQL, PHP‑FPM, Nginx, Redis) in containers.

## 📁 Repository Layout
```
/docker/
├── docker-compose.yml   # Orchestrates all containers
├── Dockerfile           # Builds the PHP‑FPM image
├── php.ini              # Custom PHP configuration
├── nginx/
│   ├── nginx.conf       # Main Nginx config
│   └── conf.d/
│       ├── default.conf# Default site config
│       └── gibbon.conf # Gibbon‑specific rules
├── .env.example         # Template for environment variables
├── startup.sh           # Starts the stack
├── backup.sh            # Backup utilities
└── healthcheck.sh       # Service health checks
```

## 🚀 Quick Start

1. **Copy environment template**
   ```bash
   cp docker/.env.example .env
   ```
2. **Edit `.env`** – set required variables (`DB_ROOT_PASSWORD`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `GIBBON_URL`, etc.).
3. **Start the stack**
   ```bash
   ./docker/startup.sh
   ```

The application will be reachable at the URL defined in `GIBBON_URL` (default: `http://gibbon.local`).

## ⚙️ Configuration

| Variable          | Description                     | Default |
|-------------------|---------------------------------|---------|
| `GIBBON_URL`      | Public URL for GibbonEdu        | `gibbon.local` |
| `TIMEZONE`        | System timezone                 | `UTC` |
| `DB_ROOT_PASSWORD`| MySQL root password            | *required* |
| `DB_NAME`         | Database name                   | `gibbon` |
| `DB_USER`         | Database user                   | `gibbon_user` |
| `DB_PASSWORD`     | Database password               | *required* |
| `REDIS_HOST`      | Redis host (`false` to disable) | `redis` |
| `SECRET_KEY`      | Application secret key          | Auto‑generated |

### Required variables
- `DB_ROOT_PASSWORD`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
- `GIBBON_URL`

## 📦 Services Overview

| Service   | Image                | Port (internal) |
|-----------|----------------------|-----------------|
| MySQL     | `mysql:8.0`          | 3306            |
| PHP‑FPM   | Custom (`php:8.1-fpm-alpine`) | 9000 |
| Nginx     | `nginx:alpine`       | 80, 443         |
| Redis     | `redis:alpine`       | 6379            |

## 📋 Management Commands

```bash
# Start all services
./docker/startup.sh

# Stop everything
docker-compose down

# Restart containers
docker-compose restart

# Follow logs (replace <service> with app, db, web, redis)
docker-compose logs -f <service>
```

### Backup & Restore
```bash
# Create a backup
./docker/backup.sh

# List backups
ls -la backups/

# Restore (manual)
tar -xzf backups/<backup_file>.tar.gz
```

## 🔧 Customization

- **PHP extensions** – edit `Dockerfile` and add `RUN docker-php-ext-install <extension>`.
- **Nginx rules** – modify files under `nginx/conf.d/`.
- **Database init scripts** – place custom `.sql` files in a `mysql/` folder (executed on first run).

## 🛡️ Security & Performance

- Non‑root user inside the PHP container.
- OPCache enabled for PHP bytecode caching.
- Gzip compression and static file caching via Nginx.
- Redis used for session storage and caching.

## 🔄 Updating GibbonEdu

```bash
# Stop containers
docker-compose down

# Pull latest code (adjust path if needed)
cd /workspace/gibbon-core
git pull origin main

# Restart stack
cd /workspace/docker
./startup.sh
```

## 🐛 Troubleshooting

- **Database errors** – `docker-compose logs db` and verify `.env` credentials.
- **PHP errors** – `docker-compose logs app`.
- **Nginx errors** – `docker-compose logs web`.

## 🤝 Contributing

Feel free to fork, improve Docker files, or add new scripts. This setup aims to be:

- Version‑agnostic (works with any GibbonEdu version supporting PHP 8.1+)
- Production‑ready (security, performance, monitoring)
- Easy to maintain (clear separation of concerns)

## 📄 License

This Docker configuration is provided **as‑is** for use with GibbonEdu. Ensure you comply with the original GibbonEdu license.
