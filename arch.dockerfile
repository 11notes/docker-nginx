# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      APP_VERSION=0 \
      BUILD_NGINX_CONFIGURATION=light \
      BUILD_DEPENDENCY_OPENSSL_VERSION=3.5.1 \
      BUILD_DEPENDENCY_ZLIB_VERSION=1.3.1 \
      BUILD_DEPENDENCY_ZLIB_SHA256=9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23 \
      BUILD_DEPENDENCY_PCRE2_VERSION=10.45 \
      BUILD_DEPENDENCY_HEADERS_MORE_VERSION=0.39 \
      BUILD_DEPENDENCY_QUICKJS_VERSION= \
      BUILD_DEPENDENCY_NJS_VERSION=0.8.10 \
      BUILD_NGINX_PREFIX=/etc/nginx

  ARG BUILD_ROOT=/nginx-${APP_VERSION} \
      BUILD_DEPENDENCY_OPENSSL_ROOT=/openssl-${BUILD_DEPENDENCY_OPENSSL_VERSION} \
      BUILD_DEPENDENCY_ZLIB_ROOT=/zlib-${BUILD_DEPENDENCY_ZLIB_VERSION} \
      BUILD_DEPENDENCY_PCRE2_ROOT=/pcre2-${BUILD_DEPENDENCY_PCRE2_VERSION} \
      BUILD_DEPENDENCY_HEADERS_MORE_ROOT=/headers-more-nginx-module-${BUILD_DEPENDENCY_HEADERS_MORE_VERSION} \
      BUILD_DEPENDENCY_BROTLI_ROOT=/ngx_brotli \
      BUILD_DEPENDENCY_NJS_ROOT=/njs-${BUILD_DEPENDENCY_NJS_VERSION} \
      BUILD_DEPENDENCY_QUICKJS_ROOT=/quickjs${BUILD_DEPENDENCY_QUICKJS_VERSION} \
      BUILD_BIN=${BUILD_ROOT}/objs/nginx

