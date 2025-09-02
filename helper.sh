#!/bin/bash

fello_disable_xdebug() {
    podman exec fello_php_fpm rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    podman restart fello_php_fpm
}
