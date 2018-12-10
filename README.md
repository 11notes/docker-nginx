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
    -d 11notes/nginx:stable 
```

## difference between nginx:1.14.2-alpine

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

* [alpine:3.8](https://github.com/gliderlabs/docker-alpine/blob/c14b86580b9f86f42296050ec7564faf6b6db9be/versions/library-3.8/x86_64/Dockerfile) - jdownloader project
* [nginx/alpine:stable](https://github.com/nginxinc/docker-nginx/blob/b71469ab815f580ba0ad658a32e91c86f8565ed4/stable/alpine/Dockerfile) - official nginx container

## tips

* Don't bind to ports < 1024 (requires root)
* [alpine-docker-netshare](https://github.com/11notes/alpine-docker-netshare) - Examples to store persistent storage on NFS/CIFS/etc