# :: FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:localhealth AS distroless-localhealth
  FROM 11notes/util:bin AS util-bin

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: NGINX
  FROM alpine AS build
  COPY --from=util-bin / /
  COPY ./key.txt /

  ARG APP_UID \
      APP_GID \
      APP_VERSION \
      APP_ROOT \
      BUILD_DEPENDENCY_OPENSSL_VERSION \
      BUILD_DEPENDENCY_ZLIB_VERSION \
      BUILD_DEPENDENCY_ZLIB_SHA256 \
      BUILD_DEPENDENCY_PCRE2_VERSION \
      BUILD_DEPENDENCY_HEADERS_MORE_VERSION \
      BUILD_DEPENDENCY_QUICKJS_VERSION \
      BUILD_DEPENDENCY_NJS_VERSION \
      BUILD_NGINX_PREFIX \
      BUILD_NGINX_CONFIGURATION \
      BUILD_ROOT \
      BUILD_DEPENDENCY_OPENSSL_ROOT \
      BUILD_DEPENDENCY_ZLIB_ROOT \
      BUILD_DEPENDENCY_PCRE2_ROOT \
      BUILD_DEPENDENCY_HEADERS_MORE_ROOT \
      BUILD_DEPENDENCY_BROTLI_ROOT \
      BUILD_DEPENDENCY_NJS_ROOT \
      BUILD_DEPENDENCY_QUICKJS_ROOT \
      BUILD_BIN

  RUN set -ex; \
    apk --update --no-cache add \
      gpg \
      gpg-agent \
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
      pv \
      jq \
      xz;

  RUN set -ex; \
    gpg --import /key.txt;

  RUN set -ex; \
    cd /; \
    eleven asset gpg-asc https://nginx.org/download/nginx-${APP_VERSION}.tar.gz https://nginx.org/download/nginx-${APP_VERSION}.tar.gz.asc; \
    eleven asset sha256 https://zlib.net/zlib-${BUILD_DEPENDENCY_ZLIB_VERSION}.tar.gz ${BUILD_DEPENDENCY_ZLIB_SHA256}; \
    eleven github asset PCRE2Project/pcre2 pcre2-${BUILD_DEPENDENCY_PCRE2_VERSION} pcre2-${BUILD_DEPENDENCY_PCRE2_VERSION}.tar.gz; \
    eleven github asset openresty/headers-more-nginx-module v${BUILD_DEPENDENCY_HEADERS_MORE_VERSION} v${BUILD_DEPENDENCY_HEADERS_MORE_VERSION}.tar.gz;
    
  RUN set -ex; \
    #build OpenSSL
    case "${BUILD_NGINX_CONFIGURATION}" in \
      "full") \
        cd /; \
        eleven github asset openssl/openssl openssl-${BUILD_DEPENDENCY_OPENSSL_VERSION} openssl-${BUILD_DEPENDENCY_OPENSSL_VERSION}.tar.gz; \
      ;; \
    esac;

  RUN set -ex; \
    # build brotli
    cd /; \
    eleven git clone google/ngx_brotli.git; \
    mkdir -p ${BUILD_DEPENDENCY_BROTLI_ROOT}/deps/brotli/out; \
    cd ${BUILD_DEPENDENCY_BROTLI_ROOT}/deps/brotli/out; \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed .. 2>&1 > /dev/null; \
    cmake --build . --config Release --target brotlienc 2>&1 > /dev/null;

  RUN set -ex; \
    #build QuickJS
    case "${BUILD_NGINX_CONFIGURATION}" in \
      "full") \
        cd /; \
        eleven github asset nginx/njs ${BUILD_DEPENDENCY_NJS_VERSION} ${BUILD_DEPENDENCY_NJS_VERSION}.tar.gz; \
        cd ${BUILD_DEPENDENCY_QUICKJS_ROOT}; \
        CFLAGS='-fPIC -static -static-libgcc' make libquickjs.a 2>&1 > /dev/null; \
      ;; \
    esac;

  RUN set -ex; \
    #build XLST
    case "${BUILD_NGINX_CONFIGURATION}" in \
      "full") \
        cd /; \
        eleven asset sha256-sum https://download.gnome.org/sources/libxml2/2.14/libxml2-2.14.1.tar.xz https://download.gnome.org/sources/libxml2/2.14/libxml2-2.14.1.sha256sum; \
        eleven asset sha256-sum https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.43.tar.xz https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.43.sha256sum; \
        cd /libxml2-2.14.1; \
        ./configure \
          --prefix="/usr" \
          --disable-shared \
          --enable-static \
          --without-python; \
        make -s -j $(nproc) 2>&1 > /dev/null; \
        make install; \
        cd /libxslt-1.1.43; \
        ./configure \
          --prefix="/usr" \
          --disable-shared \
          --enable-static \
          --without-python; \
        make -s -j $(nproc) 2>&1 > /dev/null; \
        make install; \
      ;; \
    esac;

  RUN set -ex; \
    case "${BUILD_NGINX_CONFIGURATION}" in \
      "light") \
        cd ${BUILD_ROOT}; \
        ./configure \
          --with-zlib=${BUILD_DEPENDENCY_ZLIB_ROOT} \
          --with-pcre=${BUILD_DEPENDENCY_PCRE2_ROOT} \
          --add-module=${BUILD_DEPENDENCY_HEADERS_MORE_ROOT} \
          --add-module=${BUILD_DEPENDENCY_BROTLI_ROOT} \
          --prefix=${BUILD_NGINX_PREFIX} \
          --sbin-path=${BUILD_BIN} \
          --modules-path=${APP_ROOT}/lib/modules \
          --conf-path=${BUILD_NGINX_PREFIX}/nginx.conf \
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
          --prefix=${BUILD_NGINX_PREFIX} \
          --sbin-path=${BUILD_BIN} \
          --modules-path=${APP_ROOT}/lib/modules \
          --conf-path=${BUILD_NGINX_PREFIX}/nginx.conf \
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
    make -s -j $(nproc);

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};

  RUN set -ex; \
    mkdir -p /distroless${BUILD_NGINX_PREFIX}; \
    cp -R ${BUILD_ROOT}/conf/* /distroless${BUILD_NGINX_PREFIX}; \
    rm /distroless${BUILD_NGINX_PREFIX}/nginx.conf;

  COPY ./rootfs/etc/nginx/ /distroless${BUILD_NGINX_PREFIX}

  RUN set -ex; \
    ls -lah /distroless${BUILD_NGINX_PREFIX}; \
    cat /distroless${BUILD_NGINX_PREFIX}/nginx.conf;

# :: FILE-SYSTEM
  FROM alpine AS file-system
  ARG APP_ROOT
  COPY ./rootfs/nginx /distroless${APP_ROOT}

  RUN set -ex; \
    mkdir -p /distroless${APP_ROOT}/etc; \
    mkdir -p /distroless${APP_ROOT}/var; \
    mkdir -p /distroless${APP_ROOT}/run; \
    mkdir -p /distroless${APP_ROOT}/lib/modules; \
    mkdir -p /distroless${APP_ROOT}/cache; \
    mkdir -p /distroless${APP_ROOT}/log; \
    ln -sf /dev/stdout /distroless${APP_ROOT}/log/access.log; \
    ln -sf /dev/stderr /distroless${APP_ROOT}/log/error.log;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
  # :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=distroless / /
    COPY --from=distroless-localhealth / /
    COPY --from=build /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s --start-interval=5s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:3000/ping", "-I"]

# :: Start
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/nginx"]