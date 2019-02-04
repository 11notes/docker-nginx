# docker-nginx

Dockerfile to create and run your own nginx process inside an alpine docker container. Nginx is compiled from source and currently has one added optional module.

## Volumes

/nginx/etc

Purpose: vHost config, must end in *.conf (set in /etc/nginx/nginx.conf)

/nginx/www

Purpose: Webroot for vHost

/nginx/ssl

Purpose: SSL certificate directory

## Run
```shell
docker run --name nginx \
    -v volume-etc:/nginx/etc \
    -v volume-www:/nginx/www \
    -v volume-ssl:/nginx/ssl:ro \
    -d 11notes/nginx:stable
```

## difference between official docker images

Additional plugins:

```shell
    module_headers_more
```

Nginx configuration:

```shell
    all data moved to /nginx (in compiler!)
```

## Docker -u 1000:1000 (no root initiative)

As part to make containers more secure, this container will not run as root, but as uid:gid 1000:1000. Therefore the default TCP port 80 was changed to 8080 (/source/default.conf).

## Build with

* [Alpine Linux](https://alpinelinux.org/) - Alpine Linux
* [nginx](https://github.com/nginxinc/docker-nginx) - Nginx

## Tips

* Don't bind to ports < 1024 (requires root), use NAT
* [Permanent Storge with NFS/CIFS/...](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS/...