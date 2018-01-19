# ------ Header ------ #
FROM alpine:latest
MAINTAINER 11notes <docker@11notes.ch>

# ------ download latest version of nginx and create folder structure, deleting default files ------ #

#   // update apk
RUN apk update \
#   // download and install nginx
    && apk add nginx \
#   // create non-existing /run/nginx directory (PID)
    && mkdir -p /run/nginx \
#   // create directory for SSL certificates
    && mkdir -p /etc/nginx/ssl \
#   // delete default vHost configuration
    && rm /etc/nginx/conf.d/default.conf \
#   // delete default vHost web directory
    && rm -R /var/www/localhost

#   // add default nginx.conf file
ADD ./nginx.conf /etc/nginx/nginx.conf

#   // default SIGTERM to docker
STOPSIGNAL SIGTERM

# ------ define volumes ------ #
VOLUME ["/etc/nginx", "/var/www"]

# ------ entrypoint for container ------ #
CMD ["nginx", "-g", "daemon off;"]