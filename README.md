# Fello Project - Podman Setup

Complete containerized environment for Fello applications using Podman with SELinux.

## Quick Setup

Store this repository parallel to the Fello project directory. (Not required but recommended)

## Recommended Structure

```txt
├── fc-community-brands
├── fc-inventory
├── fc-inventory-api
├── fc-square
├── fello-eventbrite
├── fello-ims
├── fello-marching-order
├── fello-new
├── fello-shopify
├── fello-shopify-ca
├── fello-square-ca
└── podman-setup        <------- The podman-setup lives here, parallel to Fello projects
```

### Files

- Required: Copy `.env.example` to `.env` and adjust if needed.
- Required: Copy `config/phpmyadmin/config.user.inc.example.php` to `config/phpmyadmin/config.user.inc.php` and adjust if needed.

## Basic operations

### Start Services

Ensure these files are sources in the terminal session:

- `fello_build_and_start_pods` - Full build and start
- `fello_stop_and_remove_pods` - Stop and remove pods
- `fello_start_pods`           - Start already stopped pods
- `fello_stop_pods`            - Stop pods without removing
- `fello_enable_xdebug`        - Enable xdebug in php-fpm (Not recommended unless debugging, this makes API 5x slow by default)
- `fello_disable_xdebug`       - Disable xdebug in php-fpm (Recommended for normal use)

### Application Access

| Service    | URL                                 |
|------------|-------------------------------------|
| PHPMyAdmin | <http://localhost:9080>             |
| API        | <http://api.fello.localhost>        |
| IMSv2      | <http://ims.fello.localhost>        |
| IMSv4      | <http://v4.fello.localhost>         |
| Fello      | <http://fello.localhost>            |
| Square     | <http://square.fello.localhost>     |
| Givesmart  | <http://givesmart.fello.localhost>  |
| Mobilecause| <http://mobilecause.fello.localhost>|
| Shopify    | <http://shopify.fello.localhost>    |
| Eventbrite | <http://eventbrite.fello.localhost> |
| Tassel     | <http://tassel.fello.localhost>     |
| Aramark    | <http://aramark.fello.localhost>    |
| Levy       | <http://levy.fello.localhost>       |
| ShopifyCA  | <http://shopifyca.fello.localhost>  |
| TasselCA   | <http://tasselca.fello.localhost>   |
| SquareCA   | <http://squareca.fello.localhost>   |

## Environment Configuration

### Application .env Files

Update each Laravel application's `.env` file:

- `APP_URL` in all websites has to be set correctly like `APP_URL=http://shopify.fello.localhost`
- Ensure redis client is set to `predis` not `phpredis`.
- DB Host will be like `DB_HOST=fello_db`
- Redis host will be like `REDIS_HOST=fello_db`
- IMS URL will be like `IMS_URL=http://fello_nginx:8081/` for server to server call

## Permission Fixes

### Laravel Storage Permissions

If you encounter Laravel log/session permission errors:

```bash
# Fix ownership (run as root)
sudo find ../fello-ims/storage -user root -exec chown $(whoami):$(whoami) {} \;
sudo find ../fello-new/storage -user root -exec chown $(whoami):$(whoami) {} \;
sudo find ../fc-inventory-api/storage -user root -exec chown $(whoami):$(whoami) {} \;

# Set permissions
chmod -R 777 ../fello-ims/storage
chmod -R 777 ../fello-new/storage
chmod -R 777 ../fc-inventory-api/storage
```

## Database Access

### phpMyAdmin

- URL: <http://localhost:9080>
- Username: `root`
- Password: `<password>`

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
podman exec -it fello_php_fpm82 bash
podman exec -it fello_nginx sh
```

### Common Issues

**502 Bad Gateway**: Check PHP-FPM logs and restart services
**Permission Denied**: Run permission fix commands above
**Database Connection**: Verify `DB_HOST=fello-mysql8` in .env files
**API Calls Failing**: Use `http://fello-nginx:8081/` for internal calls

## Architecture

- **Web Services Pod** (port 8080): Nginx + PHP-FPM + applications
- **Database Pod** (port 9080): MySQL + phpMyAdmin
- **Internal API Port**: 8081 for container-to-container communication
- **SELinux Compatible**: All volumes use `:Z` flags
- **Rootless**: Runs without requiring root privileges
