FROM ubuntu:trusty

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

ENV container docker
ENV ENV /etc/skel/.profile
ENV TERM xterm

# Default, but overrideable env vars to be substituted in st2.template chatops.conf
ENV ST2_AUTH_URL    http://st2auth:9100/
ENV ST2_API_URL http://st2api:9101/
ENV ST2_API_KEY XXXXXXXXXXXXXXXXXXX

# Generate and set locale to UTF-8 
# # Add NodeJS v10 repository:
RUN apt-get -qq update \
  && apt-get install -y \
    curl \
    locales \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 \
  && curl -sL https://deb.nodesource.com/setup_10.x |  bash -

# The LC_ALL variable must be defined after executing update-local
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'



# Install st2chatops
RUN if [ "${ST2_VERSION#*dev}" != "${ST2_VERSION}" ]; then \
  ST2_BRANCH=master; \
    else \
  ST2_BRANCH=v${ST2_VERSION%.*}; \
  && patch /opt/stackstorm/chatops/st2chatops.env < /tmp/st2.chatops.patch  \
  && rm -f /tmp/st2.conf.patch

# Download st2chatops.env and apply patch
COPY files/st2.st2chatops.env /tmp
RUN apt-get install -y crudini \
  && crudini --merge /etc/st2/chatops.env < /tmp/st2.tmp.chatops \
  && rm -f /tmp/st2.tmp.chatops \
  && apt-get purge -y crudini \
  && apt-get autoremove -y

ENV PATH="$HERE/node_modules/.bin:$HERE/node_modules/hubot/node_modules/.bin:$PATH"

WORKDIR /opt/stackstorm/chatops
CMD ["bin/hubot"]
EXPOSE 8080
