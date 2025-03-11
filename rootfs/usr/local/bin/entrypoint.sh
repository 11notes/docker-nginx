#!/bin/ash  
  if { [ ! -f "${APP_ROOT}/ssl/default.crt" ] && [ -f "${APP_ROOT}/etc/default.conf" ] && cat ${APP_ROOT}/etc/default.conf | grep -q "default.crt"; }; then
    eleven log debug "creating default certificate"
    openssl req -x509 -newkey rsa:4096 -subj "/C=XX/ST=XX/L=XX/O=XX/OU=DOCKER/CN=${APP_NAME}" \
      -keyout "${APP_ROOT}/ssl/default.key" \
      -out "${APP_ROOT}/ssl/default.crt" \
      -days 3650 -nodes -sha256 &> /dev/null
  fi

  if [ -z "${1}" ]; then
    if [ ! -z ${NGINX_DYNAMIC_RELOAD} ]; then
      eleven log info "enable dynamic reload"
      /sbin/inotifyd /usr/local/bin/reload.sh ${APP_ROOT}/etc:cdnym &
    fi

    set -- "nginx" \
      -g \
      'daemon off;'
    eleven log start
  fi

  exec "$@"