# Use dynamically set base image
# Default base image is Ubuntu 22.04 (jammy)
ARG BASE_IMAGE=ubuntu:jammy
FROM --platform=linux/amd64 ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ARG ST2_VERSION
RUN : "${ST2_VERSION:?Docker build argument needs to be set and non-empty.}"

LABEL maintainer="StackStorm <info@stackstorm.com>"
LABEL com.stackstorm.vendor="StackStorm"
LABEL com.stackstorm.support="Community"
LABEL com.stackstorm.version="${ST2_VERSION}"
LABEL com.stackstorm.name="StackStorm K8s HA"
LABEL com.stackstorm.description="Docker image, optimized to run StackStorm \
components and core services with Highly Available requirements in Kubernetes environment"
LABEL com.stackstorm.url="https://stackstorm.com/#product"
LABEL com.stackstorm.component="st2web"

ENV container docker
ENV TERM xterm
ENV ST2WEB_HTTPS 0

# Default, but overrideable env vars to be substituted in st2.template nginx conf
ENV ST2_AUTH_URL http://st2auth:9100/
ENV ST2_API_URL http://st2api:9101/
ENV ST2_STREAM_URL http://st2stream:9102/

# Generate UTF-8 locale
RUN apt-get -qq update && apt dist-upgrade -y \
  && apt-get install -y \
    curl \
    locales \
    gpg \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Install nginx
RUN curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor > /etc/apt/trusted.gpg.d/nginx-key.gpg \
  && echo "SEE BELOW TO CHECK THE NGINX GPG SIGNING KEY EXPIRY DATE!" \
  && gpg --dry-run --quiet --no-keyring --import --import-options import-show /etc/apt/trusted.gpg.d/nginx-key.gpg \
  && echo "deb [signed-by=/etc/apt/trusted.gpg.d/nginx-key.gpg] http://nginx.org/packages/ubuntu/ jammy nginx" > /etc/apt/sources.list.d/nginx.list \
  && apt-get update \
  && apt-get install -y nginx \
  && rm -f /etc/apt/sources.list.d/nginx.list

# Install StackStorm Web UI
RUN if [ "${ST2_VERSION#*dev}" != "${ST2_VERSION}" ]; then \
    ST2_REPO=staging-unstable; \
  else \
    ST2_REPO=stable; \
  fi \
  && echo ST2_REPO=${ST2_REPO} \
  && curl -s https://packagecloud.io/install/repositories/StackStorm/${ST2_REPO}/script.deb.sh | bash \
  && apt-get install -y st2web=${ST2_VERSION}-* \
  && rm -f /etc/apt/sources.list.d/StackStorm_*.list

# Download st2.conf and apply patch
COPY files/st2.conf-http.patch /tmp
COPY files/st2.conf-https.patch /tmp
RUN if [ "${ST2_VERSION#*dev}" != "${ST2_VERSION}" ]; then \
    ST2_BRANCH=master; \
  else \
    ST2_BRANCH=v${ST2_VERSION%.*}; \
  fi \
  && echo ST2_BRANCH=${ST2_BRANCH} \
  && apt-get install -y patch gettext-base \
  && curl -sf https://raw.githubusercontent.com/StackStorm/st2/${ST2_BRANCH}/conf/nginx/st2.conf -o /etc/nginx/conf.d/st2-http.template \
  && cp /etc/nginx/conf.d/st2-http.template /etc/nginx/conf.d/st2-https.template \
  && patch /etc/nginx/conf.d/st2-http.template < /tmp/st2.conf-http.patch \
  && patch /etc/nginx/conf.d/st2-https.template < /tmp/st2.conf-https.patch \
  && rm -f /etc/nginx/conf.d/default.conf \
  && rm -f /tmp/st2.conf.patch \
  && rm -f /tmp/st2.conf-http.patch \
  && rm -f /tmp/st2.conf-https.patch

# It's a user's responsbility to pass the valid SSL certificate files: 'st2.key' and 'st2.crt', used in nginx
VOLUME ["/etc/ssl/st2/"]

EXPOSE 80
EXPOSE 443
STOPSIGNAL SIGTERM
CMD ["/bin/bash", "-c", "if [ ${ST2WEB_HTTPS} = 1 ]; then ST2WEB_TEMPLATE='/etc/nginx/conf.d/st2-https.template'; else ST2WEB_TEMPLATE='/etc/nginx/conf.d/st2-http.template'; fi && envsubst '${ST2_AUTH_URL} ${ST2_API_URL} ${ST2_STREAM_URL}' < ${ST2WEB_TEMPLATE} > /etc/nginx/conf.d/st2.conf && exec nginx -g 'daemon off;'"]
