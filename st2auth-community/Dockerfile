ARG ST2_VERSION
FROM stackstorm/st2base:${ST2_VERSION}
LABEL com.stackstorm.component="st2auth"

USER st2

VOLUME ["/etc/st2/keys", "/opt/stackstorm/rbac"]
CMD ["/opt/stackstorm/st2/bin/st2auth", "--config-file=/etc/st2/st2.conf", "--config-file=/etc/st2/st2.docker.conf", "--config-file=/etc/st2/st2.user.conf"]
EXPOSE 9100
