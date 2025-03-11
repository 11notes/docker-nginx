${{ content_synopsis }} What can I do with this? This image will serve as a base for nginx related images that need a high-performance webserver. It can also be used stand alone as a webserver or reverse proxy. It will automatically reload on config changes if configured.

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of vHost config, must end in *.conf (set in /etc/nginx/nginx.conf)
* **${{ json_root }}/var** - Directory of webroot for vHost

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}
| `NGINX_DYNAMIC_RELOAD` | Enable reload of nginx on configuration changes in /nginx/etc (only on successful configuration test!) | |
| `NGINX_HEALTHCHECK_URL` | URL to check if nginx is ready to accept connections | https://localhost:8443/ping |

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}