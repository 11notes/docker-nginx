#!/bin/ash
  if [ -z "${HEALTHCHECK_PROTO}" ]; then HEALTHCHECK_PROTO=http; fi
  if [ -z "${HEALTHCHECK_HOST}" ]; then HEALTHCHECK_HOST=localhost; fi
  if [ -z "${HEALTHCHECK_PORT}" ]; then HEALTHCHECK_PORT=8080; fi
  if [ -z "${HEALTHCHECK_URL}" ]; then HEALTHCHECK_URL=/; fi
  curl --max-time 5 -kILs --fail ${HEALTHCHECK_PROTO}://${HEALTHCHECK_HOST}:${HEALTHCHECK_PORT}${HEALTHCHECK_URL}