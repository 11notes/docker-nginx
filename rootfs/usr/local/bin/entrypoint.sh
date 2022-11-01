#!/bin/ash
if [ -z "$1" ]; then
    set -- "nginx" \
        -g \
        daemon off
fi

exec "$@"