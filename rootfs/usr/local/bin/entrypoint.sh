#!/bin/ash
  if [ ! -f "${APP_ROOT}/ssl/default.crt" ]; then
    elevenLogJSON debug "creating default certificate"
    openssl req -x509 -newkey rsa:4096 -subj "/C=XX/ST=XX/L=XX/O=XX/OU=DOCKER/CN=${APP_NAME}" \
      -keyout "${APP_ROOT}/ssl/default.key" \
      -out "${APP_ROOT}/ssl/default.crt" \
      -days 3650 -nodes -sha256 &> /dev/null
  fi

  if [ -z "${1}" ]; then
    if [ ! -z ${NGINX_DYNAMIC_RELOAD} ]; then
      elevenLogJSON info "enable dynamic reload"
      /sbin/inotifyd /usr/local/bin/dynamic_reload.sh ${APP_ROOT}/etc:cdnym &
    fi

    elevenLogJSON info "starting ${APP_NAME} (${APP_VERSION})"
    set -- "nginx" \
      -g \
      'daemon off;'
  fi

  exec "$@"