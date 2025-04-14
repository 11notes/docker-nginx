![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# ⛰️ nginx
[<img src="https://img.shields.io/badge/github-source-blue?logo=github&color=040308">](https://github.com/11notes/docker-nginx)![size](https://img.shields.io/docker/image-size/11notes/nginx/1.26.3?color=0eb305)![version](https://img.shields.io/docker/v/11notes/nginx/1.26.3?color=eb7a09)![pulls](https://img.shields.io/docker/pulls/11notes/nginx?color=2b75d6)[<img src="https://img.shields.io/github/issues/11notes/docker-nginx?color=7842f5">](https://github.com/11notes/docker-nginx/issues)

Nginx with additional plugins and custom compiled

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [1.26.3](https://hub.docker.com/r/11notes/nginx/tags?name=1.26.3)
* [stable](https://hub.docker.com/r/11notes/nginx/tags?name=stable)
* [latest](https://hub.docker.com/r/11notes/nginx/tags?name=latest)
* [1.26.3-unraid](https://hub.docker.com/r/11notes/nginx/tags?name=1.26.3-unraid)
* [stable-unraid](https://hub.docker.com/r/11notes/nginx/tags?name=stable-unraid)
* [latest-unraid](https://hub.docker.com/r/11notes/nginx/tags?name=latest-unraid)

# UNRAID VERSION 🟠
This image supports unraid by default. Simply add **-unraid** to any tag and the image will run as 99:100 instead of 1000:1000 causing no issues on unraid. Enjoy.

# SYNOPSIS 📖
**What can I do with this?** What can I do with this? This image will serve as a base for nginx related images that need a high-performance webserver. It can also be used stand alone as a webserver or reverse proxy. It will automatically reload on config changes if configured.

# VOLUMES 📁
* **/nginx/etc** - Directory of vHost config, must end in *.conf (set in /etc/nginx/nginx.conf)
* **/nginx/var** - Directory of webroot for vHost

# COMPOSE ✂️
```yaml
services:
  nginx:
    image: "11notes/nginx:1.26.2"
    container_name: "nginx"
    environment:
      TZ: "Europe/Zurich"
    ports:
      - "8443:8443/tcp"
    volumes:
      - "etc:/nginx/etc"
      - "var:/nginx/var"
      - "ssl:/nginx/ssl"
    restart: "always"
volumes:
  etc:
  var:
  ssl:
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
| `NGINX_DYNAMIC_RELOAD` | Enable reload of nginx on configuration changes in /nginx/etc (only on successful configuration test!) | |
| `NGINX_HEALTHCHECK_URL` | URL to check if nginx is ready to accept connections | https://localhost:8443/ping |

# SOURCE 💾
* [11notes/nginx](https://github.com/11notes/docker-nginx)

# PARENT IMAGE 🏛️
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH 🧰
* [nginx](https://nginx.org)

# GENERAL TIPS 📌
* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-nginx/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-nginx/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-nginx/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 11.3.2025, 07:50:49 (CET)*