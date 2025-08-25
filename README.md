# Fello Project - Podman Setup

This directory contains a complete Podman-based replacement for the Docker Compose setup, designed specifically for Fedora with SELinux enabled.

## Architecture

The setup uses a **2-pod architecture**:

### Pod 1: Web Services (`fello-web-pod`)

- **Nginx** - Web server with virtual hosts
- **PHP-FPM 8.2** - PHP processor using php:8.2-fpm-bullseye
- **Port**: 80 (HTTP)

### Pod 2: Database (`fello-db-pod`)  

- **MySQL 8.0.30** - Database server
- **PHPMyAdmin** - Database administration interface
- **Ports**: 3306 (MySQL), 9080 (PHPMyAdmin)

## Supported Applications

The setup provides nginx virtual hosts for:

- **FC Inventory API** - `http://fc-inventory-api.localhost`
- **FC Inventory** - `http://fc-inventory.localhost`
- **Fello IMS** - `http://fello-ims.localhost`
- **Fello New** - `http://fello-new.localhost`

## Prerequisites

1. **Podman** installed on Fedora
2. **SELinux** enabled (uses `:Z` volume flags)
3. **Root or rootless** Podman configuration

## Quick Start

### 1. Initial Setup

```bash
# Navigate to the podman-setup directory
cd /path/to/Fello/podman-setup

# Start all services (first time)
./start-pods.sh
```

### 2. Configure /etc/hosts

Add these entries to `/etc/hosts`:

```bash
echo "127.0.0.1 fc-inventory-api.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 fc-inventory.localhost" | sudo tee -a /etc/hosts  
echo "127.0.0.1 fello-ims.localhost" | sudo tee -a /etc/hosts
echo "127.0.0.1 fello-new.localhost" | sudo tee -a /etc/hosts
```

### 3. Install PHP Dependencies

```bash
# Install Composer dependencies for all projects
./composer-install.sh
```

## Management Scripts

### Core Scripts

- **`start-pods.sh`** - Full setup (creates pods, builds images, starts containers)
- **`stop-pods.sh`** - Stop and remove all pods
- **`status-pods.sh`** - Show status of pods, containers, and URLs

### Quick Scripts  

- **`simple-start.sh`** - Quick start existing pods (no rebuild)
- **`simple-stop.sh`** - Quick stop pods (preserve for restart)

### Utility Scripts

- **`composer-install.sh`** - Install PHP dependencies in all projects

## Configuration

### Environment Variables (`.env`)

```bash
MYSQL_ROOT_PASSWORD=ravindra
MYSQL_PORT=3306
PMA_PORT=9080
FELLO_NETWORK=fello-network
NGINX_PORT=80
```

### MySQL Configuration

- **Custom config**: `config/mysql/my.cnf`
- **Data persistence**: `volumes/mysql/`
- **Log location**: `volumes/logs/mysql/`

### Nginx Configuration  

- **Main config**: `config/nginx/nginx.conf`
- **Virtual hosts**: `config/nginx/conf.d/*.conf`
- **Log location**: `volumes/logs/nginx/`

### PHP-FPM Configuration

- **Custom config**: `config/php-fpm/php-fpm.conf`
- **Dockerfile**: `config/php-fpm/Dockerfile`
- **Log location**: `volumes/logs/php-fpm/`

## SELinux Compatibility

All volume mounts use the `:Z` flag for SELinux compatibility:

- Automatically relabels mounted volumes
- Works with enforcing SELinux policies
- No manual SELinux configuration required

## Data Persistence

Data is stored in the `volumes/` directory:

```
volumes/
├── mysql/          # MySQL data files
└── logs/           # Application logs
    ├── mysql/      
    ├── nginx/      
    └── php-fpm/    
```

## Troubleshooting

### Check Status

```bash
./status-pods.sh
```

### View Logs

```bash
# Container logs
podman logs fello-mysql8
podman logs fello-nginx  
podman logs fello-php-fpm
podman logs fello-phpmyadmin

# Application logs
tail -f volumes/logs/nginx/fc-inventory-api.error.log
tail -f volumes/logs/mysql/error.log
tail -f volumes/logs/php-fpm/error.log
```

### Rebuild Services

```bash
# Stop everything
./stop-pods.sh

# Start fresh (rebuilds images)
./start-pods.sh
```

### Access Containers

```bash
# Access PHP-FPM container
podman exec -it fello-php-fpm bash

# Access MySQL container  
podman exec -it fello-mysql8 mysql -u root -p

# Access Nginx container
podman exec -it fello-nginx sh
```

## Network Architecture

- **Network**: `fello-network` (custom bridge network)
- **Pod Communication**: Containers within pods use localhost
- **Inter-pod Communication**: Via network name resolution
- **External Access**: Through published ports

## Development Workflow

1. **Start Development**:

   ```bash
   ./simple-start.sh
   ```

2. **Work on Code**: Edit files in project directories

3. **View Changes**: Refresh browser (PHP files reload automatically)

4. **Stop Development**:

   ```bash
   ./simple-stop.sh
   ```

5. **Install New Dependencies**:

   ```bash
   podman exec -it fello-php-fpm composer install
   ```

## Migration from Docker

This Podman setup replaces:

- `fello-mysql/docker-compose.yml` → Database pod
- Individual project Docker files → Web services pod  
- Docker networks → Podman network
- Docker volumes → Local volumes with `:Z` flags

### Key Improvements

- **SELinux Compatible**: No SELinux configuration needed
- **Centralized Management**: Single location for all services
- **Better Resource Control**: Pods provide process grouping
- **Enhanced Security**: Rootless container support
- **Unified Logging**: Centralized log directory

## Support

For issues with this Podman setup:

1. Check logs using troubleshooting commands above
2. Verify SELinux is not blocking operations  
3. Ensure all project directories exist at expected paths
4. Confirm Podman and network configuration

---

**Generated with [Claude Code](https://claude.ai/code)**
