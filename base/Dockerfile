FROM ubuntu:bionic

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

# Generate and set locale to UTF-8
RUN apt-get -qq update \
  && apt-get install -y \
    curl \
    locales \
    gpg \
    lsb-release \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8 \
  && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# The LC_ALL variable must be defined after executing update-local
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Install StackStorm, but without UI
RUN if [ "${ST2_VERSION#*dev}" != "${ST2_VERSION}" ]; then \
    ST2_REPO=staging-unstable; \
  else \
    ST2_REPO=stable; \
  fi \
  && echo ST2_REPO=${ST2_REPO} \
  && curl -sf https://packagecloud.io/install/repositories/StackStorm/${ST2_REPO}/script.deb.sh | bash \
  && apt-get install -y st2=${ST2_VERSION}-* \
  && rm -f /etc/apt/sources.list.d/StackStorm_*.list

# Add custom st2 empty config file, used to override original st2.conf
COPY files/st2.docker.conf /etc/st2/
COPY files/st2.user.conf /etc/st2/
# Overrides $ST2_CONF for st2ctl to inject several config files
COPY files/st2ctl /etc/default/

# Use custom logging config that'll stream all st2 service logs to stdout and never save to files
RUN cd /etc/st2; \
  for file in /etc/st2/logging.*.conf; do \
    rm -f ${file}; \
    ln -s logging.docker.conf ${file}; \
  done
COPY files/logging.docker.conf /etc/st2/

# Hardcode some st2.conf values needed for Docker
COPY files/st2.tmp.conf /tmp/
RUN apt-get install -y crudini \
  && crudini --merge /etc/st2/st2.conf < /tmp/st2.tmp.conf \
  && rm -f /tmp/st2.tmp.conf \
  && apt-get purge -y crudini \
  && apt-get autoremove -y

# Add Custom "StackStorm" welcome message
COPY files/.welcome.sh /etc/skel/.welcome
RUN install -m755 -ost2 -gst2 -d /home/st2
RUN echo '. /etc/skel/.welcome' >> /etc/skel/.profile
RUN echo '. /etc/skel/.welcome' >> /etc/skel/.bashrc
RUN echo '. /etc/skel/.welcome' >> /root/.bashrc
RUN echo '. /etc/skel/.welcome' >> /home/st2/.bashrc

# Used by all stackstorm services
VOLUME ["/etc/st2"]
WORKDIR /opt/stackstorm
