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
        mkdir -p "$LOGS_PATH/php-fpm82"
        mkdir -p "$LOGS_PATH/php-fpm74"

        echo "🔧 Fixing Laravel storage permissions..."
        chmod -R 777 $API_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $IMS_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $V4_FELLO_COM_PATH/storage 2>/dev/null || true

        chmod -R 777 $ARAMARK_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $EVENTBRITE_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $GIVESMART_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $LEVY_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $MOBILECAUSE_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $SHOPIFY_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $SHOPIFYCA_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $SQURE_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $SQURECA_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $TASSEL_FELLO_COM_PATH/storage 2>/dev/null || true
        chmod -R 777 $TASSELCA_FELLO_COM_PATH/storage 2>/dev/null || true

        podman network exists $FELLO_NETWORK || podman network create $FELLO_NETWORK
        podman build -t fello-php-fpm:8.2 config/php-fpm8.2
        podman build -t fello-php-fpm:7.4 config/php-fpm7.4
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
            -v $PWD/$MYSQL_FILES_PATH:/files:ro,Z \
            -v $PWD/$LOGS_PATH/mysql:/var/log/mysql:Z \
            -v $PWD/config/mysql/conf_override.cnf:/etc/mysql/conf.d/conf_override.cnf:ro,Z \
            mysql:8.0.30
    }

    build_phpmyadmin_container() {
        podman run -d \
            --pod fello_db \
            --name fello_phpmyadmin \
            -e PMA_HOST=fello_mysql8 \
            -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
            -v $PWD/config/phpmyadmin/config.user.inc.php:/etc/phpmyadmin/config.user.inc.php:ro,Z \
            phpmyadmin
    }

    build_redis_container() {
        podman run -d --name fello_redis --pod fello_db redis:alpine
    }

    build_web_pod() {
        build_php_fpm82_container
        build_php_fpm74_container
        build_nginx_container
    }

    build_php_fpm82_container() {
        echo "🚀 Starting PHP-FPM 8.2 container..."

        podman run -d \
            --pod fello_web \
            --name fello_php_fpm82 \
            -v $PWD/$API_FELLO_COM_PATH:/var/www/api.fello.com:Z \
            -v $PWD/$V4_FELLO_COM_PATH:/var/www/v4.fello.com:Z \
            -v $PWD/$ARAMARK_FELLO_COM_PATH:/var/www/aramark.fello.com:Z \
            -v $PWD/$EVENTBRITE_FELLO_COM_PATH:/var/www/eventbrite.fello.com:Z \
            -v $PWD/$FELLO_COM_PATH:/var/www/fello.com:Z \
            -v $PWD/$GIVESMART_FELLO_COM_PATH:/var/www/givesmart.fello.com:Z \
            -v $PWD/$LEVY_FELLO_COM_PATH:/var/www/levy.fello.com:Z \
            -v $PWD/$MOBILECAUSE_FELLO_COM_PATH:/var/www/mobilecause.fello.com:Z \
            -v $PWD/$SHOPIFY_FELLO_COM_PATH:/var/www/shopify.fello.com:Z \
            -v $PWD/$SHOPIFYCA_FELLO_COM_PATH:/var/www/shopifyca.fello.com:Z \
            -v $PWD/$SQURE_FELLO_COM_PATH:/var/www/square.fello.com:Z \
            -v $PWD/$SQURECA_FELLO_COM_PATH:/var/www/squareca.fello.com:Z \
            -v $PWD/$TASSEL_FELLO_COM_PATH:/var/www/tassel.fello.com:Z \
            -v $PWD/$TASSELCA_FELLO_COM_PATH:/var/www/tasselca.fello.com:Z \
            -v $PWD/$LOGS_PATH/php-fpm82:/var/log/php-fpm:Z \
            fello-php-fpm:8.2
    }

    build_php_fpm74_container() {
        echo "🚀 Starting PHP-FPM 7.4 container..."

        podman run -d \
            --pod fello_web \
            --name fello_php_fpm74 \
            -v $PWD/$IMS_FELLO_COM_PATH:/var/www/ims.fello.com:Z \
            -v $PWD/$LOGS_PATH/php-fpm74:/var/log/php-fpm:Z \
            fello-php-fpm:7.4
    }

    build_nginx_container() {
        echo "🚀 Starting Nginx container..."
        podman run -d \
            --pod fello_web \
            --name fello_nginx \
            -v $PWD/$LOGS_PATH/nginx:/var/log/nginx:Z \
            -v $PWD/$API_FELLO_COM_PATH:/var/www/api.fello.com:ro,Z \
            -v $PWD/$IMS_FELLO_COM_PATH:/var/www/ims.fello.com:ro,Z \
            -v $PWD/$V4_FELLO_COM_PATH:/var/www/v4.fello.com:ro,Z \
            -v $PWD/$ARAMARK_FELLO_COM_PATH:/var/www/aramark.fello.com:ro,Z \
            -v $PWD/$EVENTBRITE_FELLO_COM_PATH:/var/www/eventbrite.fello.com:ro,Z \
            -v $PWD/$FELLO_COM_PATH:/var/www/fello.com:ro,Z \
            -v $PWD/$GIVESMART_FELLO_COM_PATH:/var/www/givesmart.fello.com:ro,Z \
            -v $PWD/$LEVY_FELLO_COM_PATH:/var/www/levy.fello.com:ro,Z \
            -v $PWD/$MOBILECAUSE_FELLO_COM_PATH:/var/www/mobilecause.fello.com:ro,Z \
            -v $PWD/$SHOPIFY_FELLO_COM_PATH:/var/www/shopify.fello.com:ro,Z \
            -v $PWD/$SHOPIFYCA_FELLO_COM_PATH:/var/www/shopifyca.fello.com:ro,Z \
            -v $PWD/$SQURE_FELLO_COM_PATH:/var/www/square.fello.com:ro,Z \
            -v $PWD/$SQURECA_FELLO_COM_PATH:/var/www/squareca.fello.com:ro,Z \
            -v $PWD/$TASSEL_FELLO_COM_PATH:/var/www/tassel.fello.com:ro,Z \
            -v $PWD/$TASSELCA_FELLO_COM_PATH:/var/www/tasselca.fello.com:ro,Z \
            -v $PWD/config/nginx/conf.d/api.fello.com.conf:/etc/nginx/conf.d/api.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/ims.fello.com.conf:/etc/nginx/conf.d/ims.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/v4.fello.com.conf:/etc/nginx/conf.d/v4.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/aramark.fello.com.conf:/etc/nginx/conf.d/aramark.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/eventbrite.fello.com.conf:/etc/nginx/conf.d/eventbrite.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/fello.com.conf:/etc/nginx/conf.d/fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/givesmart.fello.com.conf:/etc/nginx/conf.d/givesmart.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/levy.fello.com.conf:/etc/nginx/conf.d/levy.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/mobilecause.fello.com.conf:/etc/nginx/conf.d/mobilecause.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/shopify.fello.com.conf:/etc/nginx/conf.d/shopify.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/shopifyca.fello.com.conf:/etc/nginx/conf.d/shopifyca.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/square.fello.com.conf:/etc/nginx/conf.d/square.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/squareca.fello.com.conf:/etc/nginx/conf.d/squareca.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/tassel.fello.com.conf:/etc/nginx/conf.d/tassel.fello.com.conf:ro,Z \
            -v $PWD/config/nginx/conf.d/tasselca.fello.com.conf:/etc/nginx/conf.d/tasselca.fello.com.conf:ro,Z \
            nginx:alpine
    }

    post_stage_setup() {
        if ! declare -f fello_enable_xdebug > /dev/null; then
            source "./helper.sh"
        fi
        fello_disable_xdebug
    }

    print_success_message() {
        echo "✅ All pods started successfully!"
        echo ""
        echo "🔗 Access URLs:"
        echo "   PHPMyAdmin:        http://localhost:$PMA_PORT"
        echo ""
        echo "   API:               http://api.fello.localhost:$NGINX_PORT"
        echo "   IMSv2:             http://ims.fello.localhost:$NGINX_PORT"
        echo "   IMSv4:             http://v4.fello.localhost:$NGINX_PORT"
        echo ""
        echo "   Aramark:           http://aramark.fello.localhost:$NGINX_PORT"
        echo "   Eventbrite:        http://eventbrite.fello.localhost:$NGINX_PORT"
        echo "   Fello:             http://fello.localhost:$NGINX_PORT"
        echo "   GiveSmart:         http://givesmart.fello.localhost:$NGINX_PORT"
        echo "   Levy:              http://levy.fello.localhost:$NGINX_PORT"
        echo "   MobileCause:       http://mobilecause.fello.localhost:$NGINX_PORT"
        echo "   Shopify:           http://shopify.fello.localhost:$NGINX_PORT"
        echo "   Shopify CA:        http://shopifyca.fello.localhost:$NGINX_PORT"
        echo "   Square:            http://square.fello.localhost:$NGINX_PORT"
        echo "   Square CA:         http://squareca.fello.localhost:$NGINX_PORT"
        echo "   Tassel:            http://tassel.fello.localhost:$NGINX_PORT"
        echo "   Tassel CA:         http://tasselca.fello.localhost:$NGINX_PORT"
        echo ""
    }

    pre_stage_setup
    create_pods
    post_stage_setup
    print_success_message    
}
