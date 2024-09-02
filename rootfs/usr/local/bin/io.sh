#!/bin/ash
  RELOAD_LOG=${APP_ROOT}/run/reload.log
  nginx -tq &> ${RELOAD_LOG}
  elevenLogJSON info "change in config files detected"
  if cat ${RELOAD_LOG} | grep -q "nginx.conf test failed"; then
    elevenLogJSON info "error in configuration files found"
    cat ${RELOAD_LOG}
  else
    if cat ${RELOAD_LOG} | grep -q "nginx.conf test is successful"; then
      elevenLogJSON info "reload nginx with config changes"
      nginx -s reload
    else
      elevenLogJSON info "error in configuration files found"
      cat ${RELOAD_LOG}
    fi
  fi