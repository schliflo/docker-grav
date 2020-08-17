#!/usr/bin/env bash

#wait for imaginary to start
echo "STARTUP: wait for imaginary"
wait-for-it.sh 127.0.0.1:$IMAGINARY_PORT --timeout=60 --strict
echo "STARTUP: imaginary running on $IMAGINARY_PORT"

#wait for php-fpm to start
echo "STARTUP: wait for php-fpm"
wait-for-it.sh 127.0.0.1:$PHP_FPM_PORT --timeout=60 --strict
echo "STARTUP: php-fpm running on $PHP_FPM_PORT"

#start nginx
echo "STARTUP: starting nginx on port $PORT"
envsubst '\$PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && nginx -g 'daemon off;'
