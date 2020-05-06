FROM ubuntu:bionic

ARG DEBIAN_FRONTEND=noninteractive

ARG ST2_VERSION
RUN : "${ST2_VERSION:?Docker build argument needs to be set and non-empty.}"

LABEL maintainer="StackStorm <info@stackstorm.com>"
LABEL com.stackstorm.vendor="StackStorm"
LABEL com.stackstorm.support="Community"
LABEL com.stackstorm.version="${ST2_VERSION}"
LABEL com.stackstorm.name="StackStorm chatops in K8s"
LABEL com.stackstorm.description="st2chatops Docker image, optimized to run StackStorm chatops in Kubernetes environment"
LABEL com.stackstorm.url="https://stackstorm.com/#product"
LABEL com.stackstorm.component="st2chatops"

ENV container docker
ENV TERM xterm

# Configure st2chatops by passing required ENV variables.
# Full list of supported variables and chat adapters:
# https://github.com/StackStorm/st2chatops/blob/master/st2chatops.env
#
# Default, but overrideable ST2 service endpoints passed to st2chatops/hubot
ENV ST2_AUTH_URL http://st2auth:9100/
ENV ST2_API_URL http://st2api:9101/
ENV ST2_STREAM_URL http://st2stream:9102/

# Generate and set locale to UTF-8
RUN apt-get -qq update \
  && apt-get install -y \
    curl \
    locales \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# The LC_ALL variable must be defined after executing update-local
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Install st2chatops
RUN if [ "${ST2_VERSION#*dev}" != "${ST2_VERSION}" ]; then \
    ST2_REPO=unstable; \
  else \
    ST2_REPO=stable; \
  fi \
  && echo ST2_REPO=${ST2_REPO} \
  && curl -s https://packagecloud.io/install/repositories/StackStorm/${ST2_REPO}/script.deb.sh | bash \
  && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get install -y st2chatops=${ST2_VERSION}-* \
  && rm -f /etc/apt/sources.list.d/nodesource.list \
  && rm -f /etc/apt/sources.list.d/StackStorm_*.list

USER st2
WORKDIR /opt/stackstorm/chatops
EXPOSE 8081
CMD ["bin/hubot"]
