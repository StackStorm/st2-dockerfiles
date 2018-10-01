ARG ST2_VERSION
FROM stackstorm/st2base:${ST2_VERSION}
LABEL com.stackstorm.component="st2timersengine"

USER st2

CMD ["/opt/stackstorm/st2/bin/st2timersengine", "--config-file=/etc/st2/st2.conf", "--config-file=/etc/st2/st2.docker.conf", "--config-file=/etc/st2/st2.user.conf"]
