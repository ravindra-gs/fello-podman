# Fello Project - Podman Setup

Complete containerized environment for Fello applications using Podman on Fedora with SELinux.

## Quick Setup

### 1. Start Services
```bash
cd /path/to/Fello/podman-setup
./start-pods.sh
```

### 2. Configure Host Resolution
```bash
echo "127.0.0.1 fc-inventory-api.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 fc-inventory.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 fello-ims.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 fello-new.localhost" | sudo tee -a /etc/hosts
```

### 3. Install Dependencies
```bash
./composer-install.sh
```

## Application Access

- **FC Inventory API**: http://fc-inventory-api.localhost:8080
- **FC Inventory**: http://fc-inventory.localhost:8080  
- **Fello IMS**: http://fello-ims.localhost:8080
- **Fello New**: http://fello-new.localhost:8080
- **phpMyAdmin**: http://localhost:9080

## Environment Configuration

### Application .env Files

Update each Laravel application's `.env` file:

#### Database Configuration (All Apps)
```env
DB_CONNECTION=mysql
DB_HOST=fello-mysql8
DB_PORT=3306
DB_DATABASE=your_database_name
DB_USERNAME=root
DB_PASSWORD=ravindra
```

#### Server-to-Server API Calls
For applications calling fc-inventory-api internally:

**fello-new/.env**:
```env
IMS_URL=http://fello-nginx:8081/
```

**fello-ims/.env**:
```env
FC_API_URL=http://fello-nginx:8081/
```

### System .env File (podman-setup/.env)
```env
MYSQL_ROOT_PASSWORD=ravindra
MYSQL_PORT=3306
PMA_PORT=9080
FELLO_NETWORK=fello-network
NGINX_PORT=8080

# Project paths - adjust as needed
FELLO_IMS_PATH=../fello-ims
FELLO_NEW_PATH=../fello-new
FC_INVENTORY_API_PATH=../fc-inventory-api
FC_INVENTORY_PATH=../fc-inventory
MYSQL_DATA_PATH=volumes/mysql
MYSQL_FILES_PATH=volumes/mysql-files
LOGS_PATH=volumes/logs
```

## Permission Fixes

### Laravel Storage Permissions
If you encounter Laravel log/session permission errors:

```bash
# Fix ownership (run as root)
sudo find /run/media/Data/GS/Projects/Fello/fello-ims/storage -user root -exec chown ravindra-gs:ravindra-gs {} \;
sudo find /run/media/Data/GS/Projects/Fello/fello-new/storage -user root -exec chown ravindra-gs:ravindra-gs {} \;
sudo find /run/media/Data/GS/Projects/Fello/fc-inventory-api/storage -user root -exec chown ravindra-gs:ravindra-gs {} \;

# Set permissions
chmod -R 777 /run/media/Data/GS/Projects/Fello/fello-ims/storage
chmod -R 777 /run/media/Data/GS/Projects/Fello/fello-new/storage
chmod -R 777 /run/media/Data/GS/Projects/Fello/fc-inventory-api/storage
```

### Automated Fix
```bash
./fix-permissions.sh  # Stops containers, fixes permissions, restarts
```

## Management Commands

### Daily Operations
```bash
./start-pods.sh     # Full start (rebuilds if needed)
./stop-pods.sh      # Stop all services
./status-pods.sh    # Check status
```

### Quick Start/Stop (No Rebuild)
```bash
./simple-start.sh   # Quick start existing containers
./simple-stop.sh    # Quick stop (preserves containers)
```

## Database Access

### phpMyAdmin
- URL: http://localhost:9080
- Username: `root`
- Password: `ravindra`

### Command Line
```bash
podman exec -it fello-mysql8 mysql -u root -p
```

## Troubleshooting

### View Logs
```bash
# Container logs
podman logs fello-nginx
podman logs fello-php-fpm
podman logs fello-mysql8
podman logs fello-phpmyadmin

# Application logs  
tail -f volumes/logs/nginx/error.log
tail -f /path/to/fello-ims/storage/logs/laravel.log
```

### Access Containers
```bash
podman exec -it fello-php-fpm bash
podman exec -it fello-nginx sh
```

### Common Issues

**502 Bad Gateway**: Check PHP-FPM logs and restart services
**Permission Denied**: Run permission fix commands above
**Database Connection**: Verify `DB_HOST=fello-mysql8` in .env files
**API Calls Failing**: Use `http://fello-nginx:8081/` for internal calls

### Complete Reset
```bash
./stop-pods.sh
./start-pods.sh  # Rebuilds everything
```

## Architecture

- **Web Services Pod** (port 8080): Nginx + PHP-FPM + applications
- **Database Pod** (port 9080): MySQL + phpMyAdmin
- **Internal API Port**: 8081 for container-to-container communication
- **SELinux Compatible**: All volumes use `:Z` flags
- **Rootless**: Runs without requiring root privileges

---

**Generated with [Claude Code](https://claude.ai/code)**