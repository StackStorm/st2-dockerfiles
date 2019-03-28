FROM ubuntu:trusty

ARG DEBIAN_FRONTEND=noninteractive
ARG ST2_VERSION
RUN : "${ST2_VERSION:?Docker build argument needs to be set and non-empty.}"

LABEL maintainer="StackStorm <info@stackstorm.com>" \
      com.stackstorm.vendor="StackStorm"  \
      com.stackstorm.support="Community"  \
      com.stackstorm.version="${ST2_VERSION}" \
      com.stackstorm.name="StackStorm K8s HA" \
      com.stackstorm.description="Docker image, optimized to run StackStorm   \
      components and core services with Highly Available requirements in Kubernetes environment"  \
      com.stackstorm.url="https://stackstorm.com/#product"

ENV container docker
ENV TERM xterm

# Default, but overrideable env vars to be substituted in st2.template chatops.conf
ENV ST2_AUTH_URL  http://st2auth:9100/
ENV ST2_API_URL   http://st2api:9101/
ENV ST2_API_KEY   XXXXXXXXXXXXXXXXXXX

# Generate and set locale to UTF-8 
# # Add NodeJS v10 repository:
RUN apt-get -qq update \
  && apt-get install -y \
    curl \
    locales \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 \
  && curl -sL https://deb.nodesource.com/setup_10.x | bash -

# The LC_ALL variable must be defined after executing update-local
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Install StackStorm Web UI
RUN if [ "${ST2_VERSION#*dev}" != "${ST2_VERSION}" ]; then \
    ST2_REPO=unstable; \
  else \
    ST2_REPO=stable; \
    fi \
  && echo ST2_REPO=${ST2_REPO} \
  && curl -s https://packagecloud.io/install/repositories/StackStorm/${ST2_REPO}/script.deb.sh | bash \
  && apt-get install -y st2chatops=${ST2_VERSION}-* 

# Download st2chatops.env and apply patch
COPY files/st2chatops.env /tmp
RUN apt-get install -y crudini \
  && crudini --merge /opt/stackstorm/chatops/st2chatops.env < /tmp/st2chatops.env \
  && rm -f /tmp/st2chatops.env \
  && apt-get purge -y crudini \
  && apt-get autoremove -y  \
  && rm -f /etc/apt/sources.list.d/StackStorm_*.list

VOLUME ["/opt/stackstorm/chatops"]
WORKDIR /opt/stackstorm/chatops
CMD ["bin/hubot"]
EXPOSE 8080
