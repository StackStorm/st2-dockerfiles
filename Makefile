ST2_VERSION ?= 3.0dev
DOCKER_TAG ?= ${ST2_VERSION}
SHELL := /bin/bash

# Run Docker build for 1) base st2base image 2) child st2 component images 3) st2web-community
.PHONY: build
build:
	@docker build \
		--build-arg ST2_VERSION=${ST2_VERSION} \
		-t stackstorm/st2base:${DOCKER_TAG} st2base/
	@echo -e "\033[32mSuccessfully built \033[1mstackstorm/st2base\033[0m\033[32m common Docker image with StackStorm version \033[1m${ST2_VERSION}\033[0m"
	@set -e; \
	for component in st2*-community; do \
	  docker build \
  		--build-arg ST2_VERSION=${ST2_VERSION} \
	    --tag stackstorm/$$component:${DOCKER_TAG} \
	    $$component/; \
	  echo -e "\033[32mSuccessfully built \033[1mstackstorm/$$component:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	done

.PHONY: push
push:
	docker push stackstorm/st2base:${DOCKER_TAG};
	echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$component:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	@set -e; \
	for component in st2*-community; do \
	  docker push stackstorm/$$component:${DOCKER_TAG}; \
	  echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$component:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	done
