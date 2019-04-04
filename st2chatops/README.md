# Docker st2chatops
[![Go to st2chatops Docker Hub](https://img.shields.io/badge/Docker%20Hub-stackstorm/st2chatops-blue.svg)](https://hub.docker.com/r/stackstorm/st2chatops/)

Containerized `st2chatops` nodejs app, the StackStorm chatops bi-directional service integration, based on hubot.

## Configuration
### `ENV` vars
The following environment variables are required for `st2chatops` configuration:
- `ST2_AUTH_URL` (default: `http://st2auth:9100/`) - Remote StackStorm Auth service URL.
- `ST2_API_URL` (default: `http://st2api:9101/`) - Remote StackStorm API service URL.
- `ST2_STREAM_URL` (default: `http://st2stream:9102/`) - Remote StackStorm Stream service URL.
- `ST2_API_KEY` OR `ST2_AUTH_USERNAME` & `ST2_AUTH_PASSWORD` pair for ST2 authentication. We highly recommend to use API Key where possible.
- `HUBOT_ADAPTER` - Hubot Adapter to configure. Depending on adapter you're trying to enable, it will require more configuration. Please refer to [`st2chatops.env`]( https://github.com/StackStorm/st2chatops/blob/master/st2chatops.env) for more examples.

See https://docs.stackstorm.com/chatops/chatops.html#configuration and https://github.com/StackStorm/st2chatops/blob/master/st2chatops.env
for the list of supported chat Adapters and ENV variables to configure for each.

> Warning! All 3 remote StackStorm services should be DNS/network accessible for `st2chatops` container to start properly.
