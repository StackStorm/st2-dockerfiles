#!/bin/bash

# Get Ubuntu version
UBUNTU_VERSION=$(lsb_release -s -d)

VERSIONFILE=$(ls /opt/stackstorm/st2/lib/python*/site-packages/st2common/__init__.py)
ST2_VERSION=$(/opt/stackstorm/st2/bin/python -c "exec(open('$VERSIONFILE').read()); print(__version__)")

printf "Welcome to \033[1;38;5;208mStackStorm HA\033[0m \033[1m%s\033[0m (${UBUNTU_VERSION} %s %s)\n" "v${ST2_VERSION}" "$(uname -o)" "$(uname -m)"
printf " * Documentation: https://docs.stackstorm.com/\n"
printf " * Community: https://stackstorm.com/community-signup\n"
printf " * Forum: https://forum.stackstorm.com/\n\n"
# User logged into st2client container
if [ -n "$ST2CLIENT" ]; then
  printf " Here you can use StackStorm CLI. Examples:\n"
  printf "   st2 action list --pack=core\n"
  printf "   st2 run core.local cmd=date\n"
  printf "   st2 run core.local_sudo cmd='apt-get update' --tail\n"
  printf "   st2 execution list\n"
  printf "\n"
else
  printf " \033[1mNotice!\033[0m It's recommended to use \033[1mst2client\033[0m container to work with StackStorm cluster.\n"
fi
# Is K8s environment
if [ -n "$KUBERNETES_PORT" ]; then
  printf " \033[1mWarning!\033[0m Do not edit configs, packs or any content inplace as they will be overridden. Modify Helm values.yaml instead!\n"
fi
printf "\n"
