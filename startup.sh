#!/bin/sh

cron -f &

exec docker-entrypoint.sh "$@"
