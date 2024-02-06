ARG ST2_VERSION
FROM --platform=linux/amd64 stackstorm/st2:${ST2_VERSION}
LABEL com.stackstorm.component="st2scheduler"

USER st2

CMD ["/opt/stackstorm/st2/bin/st2scheduler", "--config-file=/etc/st2/st2.conf", "--config-file=/etc/st2/st2.docker.conf", "--config-file=/etc/st2/st2.user.conf"]
