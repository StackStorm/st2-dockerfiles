ARG ST2_VERSION
FROM --platform=linux/amd64 stackstorm/st2:${ST2_VERSION}
LABEL com.stackstorm.component="st2actionrunner"

# Install utils used by st2 'linux' pack, part of StackStorm core
RUN apt-get install -y rsync \
  inetutils-traceroute \
  net-tools \
  dnsutils \
  sendmail

USER root

VOLUME ["/home/stanley/.ssh", "/opt/stackstorm/packs", "/opt/stackstorm/virtualenvs"]
CMD ["/opt/stackstorm/st2/bin/st2actionrunner", "--config-file=/etc/st2/st2.conf", "--config-file=/etc/st2/st2.docker.conf", "--config-file=/etc/st2/st2.user.conf"]
