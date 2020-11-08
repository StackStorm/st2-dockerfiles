ST2_VERSION ?= 3.4dev
DOCKER_TAG ?= ${ST2_VERSION}
RELEASE_TAG_REGEX := [^dev]$$
SHELL := /bin/bash

ifneq ($(shell echo ${ST2_VERSION} | grep -E "${RELEASE_TAG_REGEX}"), )
          RELEASE_VERSION = true
          MAJOR = $(word 1, $(subst ., ,${ST2_VERSION}))
          MINOR = $(word 2, $(subst ., ,${ST2_VERSION}))
          PATCH = $(word 3, $(subst ., ,${ST2_VERSION}))
else
          RELEASE_VERSION = false
endif

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
ifeq ($(RELEASE_VERSION), true)
	for image in st2 st2*; do \
	    docker tag stackstorm/$$image:${DOCKER_TAG} stackstorm/$$image:${MAJOR}; \
	    docker tag stackstorm/$$image:${DOCKER_TAG} stackstorm/$$image:${MAJOR}.${MINOR}; \
	    echo -e "\033[32mSuccessfully tagged \033[1mstackstorm/$$image:${DOCKER_TAG}\033[0m\033[32m with \033[1mstackstorm/$$image:${MAJOR}\033[0m\033[32m and \033[1mstackstorm/$$image:${MAJOR}.${MINOR}\033[0m"; \
	done
endif

.PHONY: push
push:
	docker push stackstorm/st2:${DOCKER_TAG};
	@echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/st2:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m";
	@set -e; \
	for component in st2*; do \
		docker push stackstorm/$$component:${DOCKER_TAG}; \
		echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$component:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	done
ifeq ($(RELEASE_VERSION), true)
	for image in st2 st2*; do \
	    docker push stackstorm/$$image:${MAJOR}; \
	    echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$image:${MAJOR}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	    docker push stackstorm/$$image:${MAJOR}.${MINOR}; \
	    echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$image:${MAJOR}.${MINOR}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	done
endif