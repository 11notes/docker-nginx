# :: Util
  FROM 11notes/util AS util

# :: Build / nginx
  FROM alpine/git AS build
  ARG APP_VERSION
  ARG APP_ROOT
  ENV MODULE_HEADERS_MORE_NGINX_VERSION=0.37
  RUN set -ex; \
    CONFIG="\
    --with-cc-opt=-O2 \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=${APP_ROOT}/run/nginx.pid \
    --lock-path=${APP_ROOT}/run/nginx.lock \
    --http-client-body-temp-path=${APP_ROOT}/cache/client_temp \
    --http-proxy-temp-path=${APP_ROOT}/cache/proxy_temp \
    --http-fastcgi-temp-path=${APP_ROOT}/cache/fastcgi_temp \
    --http-uwsgi-temp-path=${APP_ROOT}/cache/uwsgi_temp \
    --http-scgi-temp-path=${APP_ROOT}/cache/scgi_temp \
    --user=docker \
    --group=docker \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-http_slice_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    --add-module=/usr/lib/nginx/modules/headers-more-nginx-module-${MODULE_HEADERS_MORE_NGINX_VERSION} \
  "; \
  apk add --no-cache --update \
    curl \
    tar \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre2-dev \
    zlib-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
    libedit-dev \
    bash \
    alpine-sdk \
    findutils; \
  apk upgrade; \
  mkdir -p /usr/lib/nginx/modules; \
  mkdir -p /usr/src; \
  curl -SL https://github.com/openresty/headers-more-nginx-module/archive/v${MODULE_HEADERS_MORE_NGINX_VERSION}.tar.gz | tar -zxC /usr/lib/nginx/modules; \
  curl -SL https://nginx.org/download/nginx-${APP_VERSION}.tar.gz | tar -zxC /usr/src; \
  cd /usr/src/nginx-${APP_VERSION}; \
  ./configure $CONFIG --with-debug; \
  make -j $(nproc); \
  mv objs/nginx objs/nginx-debug; \
  mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so; \
  mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so; \
  mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so; \
  mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so; \
  ./configure $CONFIG; \
  make -j $(nproc); \
  make install; \
  install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so; \
  install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so; \
  install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so; \
  install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so; \
  strip /usr/sbin/nginx*; \
  strip /usr/lib/nginx/modules/*.so;

# :: Header
  FROM 11notes/alpine:stable

  # :: arguments
    ARG TARGETARCH
    ARG APP_IMAGE
    ARG APP_NAME
    ARG APP_VERSION
    ARG APP_ROOT
    ARG APP_UID
    ARG APP_GID

  # :: environment
    ENV APP_IMAGE=${APP_IMAGE}
    ENV APP_NAME=${APP_NAME}
    ENV APP_VERSION=${APP_VERSION}
    ENV APP_ROOT=${APP_ROOT}

    ENV NGINX_HEALTHCHECK_URL="https://localhost:8443/ping"

  # :: multi-stage
    COPY --from=util /usr/local/bin/ /usr/local/bin
    COPY --from=build /usr/sbin/nginx /usr/sbin
    COPY --from=build /etc/nginx/ /etc/nginx
    COPY --from=build /usr/lib/nginx/modules/ /etc/nginx/modules

# :: Run
  USER root
  RUN eleven printenv;

  # :: install application
    RUN set -ex; \
      apk --no-cache --update add \
        inotify-tools \
        openssl \
        pcre2-dev;

    RUN set -ex; \
      eleven mkdir ${APP_ROOT}/{etc,var,ssl,cache,run}; \
      mkdir -p /var/log/nginx; \
      touch /var/log/nginx/access.log; \
      touch /var/log/nginx/error.log; \
      ln -sf /dev/stdout /var/log/nginx/access.log; \
      ln -sf /dev/stderr /var/log/nginx/error.log;  

  # :: copy filesystem changes and set correct permissions
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin; \
      chown -R 1000:1000 \
        ${APP_ROOT} \
        /var/log/nginx;

  # :: support unraid
    RUN set -ex; \
      eleven unraid;

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD curl -X GET -kILs --fail ${NGINX_HEALTHCHECK_URL} || exit 1

# :: Start
  USER docker