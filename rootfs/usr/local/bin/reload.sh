#!/bin/ash
  eleven log debug "inotifyd event: ${1}"
  eleven log info "reloading config"
  NGINX_DYNAMIC_RELOAD_LOG=${APP_ROOT}/run/reload.log
  nginx -t &> ${NGINX_DYNAMIC_RELOAD_LOG}

  while read -r LINE; do
    if echo "${LINE}" | grep -q "nginx: "; then
      if echo "${LINE}" | grep -q "\[warn\]"; then
        LINE=$(echo ${LINE} | sed 's/nginx: \[warn\] //')
        eleven log warning "${LINE}"
      fi

      if echo "${LINE}" | grep -q "\[emerg\]"; then
        LINE=$(echo ${LINE} | sed 's/nginx: \[emerg\] //')
        eleven log error "${LINE}"
      fi
    fi
  done < ${NGINX_DYNAMIC_RELOAD_LOG}

  if cat ${NGINX_DYNAMIC_RELOAD_LOG} | grep -q "test is successful"; then
    nginx -s reload
    eleven log info "config reloaded"
  else
    eleven log error "config reload failed!"
  fi