#!/bin/bash

fello_build_and_start_pods() {
    cd /run/media/Data/GS/Projects/Fello/podman-setup

    pre_stage_setup() {
        if [ "$(sysctl -n net.ipv4.ip_unprivileged_port_start)" != "80" ]; then
            sudo sysctl net.ipv4.ip_unprivileged_port_start=80
        fi
        source .env

        mkdir -p "$MYSQL_DATA_PATH"
        mkdir -p "$LOGS_PATH/mysql"
        mkdir -p "$LOGS_PATH/nginx"
        mkdir -p "$LOGS_PATH/php-fpm"

        echo "🔧 Fixing Laravel storage permissions..."
        chmod -R 777 $FELLO_IMS_PATH/storage 2>/dev/null || true
        chmod -R 777 $FELLO_NEW_PATH/storage 2>/dev/null || true
        chmod -R 777 $FC_INVENTORY_API_PATH/storage 2>/dev/null || true

        podman network exists $FELLO_NETWORK || podman network create $FELLO_NETWORK
        podman build -t fello-php-fpm:8.2 config/php-fpm/
    }

    create_pods() {
        podman pod exists fello_db && podman pod stop fello_db && podman pod rm fello_db
        podman pod create --name fello_db --publish $PMA_PORT:80 --network $FELLO_NETWORK

        podman pod exists fello_web && podman pod stop fello_web && podman pod rm fello_web
        podman pod create --name fello_web --publish $NGINX_PORT:80 --network $FELLO_NETWORK

        build_db_pod
        build_web_pod
    }

    build_db_pod() {
        build_mysql_container
        build_phpmyadmin_container
        build_redis_container
    }

    build_mysql_container() {
        podman run -d \
            --pod fello_db \
            --name fello_mysql8 \
            -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
            -v $PWD/$MYSQL_DATA_PATH:/var/lib/mysql:Z \
            -v $PWD/$MYSQL_FILES_PATH:/files:Z \
            -v $PWD/$LOGS_PATH/mysql:/var/log/mysql:Z \
            -v $PWD/config/mysql/conf_override.cnf:/etc/mysql/conf.d/conf_override.cnf:Z \
            mysql:8.0.30
    }

    build_phpmyadmin_container() {
        podman run -d \
            --pod fello_db \
            --name fello_phpmyadmin \
            -e PMA_HOST=fello_mysql8 \
            -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
            phpmyadmin
    }

    build_redis_container() {
        podman run -d --name fello_redis --pod fello_db redis:alpine
    }

    build_web_pod() {
        build_php_fpm_container
        build_nginx_container
    }

    build_php_fpm_container() {
        podman run -d \
            --pod fello_web \
            --name fello_php_fpm \
            -v $PWD/$FC_INVENTORY_API_PATH:/var/www/fc-inventory-api:Z \
            -v $PWD/$FC_INVENTORY_PATH:/var/www/fc-inventory:Z \
            -v $PWD/$FELLO_EVENTBRITE_PATH:/var/www/fello-eventbrite:Z \
            -v $PWD/$FELLO_IMS_PATH:/var/www/fello-ims:Z \
            -v $PWD/$FELLO_NEW_PATH:/var/www/fello-new:Z \
            -v $PWD/$FELLO_SHOPIFY_CA_PATH:/var/www/fello-shopify-ca:Z \
            -v $PWD/$FELLO_SHOPIFY_PATH:/var/www/fello-shopify:Z \
            -v $PWD/$LOGS_PATH/php-fpm:/var/log/php-fpm:Z \
            fello-php-fpm:8.2

        # Disable xdebug by default
        podman exec fello_php_fpm mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.bak
        podman restart fello_php_fpm
    }

    build_nginx_container() {
        podman run -d \
            --pod fello_web \
            --name fello_nginx \
            -v $PWD/$FC_INVENTORY_API_PATH:/var/www/fc-inventory-api:Z \
            -v $PWD/$FC_INVENTORY_PATH:/var/www/fc-inventory:Z \
            -v $PWD/$FELLO_EVENTBRITE_PATH:/var/www/fello-eventbrite:Z \
            -v $PWD/$FELLO_IMS_PATH:/var/www/fello-ims:Z \
            -v $PWD/$FELLO_NEW_PATH:/var/www/fello-new:Z \
            -v $PWD/$FELLO_SHOPIFY_CA_PATH:/var/www/fello-shopify-ca:Z \
            -v $PWD/$FELLO_SHOPIFY_PATH:/var/www/fello-shopify:Z \
            -v $PWD/$LOGS_PATH/nginx:/var/log/nginx:Z \
            -v $PWD/config/nginx/conf.d/fc-inventory-api.conf:/etc/nginx/conf.d/fc-inventory-api.conf:Z \
            -v $PWD/config/nginx/conf.d/fc-inventory.conf:/etc/nginx/conf.d/fc-inventory.conf:Z \
            -v $PWD/config/nginx/conf.d/fello-eventbrite.conf:/etc/nginx/conf.d/fello-eventbrite.conf:Z \
            -v $PWD/config/nginx/conf.d/fello-ims.conf:/etc/nginx/conf.d/fello-ims.conf:Z \
            -v $PWD/config/nginx/conf.d/fello-new.conf:/etc/nginx/conf.d/fello-new.conf:Z \
            -v $PWD/config/nginx/conf.d/fello-shopify-ca.conf:/etc/nginx/conf.d/fello-shopify-ca.conf:Z \
            -v $PWD/config/nginx/conf.d/fello-shopify.conf:/etc/nginx/conf.d/fello-shopify.conf:Z \
            nginx:alpine
    }

    print_success_message() {
        echo "✅ All pods started successfully!"
        echo ""
        echo "🔗 Access URLs:"
        echo "   FC Inventory API:  http://fc-inventory-api.localhost:$NGINX_PORT"
        echo "   FC Inventory:      http://fc-inventory.localhost:$NGINX_PORT"
        echo "   Fello Eventbrite:  http://fello-eventbrite.localhost:$NGINX_PORT"
        echo "   Fello IMS:         http://fello-ims.localhost:$NGINX_PORT"
        echo "   Fello New:         http://fello-new.localhost:$NGINX_PORT"
        echo "   Fello Shopify CA:  http://fello-shopify-ca.localhost:$NGINX_PORT"
        echo "   Fello Shopify:     http://fello-shopify.localhost:$NGINX_PORT"
        echo "   PHPMyAdmin:        http://localhost:$PMA_PORT"
        echo ""
        echo "📝 Next steps:"
        echo "   1. Add entries to /etc/hosts:"
        echo "      127.0.0.1 fc-inventory-api.localhost"
        echo "      127.0.0.1 fc-inventory.localhost"
        echo "      127.0.0.1 fello-evenbrite.localhost"
        echo "      127.0.0.1 fello-ims.localhost"
        echo "      127.0.0.1 fello-new.localhost"
        echo "      127.0.0.1 fello-shopify-ca.localhost"
        echo "      127.0.0.1 fello-shopify.localhost"
        echo "   2. Run ./composer-install.sh to install PHP dependencies"
    }

    pre_stage_setup
    create_pods
    print_success_message
}
