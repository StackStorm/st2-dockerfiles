ARG ST2_VERSION
FROM stackstorm/st2base:${ST2_VERSION}
LABEL com.stackstorm.component="st2actionrunner"

USER root

VOLUME ["/home/stanley/.ssh", "/opt/stackstorm/packs", "/opt/stackstorm/virtualenvs"]
CMD ["/opt/stackstorm/st2/bin/st2actionrunner", "--config-file=/etc/st2/st2.conf", "--config-file=/etc/st2/st2.docker.conf", "--config-file=/etc/st2/st2.user.conf"]
