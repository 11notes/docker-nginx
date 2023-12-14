# Alpine :: Nginx
![size](https://img.shields.io/docker/image-size/11notes/nginx/2.6.0?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/nginx?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/nginx?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-nginx?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-nginx?color=c91cb8)

Run Nginx based on Alpine Linux. Small, lightweight, secure and fast 🏔️

## Volumes
* **/nginx/etc** - Directory of vHost config, must end in *.conf (set in /etc/nginx/nginx.conf)
* **/nginx/www** - Directory of webroot for vHost
* **/nginx/ssl** - Directory of SSL certificates

## Run
```shell
docker run --name nginx \
  -v .../etc:/nginx/etc \
  -v .../www:/nginx/www \
  -v .../ssl:/nginx/ssl:ro \
  -d 11notes/nginx:[tag]
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /nginx | home directory of user docker |

## Environment
| Parameter | Value | Default |
| --- | --- | --- |
| `HEALTHCHECK_URL` | URL to check for health of conatiner | https://localhost:8443/ping |

## Delta
Additional plugins:

```shell
  module_headers_more
```

## Parent image
* [11notes/alpine:stable](https://github.com/11notes/docker-alpine)

## Built with and thanks to
* [nginx](https://nginx.org)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Only use rootless container runtime (podman, rootless docker)
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy (haproxy, traefik, nginx)