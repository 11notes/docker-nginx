${{ content_synopsis }} This image will serve as a base for nginx related images that need a high-performance webserver. The default tag of this image is stripped for most functions that can be used by a reverse proxy in front of nginx, it adds however important webserver functions like brotli compression. The default tag is not meant to run as a reverse proxy, use the full image for that. The default tag does not support HTTPS for instance!

${{ content_uvp }} Good question! All the other images on the market that do exactly the same don’t do or offer these options:

${{ github:> [!IMPORTANT] }}
${{ github:> }}* This image runs as 1000:1000 by default, most other images run everything as root
${{ github:> }}* This image has no shell since it is 100% distroless, most other images run on a distro like Debian or Alpine with full shell access (security)
${{ github:> }}* This image does not ship with any critical or high rated CVE and is automatically maintained via CI/CD, most other images mostly have no CVE scanning or code quality tools in place
${{ github:> }}* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
${{ github:> }}* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
${{ github:> }}* This image works as read-only, most other images need to write files to the image filesystem
${{ github:> }}* This image is a lot smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

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