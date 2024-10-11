# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;


# :: Build
  FROM alpine:latest as build
  ENV BUILD_VERSION=1.26.2
  ENV MODULE_HEADERS_MORE_NGINX_VERSION=0.37

  RUN set -ex; \
    CONFIG="\
      --prefix=/etc/nginx \
      --sbin-path=/usr/sbin/nginx \
      --modules-path=/usr/lib/nginx/modules \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --pid-path=/nginx/run/nginx.pid \
      --lock-path=/nginx/run/nginx.lock \
      --http-client-body-temp-path=/nginx/cache/client_temp \
      --http-proxy-temp-path=/nginx/cache/proxy_temp \
      --http-fastcgi-temp-path=/nginx/cache/fastcgi_temp \
      --http-uwsgi-temp-path=/nginx/cache/uwsgi_temp \
      --http-scgi-temp-path=/nginx/cache/scgi_temp \
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
      --with-mail \
      --with-mail_ssl_module \
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
    curl -SL https://nginx.org/download/nginx-${BUILD_VERSION}.tar.gz | tar -zxC /usr/src; \
    cd /usr/src/nginx-${BUILD_VERSION}; \
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
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  COPY --from=build /usr/sbin/nginx /usr/sbin
  COPY --from=build /etc/nginx/ /etc/nginx
  COPY --from=build /usr/lib/nginx/modules/ /etc/nginx/modules
  ENV APP_NAME="nginx"
  ENV APP_VERSION=1.26.2
  ENV APP_ROOT=/nginx

# :: Run
  USER root

  # :: update image
    RUN set -ex; \
      apk add --no-cache \
        inotify-tools \
        openssl \
        pcre2-dev; \
      apk --no-cache upgrade;

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var; \
      mkdir -p ${APP_ROOT}/ssl; \
      mkdir -p ${APP_ROOT}/cache; \
      mkdir -p ${APP_ROOT}/run; \
      mkdir -p /var/log/nginx; \
      touch /var/log/nginx/access.log; \
      touch /var/log/nginx/error.log; \
      ln -sf /dev/stdout /var/log/nginx/access.log; \
      ln -sf /dev/stderr /var/log/nginx/error.log;    

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT} \
        /var/log/nginx;

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var", "${APP_ROOT}/ssl"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]