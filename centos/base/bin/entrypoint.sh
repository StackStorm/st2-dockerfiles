#!/bin/bash

# Create htpasswd file and login to st2 using specified username/password
htpasswd -b /etc/st2/htpasswd ${ST2_USER} ${ST2_PASSWORD}

mkdir -p /root/.st2

ROOT_CONF=/root/.st2/config
ST2_CONF=/etc/st2/st2.conf
LOG_LEVEL=${LOG_LEVEL:="INFO"}

touch ${ROOT_CONF}

crudini --set ${ROOT_CONF} credentials username ${ST2_USER}
crudini --set ${ROOT_CONF} credentials password ${ST2_PASSWORD}

# change the logging to use logging docker configuration
crudini --set ${ST2_CONF} stream logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} sensorcontainer logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} rulesengine logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} actionrunner logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} resultstracker logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} notifier logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} exporter logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} garbagecollector logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} timersengine logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} auth logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} api logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} workflowengine logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} workflow_engine logging /etc/st2/logging.docker.conf
crudini --set ${ST2_CONF} scheduler logging /etc/st2/logging.docker.conf

# change the systemd targets to use the st2 configuration for logs
SYSD_PATH=/etc/systemd/system/multi-user.target.wants

## ST2API Service
crudini --set ${SYSD_PATH}/st2api.service Service User root
crudini --set ${SYSD_PATH}/st2api.service Service Group root
crudini --set ${SYSD_PATH}/st2api.service Service Environment "\"DAEMON_ARGS=-k eventlet -b 127.0.0.1:9101 --workers 1 --threads 1 --graceful-timeout 10 --timeout 30 --log-config /etc/st2/logging.docker.conf\""
crudini --set ${SYSD_PATH}/st2api.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/gunicorn st2api.wsgi:application $DAEMON_ARGS &> /proc/1/fd/1'"

## ST2AUTH Service
crudini --set ${SYSD_PATH}/st2auth.service Service User root
crudini --set ${SYSD_PATH}/st2auth.service Service Group root
crudini --set ${SYSD_PATH}/st2auth.service Service Environment "\"DAEMON_ARGS=-k eventlet -b 127.0.0.1:9100 --workers 1 --threads 1 --graceful-timeout 10 --timeout 30 --log-config /etc/st2/logging.docker.conf\""
crudini --set ${SYSD_PATH}/st2auth.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/gunicorn st2auth.wsgi:application $DAEMON_ARGS &> /proc/1/fd/1'"

## ST2STREAM Service
crudini --set ${SYSD_PATH}/st2stream.service Service User root
crudini --set ${SYSD_PATH}/st2stream.service Service Group root
crudini --set ${SYSD_PATH}/st2stream.service Service Environment "\"DAEMON_ARGS=-k eventlet -b 127.0.0.1:9102 --workers 1 --threads 10 --graceful-timeout 10 --timeout 30 --log-config /etc/st2/logging.docker.conf\""
crudini --set ${SYSD_PATH}/st2stream.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/gunicorn st2stream.wsgi:application $DAEMON_ARGS &> /proc/1/fd/1'"

## ST2ACTIONRUNNER Service
crudini --set ${SYSD_PATH}/st2actionrunner.service Service User root
crudini --set ${SYSD_PATH}/st2actionrunner.service Service Group root
crudini --set ${SYSD_PATH}/st2actionrunner.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/python /opt/stackstorm/st2/bin/st2actionrunner --config-file /etc/st2/st2.conf --config-file /etc/st2/st2.docker.conf &> /proc/1/fd/1'"

## ST2GARBAGECOLLECTOR Service
crudini --set ${SYSD_PATH}/st2garbagecollector.service Service User root
crudini --set ${SYSD_PATH}/st2garbagecollector.service Service Group root
crudini --set ${SYSD_PATH}/st2garbagecollector.service Service Environment "\"DAEMON_ARGS=--config-file /etc/st2/st2.conf --config-file /etc/st2/st2.docker.conf\""
crudini --set ${SYSD_PATH}/st2garbagecollector.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/st2garbagecollector $DAEMON_ARGS &> /proc/1/fd/1'"

## ST2NOTIFIER Service
crudini --set ${SYSD_PATH}/st2notifier.service Service User root
crudini --set ${SYSD_PATH}/st2notifier.service Service Group root
crudini --set ${SYSD_PATH}/st2notifier.service Service Environment "\"DAEMON_ARGS=--config-file /etc/st2/st2.conf --config-file /etc/st2/st2.docker.conf\""
crudini --set ${SYSD_PATH}/st2notifier.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/st2notifier $DAEMON_ARGS &> /proc/1/fd/1'"

## ST2RESULTSTRACKER Service
crudini --set ${SYSD_PATH}/st2resultstracker.service Service User root
crudini --set ${SYSD_PATH}/st2resultstracker.service Service Group root
crudini --set ${SYSD_PATH}/st2resultstracker.service Service Environment "\"DAEMON_ARGS=--config-file /etc/st2/st2.conf --config-file /etc/st2/st2.docker.conf\""
crudini --set ${SYSD_PATH}/st2resultstracker.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/st2resultstracker $DAEMON_ARGS &> /proc/1/fd/1'"

