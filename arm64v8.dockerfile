# :: Arch
  FROM alpine AS qemu
  ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz
  RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . && mv qemu-3.0.0+resin-aarch64/qemu-aarch64-static .

# :: Builder
	FROM arm64v8/alpine:latest as build
  COPY --from=qemu qemu-aarch64-static /usr/bin
	ENV NGINX_VERSION 1.24.0
	ENV ADD_MODULE_HEADERS_MORE_NGINX_VERSION 0.34

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
			--user=nginx \
			--group=nginx \
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
			--add-module=/usr/lib/nginx/modules/headers-more-nginx-module-$ADD_MODULE_HEADERS_MORE_NGINX_VERSION \
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
		mkdir -p /usr/lib/nginx/modules; \
		mkdir -p /usr/src; \
		curl -SL https://github.com/openresty/headers-more-nginx-module/archive/v$ADD_MODULE_HEADERS_MORE_NGINX_VERSION.tar.gz | tar -zxC /usr/lib/nginx/modules; \
		curl -SL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar -zxC /usr/src; \
		cd /usr/src/nginx-$NGINX_VERSION; \
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
	FROM 11notes/alpine:arm64v8-stable
	COPY --from=qemu qemu-aarch64-static /usr/bin
	COPY --from=build /usr/sbin/nginx /usr/sbin
	COPY --from=build /etc/nginx/ /etc/nginx
	COPY --from=build /usr/lib/nginx/modules/ /etc/nginx/modules

# :: Run
  USER root

  # :: prepare
  RUN set -ex; \
    mkdir -p /nginx; \
    mkdir -p /nginx/etc; \
    mkdir -p /nginx/www; \
    mkdir -p /nginx/ssl; \
    mkdir -p /nginx/cache; \
    mkdir -p /nginx/run;

  RUN set -ex; \
    apk add --update --no-cache \
      curl \
      pcre2-dev; \
    mkdir -p /var/log/nginx; \
    touch /var/log/nginx/access.log; \
    touch /var/log/nginx/error.log; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log;

  RUN set -ex; \
    addgroup --gid 1000 -S nginx; \
    adduser --uid 1000 -D -S -h /nginx -s /sbin/nologin -G nginx nginx;

  # :: copy root filesystem changes
    COPY ./rootfs /

  # :: docker -u 1000:1000 (no root initiative)
    RUN set -ex; \
      chown nginx:nginx -R \
        /nginx \
        /var/log/nginx;

# :: Volumes
  VOLUME ["/nginx/etc", "/nginx/www", "/nginx/ssl"]

# :: Monitor
  RUN set -ex; chmod +x /usr/local/bin/healthcheck.sh
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
  USER nginx
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]