#!/bin/sh

supercronic /home/www-data/crontab &

exec docker-entrypoint.sh "$@" || true