## ST2RULESENGINE Service
crudini --set ${SYSD_PATH}/st2rulesengine.service Service User root
crudini --set ${SYSD_PATH}/st2rulesengine.service Service Group root
crudini --set ${SYSD_PATH}/st2rulesengine.service Service Environment "\"DAEMON_ARGS=--config-file /etc/st2/st2.conf --config-file /etc/st2/st2.docker.conf\""
crudini --set ${SYSD_PATH}/st2rulesengine.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/st2rulesengine $DAEMON_ARGS &> /proc/1/fd/1'"

## ST2SCHEDULER Service
crudini --set ${SYSD_PATH}/st2scheduler.service Service User root
crudini --set ${SYSD_PATH}/st2scheduler.service Service Group root
crudini --set ${SYSD_PATH}/st2scheduler.service Service Environment "\"DAEMON_ARGS=--config-file /etc/st2/st2.conf --config-file /etc/st2/st2.docker.conf\""
crudini --set ${SYSD_PATH}/st2scheduler.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/st2scheduler $DAEMON_ARGS &> /proc/1/fd/1'"

## ST2SENSORCONTAINER Service
crudini --set ${SYSD_PATH}/st2sensorcontainer.service Service User root
crudini --set ${SYSD_PATH}/st2sensorcontainer.service Service Group root
crudini --set ${SYSD_PATH}/st2sensorcontainer.service Service Environment "\"DAEMON_ARGS=--config-file /etc/st2/st2.conf --config-file /etc/st2/st2.docker.conf\""
crudini --set ${SYSD_PATH}/st2sensorcontainer.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/st2sensorcontainer $DAEMON_ARGS &> /proc/1/fd/1'"

## ST2TIMERSENGINE Service
crudini --set ${SYSD_PATH}/st2timersengine.service Service User root
crudini --set ${SYSD_PATH}/st2timersengine.service Service Group root
crudini --set ${SYSD_PATH}/st2timersengine.service Service Environment "\"DAEMON_ARGS=--config-file /etc/st2/st2.conf --config-file /etc/st2/st2.docker.conf\""
crudini --set ${SYSD_PATH}/st2timersengine.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/st2timersengine $DAEMON_ARGS &> /proc/1/fd/1'"

## ST2WORKFLOWENGINE Service
crudini --set ${SYSD_PATH}/st2workflowengine.service Service User root
crudini --set ${SYSD_PATH}/st2workflowengine.service Service Group root
crudini --set ${SYSD_PATH}/st2workflowengine.service Service Environment "\"DAEMON_ARGS=--config-file /etc/st2/st2.conf --config-file /etc/st2/st2.docker.conf\""
crudini --set ${SYSD_PATH}/st2workflowengine.service Service ExecStart "/bin/sh -c 'exec /opt/stackstorm/st2/bin/st2workflowengine $DAEMON_ARGS &> /proc/1/fd/1'"

# set log level
crudini --set /etc/st2/logging.docker.conf logger_root level ${LOG_LEVEL}
crudini --set /etc/st2/logging.docker.conf handler_consoleHandler level ${LOG_LEVEL}
# set auth configuration to true by default
crudini --set ${ST2_CONF} auth enable True

ST2_CONF=/etc/st2/st2.conf
crudini --set ${ST2_CONF} content packs_base_paths /opt/stackstorm/packs.dev

ST2_API_URL=${ST2_API_URL:-http://127.0.0.1:9101}

# Sets the metrics host
if [ ! -z ${STATSD_HOST} ];then
  crudini --set ${ST2_CONF} metrics host ${STATSD_HOST}
fi

if [ ! -z ${STATSD_PORT} ];then
  crudini --set ${ST2_CONF} metrics port ${STATSD_PORT}
fi


crudini --set ${ST2_CONF} auth api_url ${ST2_API_URL}
crudini --set ${ST2_CONF} messaging url \
  amqp://${RABBITMQ_DEFAULT_USER}:${RABBITMQ_DEFAULT_PASS}@${RABBITMQ_HOST}:${RABBITMQ_PORT}
crudini --set ${ST2_CONF} coordination url \
  redis://:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}
crudini --set ${ST2_CONF} database host ${MONGO_HOST}
crudini --set ${ST2_CONF} database port ${MONGO_PORT}
if [ ! -z ${MONGO_DB} ]; then
  crudini --set ${ST2_CONF} database db_name ${MONGO_DB}
fi
if [ ! -z ${MONGO_USER} ]; then
  crudini --set ${ST2_CONF} database username ${MONGO_USER}
fi
if [ ! -z ${MONGO_PASS} ]; then
  crudini --set ${ST2_CONF} database password ${MONGO_PASS}
fi

## Garbage Collection
crudini --set ${ST2_CONF} garbagecollector action_executions_ttl 30
crudini --set ${ST2_CONF} garbagecollector action_executions_output_ttl 30
crudini --set ${ST2_CONF} garbagecollector trigger_instances_ttl 30

# Ensure the base st2 nginx config is used

( cd /etc/nginx/conf.d && ln -sf st2-base.cnf st2.conf )

exec /sbin/init