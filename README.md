# st2community-dockerfiles
[![Circle CI](https://circleci.com/gh/StackStorm/st2community-dockerfiles.svg?style=shield&circle-token=c95b686e92e5927403b478b4becc2962ba28399c)](https://circleci.com/gh/StackStorm/workflows/st2community-dockerfiles)

Dockerfiles to build, test and push to private [docker.stackstorm.com](https://docker.stackstorm.com) StackStorm Community images,
compatible with K8s Helm chart [stackstorm-community-ha](https://github.com/StackStorm/stackstorm-community-ha)

## Requirements
* [Docker](https://docs.docker.com/install/)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html), - for pushing images to AWS ECR

## Build
- `make build` - produce Docker images for all the required StackStorm Community components
  The following ENV vars can be passed to control the build settings:
  - `ST2_VERSION` (optional, ex: `2.8.0`) - StackStorm version to build components
  - `DOCKER_TAG` (optional, ex: `latest`) - produced Docker images will get this tag, defaults to ST2_VERSION when not set

## Push
- `make push` - push the Docker images for all the required StackStorm Community components to the private docker registry.
  The following ENV vars can be passed to control the push:
  - `DOCKER_TAG` (optional, ex: `2.8.0`) - tag pushed to the docker registry, defaults to ST2_VERSION when not set
