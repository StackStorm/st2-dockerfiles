ARG ST2_VERSION
FROM --platform=linux/amd64 stackstorm/st2:${ST2_VERSION}
LABEL com.stackstorm.component="st2auth"

USER st2

VOLUME ["/etc/st2/keys", "/opt/stackstorm/rbac", "/etc/ssl/certs"]
CMD ["/opt/stackstorm/st2/bin/st2auth", "--config-file=/etc/st2/st2.conf", "--config-file=/etc/st2/st2.docker.conf", "--config-file=/etc/st2/st2.user.conf"]
EXPOSE 9100
