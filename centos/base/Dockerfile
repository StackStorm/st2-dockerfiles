FROM centos:8 AS base

# Installs all necessary development packages for a full python compilation.
RUN dnf update -y \
    && dnf groupinstall -y "development tools" \
    && dnf install epel-release -y \
    && dnf -y install dnf-plugins-core -y \
    && dnf config-manager --set-enabled powertools -y \
    && dnf install -y \
        wget \
        gcc \
        openssl-devel \
        bzip2-devel \
        libffi \
        libffi-devel \
        epel-release \
        crudini \
        wget \
        zlib-devel \
        ncurses-devel \
        sqlite-devel \
        readline-devel \
        tk-devel \
        gdbm-devel \
        libpcap-devel \
        xz-devel \
        expat-devel \
        diffutils

## Installs Python3.7 from source - this is for running Packs with Python other than 3.6
RUN wget https://www.python.org/ftp/python/3.7.6/Python-3.7.6.tar.xz \
    && tar -xf ./Python-3.7.6.tar.xz \
    && cd ./Python-3.7.6 \
    && ./configure \
        --enable-optimizations \
        --with-ensurepip=install \
        # --enable-loadable-sqlite-extensions \
        # --enable-shared \
        # --with-system-expat \
        # --with-system-ffi \
    && make -j "$(nproc)" \
    && cd ..

FROM centos:8 AS release

ENV container docker

ARG ST2_VERSION
ARG ST2CHATOPS_VERSION
ARG ST2WEB_VERSION

RUN : "${ST2_VERSION:?Docker build argument needs to be set and non-empty.}"

LABEL maintainer="StackStorm <info@stackstorm.com>"
LABEL com.stackstorm.vendor="StackStorm"
LABEL com.stackstorm.support="Community"
LABEL com.stackstorm.version="${ST2_VERSION}"
LABEL com.stackstorm.name="StackStorm K8s HA CentOS"
LABEL com.stackstorm.description="Docker CentOS image, optimized to run StackStorm \
components and core services with Highly Available requirements in Kubernetes environment"
LABEL com.stackstorm.url="https://stackstorm.com/#product"



ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN dnf update -y \
    && dnf install -y \
        make \
        glibc-langpack-en \
        glibc-locale-source \
        glibc-langpack-en \
        glibc-locale-source \ 
        openssl \
        epel-release \
        sudo \
        wget \
        git \
        httpd-tools \
        systemd \
        bind \
        bind-utils \
        gcc \
        openldap-devel \
        gettext \
        patch \
        diffutils \
        zlib-devel \
    && localedef --no-archive -i en_US -f UTF-8 en_US.UTF-8 \
    && curl -s https://packagecloud.io/install/repositories/StackStorm/stable/script.rpm.sh | bash \
    && curl -sL https://rpm.nodesource.com/setup_14.x | bash - \
    && dnf install -y \
        st2-${ST2_VERSION} \
        st2web-${ST2WEB_VERSION} \
        st2chatops-${ST2CHATOPS_VERSION} \
        crudini \
    && dnf clean expire-cache -y \
    && dnf clean all


COPY --from=base /Python-3.7.6 /Python-3.7.6

RUN cd /Python-3.7.6 \
    && make -j "$(nproc)" altinstall \
    && cd .. \
    && rm -rf /Python-3.7.6

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-bundle.crt

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Add custom st2 empty config file, used to override original st2.conf
COPY conf/st2.docker.conf /etc/st2/
COPY conf/st2.user.conf /etc/st2/
# Overrides $ST2_CONF for st2ctl to inject several config files
COPY conf/st2ctl /etc/default/
COPY conf/logging.docker.conf /etc/st2/

# Creats the encryption key for the datastore
RUN mkdir -p /etc/st2/keys \
    && st2-generate-symmetric-crypto-key --key-path /etc/st2/keys/datastore_key.json \
    && usermod -a -G st2 st2 && chgrp st2 /etc/st2/keys && chmod o-r /etc/st2/keys \
    && chgrp st2 /etc/st2/keys/datastore_key.json && chmod o-r /etc/st2/keys/datastore_key.json

# Creates stanley user
RUN mkdir -p /home/stanley/.ssh && chmod 0700 /home/stanley/.ssh \
    && ssh-keygen -f /home/stanley/.ssh/stanley_rsa -P "" \
    && cat /home/stanley/.ssh/stanley_rsa.pub >> /home/stanley/.ssh/authorized_keys \
    && chown -R stanley:stanley /home/stanley/.ssh \
    && echo "stanley    ALL=(ALL)       NOPASSWD: SETENV: ALL" >> /etc/sudoers.d/st2 \
    && chmod 0440 /etc/sudoers.d/st2 \
    && sed -i -r "s/^Defaults\s+\+?requiretty/# Defaults +requiretty/g" /etc/sudoers

RUN dnf install dnf-plugins-core epel-release -y
# Generates nginx ssl key
RUN rpm --import http://nginx.org/keys/nginx_signing.key \
    && yum-config-manager --add-repo http://nginx.org/packages/centos/7/x86_64 \
    #&& dnf update -y \
    && dnf --disablerepo='epel' install -y nginx \
    && mkdir -p /etc/ssl/st2 \
    && openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/st2/st2.key -out /etc/ssl/st2/st2.crt \
      -days 365 -nodes -subj "/C=US/ST=California/L=Palo Alto/O=StackStorm/OU=Information \
      Technology/CN=$(hostname)"

# Copys all in one nginx config
COPY conf/st2-base.cnf /etc/nginx/conf.d/st2-base.cnf
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Setup 1ppc nginx
COPY conf/st2-https.template /etc/nginx/conf.d/st2-https.template
COPY conf/st2.conf-https.patch /tmp
RUN patch /etc/nginx/conf.d/st2-https.template < /tmp/st2.conf-https.patch 

# Systemd requires a SIGRTMIN+3 signal to terminate properly.
STOPSIGNAL SIGRTMIN+3

# Remove unnecessary systemd targets
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# named (dns server) service
RUN systemctl enable named.service

# Adds the run directory for systemd. This directory will need to run as a
# tmpfs directory for systemd to properly work.
VOLUME /run

# Systemd enabling all st2 components to run at container start time.
# Results tracker removed https://github.com/StackStorm/st2/issues/5070
RUN systemctl enable \
        st2actionrunner \
        st2api \
        st2auth \
        st2garbagecollector \
        st2notifier \
        st2rulesengine \
        st2sensorcontainer \
        st2scheduler \
        st2workflowengine \
        st2timersengine \
        st2workflowengine \
        nginx

# Systemd runs as user st2. This changes the log files to allow st2 to run
RUN chown -R st2 /var/log/st2

# Opens ssh and https ports.
EXPOSE 22 443

# Used by all stackstorm services
VOLUME ["/etc/st2"]
WORKDIR /opt/stackstorm

COPY bin/entrypoint.sh /st2-docker/bin/entrypoint.sh

ENTRYPOINT ["/st2-docker/bin/entrypoint.sh"]

# For all-in-one docker-compose development
RUN mkdir /opt/stackstorm/packs.dev

# Update oslo/crudini
RUN source /opt/stackstorm/st2/bin/activate && pip install --upgrade oslo.config
COPY conf/st2.conf /etc/st2/st2.conf
RUN pip3.7 install virtualenv
