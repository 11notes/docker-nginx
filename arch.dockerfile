ARG APP_UID=1000
ARG APP_GID=1000

# :: Util
  FROM 11notes/util AS util

# :: Build / nginx
  FROM alpine AS build
  ARG TARGETARCH
  ARG TARGETPLATFORM
  ARG TARGETVARIANT
  ARG APP_ROOT
  ARG APP_VERSION
  ARG APP_NGINX_CONFIGURATION
  ENV BUILD_ROOT=/nginx-${APP_VERSION}
  ENV BUILD_BIN=${BUILD_ROOT}/objs/nginx
  ENV NGINX_PREFIX=/etc/nginx
  ENV BUILD_DEPENDENCY_OPENSSL_VERSION=3.5.0
  ENV BUILD_DEPENDENCY_OPENSSL_ROOT=/openssl-${BUILD_DEPENDENCY_OPENSSL_VERSION}
  ENV BUILD_DEPENDENCY_ZLIB_VERSION=1.3.1
  ENV BUILD_DEPENDENCY_ZLIB_ROOT=/zlib-${BUILD_DEPENDENCY_ZLIB_VERSION}
  ENV BUILD_DEPENDENCY_PCRE2_VERSION=10.45
  ENV BUILD_DEPENDENCY_PCRE2_ROOT=/pcre2-${BUILD_DEPENDENCY_PCRE2_VERSION}
  ENV BUILD_DEPENDENCY_HEADERS_MORE_VERSION=0.38
  ENV BUILD_DEPENDENCY_HEADERS_MORE_ROOT=/headers-more-nginx-module-${BUILD_DEPENDENCY_HEADERS_MORE_VERSION}
  ENV BUILD_DEPENDENCY_BROTLI_ROOT=/ngx_brotli
  ENV BUILD_DEPENDENCY_NJS_VERSION=0.8.10
  ENV BUILD_DEPENDENCY_NJS_ROOT=/njs-${BUILD_DEPENDENCY_NJS_VERSION}
  ENV BUILD_DEPENDENCY_QUICKJS_VERSION=
  ENV BUILD_DEPENDENCY_QUICKJS_ROOT=/quickjs${BUILD_DEPENDENCY_QUICKJS_VERSION}

  USER root

  COPY --from=util /usr/local/bin/ /usr/local/bin

  RUN set -ex; \
    apk --update --no-cache add \
      cmake \
      autoconf \
      automake \
      git \
      build-base \
      curl \
      tar \
      gcc \
      g++ \
      libc-dev \
      make \
      openssl-dev \
      pcre2-dev \
      zlib-dev \
      linux-headers \
      libxslt-dev  \
      libxslt-static \
      gd-dev \
      geoip-dev \
      perl-dev \
      libedit-dev \
      libxml2-dev \
      libtool \
      quickjs-dev \
      quickjs-static \
      bash \
      libxml2-static \
      alpine-sdk \
      findutils \
      brotli-dev \
      libgd \
      tar \
      xz \
      upx;

  RUN set -ex; \
    cd /; \
    curl -SL https://nginx.org/download/nginx-${APP_VERSION}.tar.gz | tar -zxC /; \
    curl -SL https://zlib.net/fossils/zlib-${BUILD_DEPENDENCY_ZLIB_VERSION}.tar.gz | tar -zxC /; \
    curl -SL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${BUILD_DEPENDENCY_PCRE2_VERSION}/pcre2-${BUILD_DEPENDENCY_PCRE2_VERSION}.tar.gz | tar -zxC /; \
    curl -SL https://github.com/openresty/headers-more-nginx-module/archive/v${BUILD_DEPENDENCY_HEADERS_MORE_VERSION}.tar.gz | tar -zxC /; 
    
  RUN set -ex; \
    #build OpenSSL
    case "${APP_NGINX_CONFIGURATION}" in \
      "full") \
        cd /; \
        curl -SL https://github.com/openssl/openssl/releases/download/openssl-${BUILD_DEPENDENCY_OPENSSL_VERSION}/openssl-${BUILD_DEPENDENCY_OPENSSL_VERSION}.tar.gz | tar -zxC /; \
      ;; \
    esac;

  RUN set -ex; \
    # build brotli
    cd /; \
    git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli; \
    mkdir -p ${BUILD_DEPENDENCY_BROTLI_ROOT}/deps/brotli/out; \
    cd ${BUILD_DEPENDENCY_BROTLI_ROOT}/deps/brotli/out; \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..; \
    cmake --build . --config Release --target brotlienc;

  RUN set -ex; \
    #build QuickJS
    case "${APP_NGINX_CONFIGURATION}" in \
      "full") \
        cd /; \
        git clone https://github.com/bellard/quickjs; \
        curl -SL https://github.com/nginx/njs/archive/refs/tags/${BUILD_DEPENDENCY_NJS_VERSION}.tar.gz | tar -zxC /; \
        cd ${BUILD_DEPENDENCY_QUICKJS_ROOT}; \
        CFLAGS='-fPIC -static -static-libgcc' make libquickjs.a; \
      ;; \
    esac;

  RUN set -ex; \
    #build XLST
    case "${APP_NGINX_CONFIGURATION}" in \
      "full") \
        cd /; \
        curl -SL https://download.gnome.org/sources/libxml2/2.14/libxml2-2.14.1.tar.xz | tar -xJC /; \
        curl -SL https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.43.tar.xz | tar -xJC /; \
        cd /libxml2-2.14.1; \
        ./configure \
          --prefix="/usr" \
          --disable-shared \
          --enable-static \
          --without-python; \
        make -s -j $(nproc); \
        make install; \
        cd /libxslt-1.1.43; \
        ./configure \
          --prefix="/usr" \
          --disable-shared \
          --enable-static \
          --without-python; \
        make -s -j $(nproc); \
        make install; \
      ;; \
    esac;

  RUN set -ex; \
    case "${APP_NGINX_CONFIGURATION}" in \
      "light") \
        cd ${BUILD_ROOT}; \
        ./configure \
          --with-zlib=${BUILD_DEPENDENCY_ZLIB_ROOT} \
          --with-pcre=${BUILD_DEPENDENCY_PCRE2_ROOT} \
          --add-module=${BUILD_DEPENDENCY_HEADERS_MORE_ROOT} \
          --add-module=${BUILD_DEPENDENCY_BROTLI_ROOT} \
          --prefix=${NGINX_PREFIX} \
          --sbin-path=${BUILD_BIN} \
          --modules-path=${APP_ROOT}/lib/modules \
          --conf-path=${NGINX_PREFIX}/nginx.conf \
          --error-log-path=${APP_ROOT}/log/error.log \
          --http-log-path=${APP_ROOT}/log/access.log \
          --pid-path=${APP_ROOT}/run/nginx.pid \
          --lock-path=${APP_ROOT}/run/nginx.lock \
          --http-client-body-temp-path=${APP_ROOT}/cache/client_temp \
          --http-proxy-temp-path=${APP_ROOT}/cache/proxy_temp \
          --http-fastcgi-temp-path=${APP_ROOT}/cache/fastcgi_temp \
          --http-uwsgi-temp-path=${APP_ROOT}/cache/uwsgi_temp \
          --http-scgi-temp-path=${APP_ROOT}/cache/scgi_temp \
          --user=docker \
          --group=docker \
          --with-file-aio \
          --with-poll_module \
          --with-select_module \
          --with-http_addition_module \
          --with-http_dav_module \
          --with-http_flv_module \
          --with-http_gunzip_module \
          --with-http_gzip_static_module \
          --with-http_mp4_module \
          --with-http_realip_module \
          --with-http_stub_status_module \
          --with-http_sub_module \
          --with-http_v2_module \
          --without-http_autoindex_module \
          --without-http_browser_module \
          --without-http_charset_module \
          --without-http_empty_gif_module \
          --without-http_geo_module \
          --without-http_memcached_module \
          --without-http_ssi_module \
          --without-http_split_clients_module \
          --without-http_fastcgi_module \
          --without-http_uwsgi_module \
          --without-http_userid_module \
          --without-http_scgi_module \
          --without-mail_pop3_module \
          --without-mail_imap_module \
          --without-mail_smtp_module \
          --with-cc-opt="-O2 -static -static-libgcc" \
          --with-ld-opt="-s -static"; \
      ;; \
      "full") \       
        cd ${BUILD_ROOT}; \
        ./configure \
          --with-zlib=${BUILD_DEPENDENCY_ZLIB_ROOT} \
          --with-pcre=${BUILD_DEPENDENCY_PCRE2_ROOT} \
          --add-module=${BUILD_DEPENDENCY_HEADERS_MORE_ROOT} \
          --add-module=${BUILD_DEPENDENCY_BROTLI_ROOT} \
          --add-module=${BUILD_DEPENDENCY_NJS_ROOT}/nginx \
          --with-openssl=${BUILD_DEPENDENCY_OPENSSL_ROOT} \
          --prefix=${NGINX_PREFIX} \
          --sbin-path=${BUILD_BIN} \
          --modules-path=${APP_ROOT}/lib/modules \
          --conf-path=${NGINX_PREFIX}/nginx.conf \
          --error-log-path=${APP_ROOT}/log/error.log \
          --http-log-path=${APP_ROOT}/log/access.log \
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
          --with-http_geoip_module \
          --with-threads \
          --with-stream \
          --with-stream_ssl_module \
          --with-stream_ssl_preread_module \
          --with-stream_realip_module \
          --with-stream_geoip_module \
          --with-http_slice_module \
          --with-http_xslt_module \
          --with-mail \
          --with-mail_ssl_module \
          --with-compat \
          --with-file-aio \
          --with-http_v2_module \
          --with-cc-opt="-O2 -static -static-libgcc -I ${BUILD_DEPENDENCY_QUICKJS_ROOT}" \
          --with-ld-opt="-s -static -L ${BUILD_DEPENDENCY_QUICKJS_ROOT}"; \
      ;; \
    esac;

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    make -s -j $(nproc); \
    eleven checkStatic ${BUILD_BIN};

  RUN set -ex; \
    mkdir -p /distroless/usr/local/bin; \
    mkdir -p /distroless${NGINX_PREFIX}; \
    cp -R ${BUILD_ROOT}/conf/* /distroless${NGINX_PREFIX}; \
    rm /distroless${NGINX_PREFIX}/nginx.conf; \
    eleven strip ${BUILD_BIN}; \
    cp ${BUILD_BIN} /distroless/usr/local/bin;

  COPY ./rootfs/etc /distroless/etc

# :: Distroless / nginx
  FROM scratch AS distroless-nginx
  COPY --from=build /distroless/ /


# :: Build / file system
  FROM alpine AS fs
  ARG APP_ROOT
  USER root

  RUN set -ex; \
    mkdir -p ${APP_ROOT}/etc; \
    mkdir -p ${APP_ROOT}/var; \
    mkdir -p ${APP_ROOT}/run; \
    mkdir -p ${APP_ROOT}/lib/modules; \
    mkdir -p ${APP_ROOT}/cache; \
    mkdir -p ${APP_ROOT}/log; \
    ln -sf /dev/stdout ${APP_ROOT}/log/access.log; \
    ln -sf /dev/stderr ${APP_ROOT}/log/error.log;

  COPY ./rootfs/nginx ${APP_ROOT}

# :: Distroless / file system
  FROM scratch AS distroless-fs
  ARG APP_ROOT
  COPY --from=fs ${APP_ROOT} /${APP_ROOT}


# :: Header
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:curl AS distroless-curl
  FROM scratch

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

  # :: multi-stage
    COPY --from=distroless --chown=${APP_UID}:${APP_GID} / /
    COPY --from=distroless-fs --chown=${APP_UID}:${APP_GID} / /
    COPY --from=distroless-curl --chown=${APP_UID}:${APP_GID} / /
    COPY --from=distroless-nginx --chown=${APP_UID}:${APP_GID} / /

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s --start-interval=5s \
    CMD ["/usr/local/bin/curl", "-kILs", "--fail", "http://localhost:3000/ping"]

# :: Start
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/nginx"]