# st2-dockerfiles
[![Circle CI](https://circleci.com/gh/StackStorm/st2-dockerfiles.svg?style=shield)](https://circleci.com/gh/StackStorm/workflows/st2-dockerfiles)

Dockerfiles to build, test and push to private [docker.stackstorm.com](https://docker.stackstorm.com) StackStorm images,
compatible with K8s Helm chart [stackstorm-ha](https://github.com/StackStorm/stackstorm-ha)

## Requirements
* [Docker](https://docs.docker.com/install/)

## Build
- `make build` - produce Docker images for all the required StackStorm components
  The following ENV vars can be passed to control the build settings:
  - `ST2_VERSION` (optional, ex: `2.8.0`) - StackStorm version to build components
  - `DOCKER_TAG` (optional, ex: `latest`) - produced Docker images will get this tag, defaults to ST2_VERSION when not set

## Push
- `make push` - push the Docker images for all the required StackStorm components to the private docker registry.
  The following ENV vars can be passed to control the push:
  - `DOCKER_TAG` (optional, ex: `2.8.0`) - tag pushed to the docker registry, defaults to ST2_VERSION when not set
