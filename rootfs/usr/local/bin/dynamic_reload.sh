#!/bin/ash
  elevenLogJSON info "reloading config"
  NGINX_DYNAMIC_RELOAD_LOG=${APP_ROOT}/run/reload.log
  nginx -t &> ${NGINX_DYNAMIC_RELOAD_LOG}

  while read -r LINE; do
    if echo "${LINE}" | grep -q "nginx: "; then
      if echo "${LINE}" | grep -q "\[warn\]"; then
        LINE=$(echo ${LINE} | sed 's/nginx: \[warn\] //')
        elevenLogJSON warning "${LINE}"
      fi

      if echo "${LINE}" | grep -q "\[emerg\]"; then
        LINE=$(echo ${LINE} | sed 's/nginx: \[emerg\] //')
        elevenLogJSON error "${LINE}"
      fi
    fi
  done < ${NGINX_DYNAMIC_RELOAD_LOG}

  if cat ${NGINX_DYNAMIC_RELOAD_LOG} | grep -q "test is successful"; then
    nginx -s reload
    elevenLogJSON info "config reloaded"
  else
    elevenLogJSON error "config reload failed!"
  fi