# Docker st2web
[![Go to stackstorm/st2web Docker Hub](https://img.shields.io/badge/Docker%20Hub-stackstorm/st2web-blue.svg)](https://hub.docker.com/r/stackstorm/st2web/)

Containerized `st2web` app, the StackStorm Web UI.
It's using `nginx` service under the hood, proxifying requests to StackStorm services (auth, api, stream).

## Configuration
### `ENV` vars
The following environment variables are available for configuration:
- `ST2_AUTH_URL` (default: `http://st2auth:9100/`) - StackStorm Auth service
- `ST2_API_URL` (default: `http://st2api:9101/`) - StackStorm API service
- `ST2_STREAM_URL` (default: `http://st2stream:9102/`) - StackStorm Stream service
- `ST2WEB_HTTPS` (default: `0`) - Use https with st2web
- `ST2_PORT_HTTP` (default: `80`) - Port to listen for HTTP traffic
- `ST2_PORT_HTTPS` (default: `443`) - Port to listen for HTTPS traffic

> Warning! All 3 services should be DNS/network accessible for `st2web` container to start properly. Thanks to K8s pod restarts, it's not a problem.

### Running as Non-Root

To run the `st2web` as non-root, pass the following config options:

* `ST2_PORT_HTTP` - should be set as `8080`
* `ST2_PORT_HTTPS` - should be set as `8443`
* Run the container as `uid`/`gid` - `999:999`

### Secrets
> Note! You may safely ignore this section if `ST2WEB_HTTPS` is set to `0`.

StackStorm Web UI uses nginx for SSL negotiation. A valid SSL certificate is required for `st2web` to run properly.
You have to share with the Docker container the following files:
- `/etc/ssl/st2/st2.crt` (required) - SSL certificate, [`ssl_certificate`](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate) nginx directive
- `/etc/ssl/st2/st2.key` (required) - SSL certificate secret key [`ssl_certificate_key`](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_certificate_key)

If you don't have a valid SSL certificate, use the following to generate one: 
```
sudo openssl req \
  -x509 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/st2/st2.key \
  -out /etc/ssl/st2/st2.crt \
  -days 365 \
  -nodes \
  -subj "/C=US/ST=California/L=Palo Alto/O=StackStorm/OU=Information Technology/CN=$(hostname)"
```
Share these files with the container.
