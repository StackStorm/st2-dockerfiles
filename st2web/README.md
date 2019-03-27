# Docker `st2web`
Containerized `st2web` app, the StackStorm Web UI.
It's using `nginx` service under the hood, proxifying requests to StackStorm services (auth, api, stream).

## Configuration
### `ENV` vars
The following environment variables are available for configuration:
- `ST2_AUTH_URL` (default: `http://st2auth:9100/`) - StackStorm Auth service
- `ST2_API_URL` (default: `http://st2api:9101/`) - StackStorm API service
- `ST2_STREAM_URL` (default: `http://st2stream:9102/`) - StackStorm Stream service



> Warning! All 3 services should be DNS/network accessible for `st2web` container to start properly. Thanks to K8s pod restarts, it's not a problem.

### Secrets
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
