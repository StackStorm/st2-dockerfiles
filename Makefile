ST2_VERSION ?= 3.0dev
DOCKER_TAG ?= ${ST2_VERSION}
SHELL := /bin/bash

# Build all required images (st2 base image plus st2 components)
.PHONY: build
build:
	@docker build \
		--pull \
		--no-cache \
		--build-arg ST2_VERSION=${ST2_VERSION} \
		-t stackstorm/st2:${DOCKER_TAG} base/
	@echo -e "\033[32mSuccessfully built \033[1mstackstorm/st2:${DOCKER_TAG}\033[0m\033[32m common Docker image with StackStorm version \033[1m${ST2_VERSION}\033[0m"
	@set -e; \
	for component in st2*; do \
		docker build \
			--no-cache \
			--build-arg ST2_VERSION=${ST2_VERSION} \
			--tag stackstorm/$$component:${DOCKER_TAG} \
			$$component/; \
		echo -e "\033[32mSuccessfully built \033[1mstackstorm/$$component:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	done

.PHONY: push
push:
	docker push  docker push stackstorm/st2:${DOCKER_TAG};
	@echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/st2:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m";
	@set -e; \
	for component in st2*; do \
		docker push stackstorm/$$component:${DOCKER_TAG}; \
		echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$component:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	done
