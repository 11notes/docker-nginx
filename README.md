# docker-nginx

Dockerfile to create and run your own nginx process inside an alpine docker container.

## docker volumes

/nginx/etc

Contains: vhost for nginx. Must end in *.conf (set in /etc/nginx/nginx.conf)

/nginx/www

Contains: webroot for vhost etc

/nginx/ssl

Contains: SSL certificates, ment as read only for web workes from a central ssl store

## docker build
```shell
docker build -t YOURNAME/YOURCONTAINER:YOURTAG .
```
## docker run
```shell
docker run --name nginx \
    -v volume-etc:/nginx/etc \
    -v volume-www:/nginx/www \
    -v volume-ssl:/nginx/ssl:ro \
    -d 11notes/nginx:latest
```

## difference between official container

Additional plugins:

```shell
    module_headers_more
```

Nginx configuration and uid/gid:

```shell
    uid:gid both set to static 1000:1000
    all data moved to /nginx
```

## build with

* [alpine](https://github.com/gliderlabs/docker-alpine) - alpine linux
* [nginx](https://github.com/nginxinc/docker-nginx) - official docker images

## tips

* Don't bind to ports < 1024 (requires root)
* [alpine-docker-netshare](https://github.com/11notes/alpine-docker-netshare) - Examples to store persistent storage on NFS/CIFS/etc