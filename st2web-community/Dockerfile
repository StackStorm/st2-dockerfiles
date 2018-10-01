FROM ubuntu:xenial

ARG ST2_VERSION

LABEL maintainer="StackStorm <info@stackstorm.com>"
LABEL com.stackstorm.vendor="StackStorm"
LABEL com.stackstorm.support="Community"
LABEL com.stackstorm.version="${ST2_VERSION}"
LABEL com.stackstorm.name="StackStorm Community K8s HA"
LABEL com.stackstorm.description="Docker image, optimized to run StackStorm Community \
components and core services with Highly Available requirements in Kubernetes environment"
LABEL com.stackstorm.url="https://stackstorm.com/#product"

ENV container docker
ENV TERM xterm

# Default, but overrideable env vars to be substituted in st2.template nginx conf
ENV ST2_AUTH_URL http://st2auth:9100/
ENV ST2_API_URL http://st2api:9101/
ENV ST2_STREAM_URL http://st2stream:9102/

RUN : "${ST2_VERSION:?Docker build argument needs to be set and non-empty.}"

# Generate UTF-8 locale
RUN apt-get -qq update \
  && apt-get install -y locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Install nginx
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ABF5BD827BD9BF62 \
  && echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" > /etc/apt/sources.list.d/nginx.list \
  && apt-get update \
  && apt-get install -y nginx \
  && rm -f /etc/apt/sources.list.d/nginx.list

# Install StackStorm Community Web UI
RUN if [ "${ST2_VERSION#*dev}" != "${ST2_VERSION}" ]; then \
    ST2_REPO=unstable; \
  else \
    ST2_REPO=stable; \
  fi \
  && echo ST2_REPO=${ST2_REPO} \
  && apt-get install -y curl \
  && curl -s https://packagecloud.io/install/repositories/StackStorm/${ST2_REPO}/script.deb.sh | bash \
  && apt-get install -y st2web=${ST2_VERSION}-* \
  && rm -f /etc/apt/sources.list.d/StackStorm_*.list

# Download st2.conf and apply patch
COPY files/st2.conf.patch /tmp
RUN if [ "${ST2_VERSION#*dev}" != "${ST2_VERSION}" ]; then \
    ST2_BRANCH=master; \
  else \
    ST2_BRANCH=v${ST2_VERSION%.*}; \
  fi \
  && echo ST2_BRANCH=${ST2_BRANCH} \
  && apt-get install -y patch gettext-base \
  && curl -sf https://raw.githubusercontent.com/StackStorm/st2/${ST2_BRANCH}/conf/nginx/st2.conf -o /etc/nginx/conf.d/st2.template \
  && patch /etc/nginx/conf.d/st2.template < /tmp/st2.conf.patch \
  && rm -f /etc/nginx/conf.d/default.conf \
  && rm -f /tmp/st2.conf.patch

# It's a user's responsbility to pass the valid SSL certificate files: 'st2.key' and 'st2.crt', used in nginx
VOLUME ["/etc/ssl/st2/"]

EXPOSE 80
EXPOSE 443
STOPSIGNAL SIGTERM
CMD ["/bin/bash", "-c", "envsubst '${ST2_AUTH_URL} ${ST2_API_URL} ${ST2_STREAM_URL}' < /etc/nginx/conf.d/st2.template > /etc/nginx/conf.d/st2.conf && exec nginx -g 'daemon off;'"]
