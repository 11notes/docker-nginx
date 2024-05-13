![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - Nginx
![size](https://img.shields.io/docker/image-size/11notes/nginx/1.26.0?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/nginx/1.26.0?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/nginx?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-nginx?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-nginx?color=c91cb8) ![stars](https://img.shields.io/docker/stars/11notes/nginx?color=e6a50e)

**Nginx base image with additional plugins and custom compiled**

# SYNOPSIS
What can I do with this? This image will serve as a base for nginx related images that need a high-performance webserver. It can also be used stand alone as a webserver or reverse proxy.

# VOLUMES
* **/nginx/etc** - Directory of vHost config, must end in *.conf (set in /etc/nginx/nginx.conf)
* **/nginx/www** - Directory of webroot for vHost
* **/nginx/ssl** - Directory of SSL certificates

# COMPOSE
```yaml
version: "3.8"
services:
  nginx:
    image: "11notes/nginx:stable"
    container_name: "nginx"
    environment:
      TZ: Europe/Zurich
    ports:
      - "8443:8443/tcp"
    volumes:
      - "etc:/nginx/etc"
      - "www:/nginx/www"
      - "ssl:/nginx/ssl"
    networks:
      - nginx
    restart: always
volumes:
  etc:
  www:
  ssl:
networks:
  nginx:
```

# DEFAULT SETTINGS
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /nginx | home directory of user docker |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |

# PARENT IMAGE
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH
* [nginx](https://nginx.org)
* [alpine](https://alpinelinux.org)

# TIPS
* Allow non-root ports < 1024 via `echo "net.ipv4.ip_unprivileged_port_start=53" > /etc/sysctl.d/ports.conf`
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes.
    