# Alpine :: Nginx
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

## Delta
Additional plugins:

```shell
  module_headers_more
```

## Parent
* [11notes/alpine:stable](https://github.com/11notes/docker-alpine)

## Built with
* [nginx](https://nginx.org/)
* [Alpine Linux](https://alpinelinux.org/)

## Tips
* You can find some [examples](examples) of special backend configurations
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy
* [Permanent Stroage](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS and more