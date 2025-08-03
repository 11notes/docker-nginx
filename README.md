![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# NGINX
![size](https://img.shields.io/docker/image-size/11notes/nginx/1.28.0?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![version](https://img.shields.io/docker/v/11notes/nginx/1.28.0?color=eb7a09)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/nginx?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-NGINX?color=7842f5">](https://github.com/11notes/docker-NGINX/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

Nginx, slim and distroless to be used behind a reverse proxy or as full version as a proxy

# INTRODUCTION 📢

nginx (engine x) is an HTTP web server, reverse proxy, content cache, load balancer, TCP/UDP proxy server, and mail proxy server.

# SYNOPSIS 📖
**What can I do with this?** This image will serve as a base for nginx related images that need a high-performance webserver. The default tag of this image is stripped for most functions that can be used by a reverse proxy in front of nginx, it adds however important webserver functions like brotli compression. The default tag is not meant to run as a reverse proxy, use the full image for that. **The default tag does not support HTTPS for instance!**

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image verifies external payloads if possible
>* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | 11notes/nginx:1.28.0 | nginx:1.28.0 |
| ---: | :---: | :---: |
| **image size on disk** | 3.69MB | 192MB |
| **process UID/GID** | 1000/1000 | 0/0 |
| **distroless?** | ✅ | ❌ |
| **rootless?** | ✅ | ❌ |



# DEFAULT CONFIG 📑
```yaml
worker_processes auto;
worker_cpu_affinity auto;
worker_rlimit_nofile 204800;
error_log /nginx/log/error.log warn;
daemon off;

events {
  worker_connections 1024;
  use epoll;
  multi_accept on;
}

http {
  log_format main escape=json '{"log":"main","time":"$time_iso8601","server":{"name":"$server_name", "protocol":"$server_protocol"}, "client":{"ip":"$remote_addr", "x-forwarded-for":"$http_x_forwarded_for", "user":"$remote_user"},"request":{"method":"$request_method", "url":"$request_uri", "time":"$request_time", "status":$status}}';
  log_format proxy escape=json '{"log":"proxy", "time":"$time_iso8601","server":{"name":"$server_name", "protocol":"$server_protocol"}}, "client":{"ip":"$remote_addr", "x-forwarded-for":"$http_x_forwarded_for", "user":"$remote_user"},"request":{"method":"$request_method", "url":"$request_uri", "time":"$request_time", "status":$status}, "proxy":{"host":"$upstream_addr", "time":{"connect":"$upstream_connect_time", "response":"$upstream_response_time", "header":"$upstream_header_time"}, "io":{"bytes":{"sent":"$upstream_bytes_sent", "received":"$upstream_bytes_received"}}, "cache":"$upstream_cache_status", "status":"$upstream_status"}}';

  access_log off;
  server_tokens off;

  include mime.types;
  default_type application/octet-stream;

  sendfile on;
  aio on;
  tcp_nopush on;
  tcp_nodelay on;
  gzip on;

  brotli on;
  brotli_comp_level 4;
  brotli_static on;
  brotli_types
    text/plain
    text/css
    text/xml
    text/javascript
    text/x-component
    application/xml
    application/xml+rss
    application/javascript
    application/json
    application/atom+xml
    application/vnd.ms-fontobject
    application/x-font-ttf
    application/x-font-opentype
    application/x-font-truetype
    application/x-web-app-manifest+json
    application/xhtml+xml
    application/octet-stream
    font/opentype
    font/truetype
    font/eot
    font/otf
    image/svg+xml
    image/x-icon
    image/vnd.microsoft.icon
    image/bmp;

  client_max_body_size 8M;
  keepalive_timeout 90;
  keepalive_requests 102400;
  reset_timedout_connection on;
  client_body_timeout 10;
  send_timeout 5;

  open_file_cache max=204800 inactive=5m;
  open_file_cache_valid 2m;
  open_file_cache_min_uses 2;
  open_file_cache_errors off;

  root /nginx/var;

  include /nginx/etc/*.conf;
}
```

The default configuration contains no special settings. It enables brotli compression, sets the workers to the same amount as n-CPUs available, has two default logging formats, disables most stuff not needed and enables best performance settings. Please mount your own config if you need to change how nginx is setup.

# VOLUMES 📁
* **/nginx/etc** - Directory of vHost config, must end in *.conf
* **/nginx/var** - Directory of webroot for vHost

# COMPOSE ✂️
```yaml
name: "nginx"
services:
  nginx:
    image: "11notes/nginx:1.28.0"
    read_only: true
    environment:
      TZ: "Europe/Zurich"
    ports:
      - "3000:3000/tcp"
    networks:
      frontend:
    volumes:
      - "etc:/nginx/etc"
      - "var:/nginx/var"
    tmpfs:
      - "/nginx/cache:uid=1000,gid=1000"
      - "/nginx/run:uid=1000,gid=1000"
    restart: "always"

volumes:
  etc:
  var:

networks:
  frontend:
```

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /nginx | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [1.28.0](https://hub.docker.com/r/11notes/nginx/tags?name=1.28.0)
* [stable](https://hub.docker.com/r/11notes/nginx/tags?name=stable)

### There is no latest tag, what am I supposed to do about updates?
It is of my opinion that the ```:latest``` tag is dangerous. Many times, I’ve introduced **breaking** changes to my images. This would have messed up everything for some people. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:1.28.0``` you can use ```:1``` or ```:1.28```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/nginx:1.28.0
docker pull ghcr.io/11notes/nginx:1.28.0
docker pull quay.io/11notes/nginx:1.28.0
```

# SOURCE 💾
* [11notes/nginx](https://github.com/11notes/docker-NGINX)

# PARENT IMAGE 🏛️
> [!IMPORTANT]
>This image is not based on another image but uses [scratch](https://hub.docker.com/_/scratch) as the starting layer.
>The image consists of the following distroless layers that were added:
>* [11notes/distroless](https://github.com/11notes/docker-distroless/blob/master/arch.dockerfile) - contains users, timezones and Root CA certificates
>* [11notes/distroless:curl](https://github.com/11notes/docker-distroless/blob/master/curl.dockerfile) - app to execute HTTP requests

# BUILT WITH 🧰
* [nginx](https://nginx.org)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-nginx/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-nginx/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-nginx/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 03.08.2025, 03:35:59 (CET)*