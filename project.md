${{ content_synopsis }} This image will serve as a base for nginx related images that need a high-performance webserver. The default tag of this image is stripped for most functions that can be used by a reverse proxy in front of nginx, it adds however important webserver functions like brotli compression. The default tag is not meant to run as a reverse proxy, use the full image for that. **The default tag does not support HTTPS for instance!**

${{ content_uvp }} Good question! Because ...

${{ github:> [!IMPORTANT] }}
${{ github:> }}* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
${{ github:> }}* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
${{ github:> }}* ... this image is auto updated to the latest version via CI/CD
${{ github:> }}* ... this image has a health check
${{ github:> }}* ... this image runs read-only
${{ github:> }}* ... this image is automatically scanned for CVEs before and after publishing
${{ github:> }}* ... this image is created via a secure and pinned CI/CD process
${{ github:> }}* ... this image verifies external payloads if possible
${{ github:> }}* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

${{ content_comparison }}


${{ title_config }}
```yaml
${{ include: ./rootfs/etc/nginx/nginx.conf }}
```

The default configuration contains no special settings. It enables brotli compression, sets the workers to the same amount as n-CPUs available, has two default logging formats, disables most stuff not needed and enables best performance settings. Please mount your own config if you need to change how nginx is setup.

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of vHost config, must end in *.conf
* **${{ json_root }}/var** - Directory of webroot for vHost

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}