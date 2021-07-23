SHELL ?= /bin/bash
RED=\033[0;31m
NC=\033[0m
################################################################################
# Setup and Help                                                               #
################################################################################

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# build:
# 	docker build --build-arg CIRCLE_SHA1="$(SHA)" -t stackstorm/stackstorm:latest images/stackstorm

# dev-build:
# 	docker build --build-arg ST2_REPO=unstable --build-arg CIRCLE_SHA1="$(SHA)" -t stackstorm/stackstorm:local-dev images/stackstorm

env: ## This help.
	bin/write-env.sh conf

up: ## docker-compose up -d
	docker-compose up -d

down: ## docker-compose down
	docker-compose down

rmi: ## docker rmi dangling images
	docker rmi $$(docker images -f dangling=true -q)

exec: ## exec into stackstorm container
	docker-compose exec stackstorm /bin/bash

.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs
