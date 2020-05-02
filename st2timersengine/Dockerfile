ARG ST2_VERSION
ARG DOCKER_TAG
FROM stackstorm/st2:${DOCKER_TAG}
LABEL com.stackstorm.component="st2timersengine"

USER st2

CMD ["/opt/stackstorm/st2/bin/st2timersengine", "--config-file=/etc/st2/st2.conf", "--config-file=/etc/st2/st2.docker.conf", "--config-file=/etc/st2/st2.user.conf"]
