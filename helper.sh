#!/bin/bash

fello_disable_xdebug() {
    podman exec fello_php_fpm82 mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.bak && podman restart fello_php_fpm82
}

fello_enable_xdebug() {
    podman exec fello_php_fpm82 mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.bak /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && podman restart fello_php_fpm82
}
