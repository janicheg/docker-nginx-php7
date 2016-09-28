#!/bin/bash

set -e

function setEnvironmentVariable() {
    if [ -z "$2" ]; then
            echo "Environment variable '$1' not set."
            return
    fi
    echo "env[$1] = \"$2\"" >> /etc/php/7.0/fpm/pool.d/www.conf
}

# Grep all ENV variables
for _curVar in `env | awk -F = '{print $1}'`;do
    # awk has split them by the equals sign
    # Pass the name and value to our function
    setEnvironmentVariable ${_curVar} ${!_curVar}
done

# prepare log output
mkdir -p /app/runtime/logs /app/web/assets
touch /var/log/nginx/access.log \
      /var/log/nginx/error.log \
      /var/www/app/runtime/logs/web.log \
      /var/www/app/runtime/logs/console.log
# adjust folder permissions for docker volume usage
find /var/www/app/runtime -type d -print0 | xargs -0 chmod 777
find /var/www/app/runtime -type f -print0 | xargs -0 chmod 666
find /var/www/app/web/assets -type d -print0 | xargs -0 chmod 777
find /var/www/app/web/assets -type f -print0 | xargs -0 chmod 666

# start PHP and nginx
service php7.0-fpm start
/usr/sbin/nginx
