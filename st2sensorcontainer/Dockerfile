ARG ST2_VERSION
FROM stackstorm/st2:${ST2_VERSION}
LABEL com.stackstorm.component="st2sensorcontainer"

USER st2

VOLUME ["/opt/stackstorm/packs", "/opt/stackstorm/virtualenvs"]
CMD ["/opt/stackstorm/st2/bin/st2sensorcontainer", "--config-file=/etc/st2/st2.conf", "--config-file=/etc/st2/st2.docker.conf", "--config-file=/etc/st2/st2.user.conf"]
