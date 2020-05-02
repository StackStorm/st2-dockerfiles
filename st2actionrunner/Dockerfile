ARG ST2_VERSION
ARG DOCKER_TAG
FROM stackstorm/st2:${DOCKER_TAG}
LABEL com.stackstorm.component="st2actionrunner"

# Install utils used by st2 'linux' pack, part of StackStorm core
RUN apt-get install -y rsync \
  inetutils-traceroute \
  net-tools \
  dnsutils

USER root

VOLUME ["/home/stanley/.ssh", "/opt/stackstorm/packs", "/opt/stackstorm/virtualenvs"]
CMD ["/opt/stackstorm/st2/bin/st2actionrunner", "--config-file=/etc/st2/st2.conf", "--config-file=/etc/st2/st2.docker.conf", "--config-file=/etc/st2/st2.user.conf"]
