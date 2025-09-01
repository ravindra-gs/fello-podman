#!/bin/bash

# COMMON STEPS
## Load environment variables
source .env

echo "🚀 Starting Fello Podman Setup..."

## Create network if it doesn't exist
echo "📡 Creating network..."
podman network exists $FELLO_NETWORK || podman network create $FELLO_NETWORK

## Create volumes if they don't exist
echo "💾 Creating volumes..."
mkdir -p $MYSQL_DATA_PATH
mkdir -p $LOGS_PATH/mysql
mkdir -p $LOGS_PATH/nginx
mkdir -p $LOGS_PATH/php-fpm

## Fix volume permissions for rootless Podman
echo "🔧 Setting volume permissions..."
chown -R $(id -u):$(id -g) volumes/ 2>/dev/null || true
chmod -R 755 volumes/

## Fix Laravel storage permissions (requires sudo for root-owned files)
echo "🔧 Fixing Laravel storage permissions..."
echo "   Note: Run 'sudo find /run/media/Data/GS/Projects/Fello/*/storage -user root -exec chown ravindra-gs:ravindra-gs {} \;' if permission errors occur"
chmod -R 777 $FELLO_IMS_PATH/storage 2>/dev/null || true
chmod -R 777 $FELLO_NEW_PATH/storage 2>/dev/null || true
chmod -R 777 $FC_INVENTORY_API_PATH/storage 2>/dev/null || true

## Build PHP-FPM image
echo "🏗️  Building PHP-FPM image..."
podman build -t fello-php-fpm:8.2 config/php-fpm/

# WEB SERVICE STEPS
## Start Web Services Pod
echo "🌐 Starting Web Services Pod..."
podman pod exists fello-web-pod && podman pod stop fello-web-pod && podman pod rm fello-web-pod
podman pod create --name fello-web-pod \
    --publish $NGINX_PORT:80 \
    --network $FELLO_NETWORK

## Run MySQL Container in web pod
echo "🗄️  Starting MySQL in Web Pod..."
podman run -d \
    --name fello-mysql8 \
    --pod fello-web-pod \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -v $PWD/$MYSQL_DATA_PATH:/var/lib/mysql:Z \
    -v $PWD/$MYSQL_FILES_PATH:/files:Z \
    -v $PWD/$LOGS_PATH/mysql:/var/log/mysql:Z \
    -v $PWD/config/mysql/conf_override.cnf:/etc/mysql/conf.d/conf_override.cnf:Z \
    mysql:8.0.30

## Create separate Database Management Pod
echo "🗄️  Starting Database Management Pod..."
podman pod exists fello-db-pod && podman pod stop fello-db-pod && podman pod rm fello-db-pod
podman pod create --name fello-db-pod \
    --publish $PMA_PORT:80 \
    --network $FELLO_NETWORK

## Run PHPMyAdmin Container in separate pod
podman run -d \
    --name fello-phpmyadmin \
    --pod fello-db-pod \
    -e PMA_HOST=fello-mysql8 \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    phpmyadmin

## Run Redis Container in web pod
echo "📦 Starting Redis in Web Pod..."
podman run -d \
    --name fello-redis \
    --pod fello-web-pod \
    redis:alpine

# --add-host=mysql8:$(podman inspect fello-db-pod --format '{{.InfraContainer.State.Network.IPAddress}}') \
## PHP-FPM Container
podman run -d \
    --name fello-php-fpm \
    --pod fello-web-pod \
    -v $PWD/$FC_INVENTORY_API_PATH:/var/www/fc-inventory-api:Z \
    -v $PWD/$FC_INVENTORY_PATH:/var/www/fc-inventory:Z \
    -v $PWD/$FELLO_IMS_PATH:/var/www/fello-ims:Z \
    -v $PWD/$FELLO_NEW_PATH:/var/www/fello-new:Z \
    -v $PWD/$LOGS_PATH/php-fpm:/var/log/php-fpm:Z \
    fello-php-fpm:8.2

# Nginx Container
podman run -d \
    --name fello-nginx \
    --pod fello-web-pod \
    -v $PWD/config/nginx/conf.d/fc-inventory-api.conf:/etc/nginx/conf.d/fc-inventory-api.conf:Z \
    -v $PWD/config/nginx/conf.d/fc-inventory.conf:/etc/nginx/conf.d/fc-inventory.conf:Z \
    -v $PWD/config/nginx/conf.d/fello-ims.conf:/etc/nginx/conf.d/fello-ims.conf:Z \
    -v $PWD/config/nginx/conf.d/fello-new.conf:/etc/nginx/conf.d/fello-new.conf:Z \
    -v $PWD/$FC_INVENTORY_API_PATH:/var/www/fc-inventory-api:Z \
    -v $PWD/$FC_INVENTORY_PATH:/var/www/fc-inventory:Z \
    -v $PWD/$FELLO_IMS_PATH:/var/www/fello-ims:Z \
    -v $PWD/$FELLO_NEW_PATH:/var/www/fello-new:Z \
    -v $PWD/$LOGS_PATH/nginx:/var/log/nginx:Z \
    nginx:alpine

echo "✅ All pods started successfully!"
echo ""
echo "🔗 Access URLs:"
echo "   FC Inventory API:  http://fc-inventory-api.localhost:$NGINX_PORT"
echo "   FC Inventory:      http://fc-inventory.localhost:$NGINX_PORT"
echo "   Fello IMS:         http://fello-ims.localhost:$NGINX_PORT"
echo "   Fello New:         http://fello-new.localhost:$NGINX_PORT"
echo "   PHPMyAdmin:        http://localhost:$PMA_PORT"
echo ""
echo "📝 Next steps:"
echo "   1. Add entries to /etc/hosts:"
echo "      127.0.0.1 fc-inventory-api.localhost"
echo "      127.0.0.1 fc-inventory.localhost"
echo "      127.0.0.1 fello-ims.localhost"
echo "      127.0.0.1 fello-new.localhost"
echo "   2. Run ./composer-install.sh to install PHP dependencies"