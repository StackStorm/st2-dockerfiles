#!/bin/bash

# Check https://packagecloud.io/StackStorm/stable for newer versions
ST2_VERSION="3.5.0-1"
ST2WEB_VERSION="3.5.0-1"
ST2CHATOPS_VERSION="3.5.0-1"

docker build  \
  --build-arg ST2_VERSION=${ST2_VERSION} \
  --build-arg ST2WEB_VERSION=${ST2WEB_VERSION} \
  --build-arg ST2CHATOPS_VERSION=${ST2CHATOPS_VERSION} \
  -t stackstorm/st2/all-in-one-st2:${ST2_VERSION} \
  .
  
