ST2_VERSION ?= 3.9dev
DOCKER_TAG ?= ${ST2_VERSION}
RELEASE_TAG_REGEX := [^dev]$$
SHELL := /bin/bash

# Determine the base image based on ST2_VERSION
# For ST2_VERSION 3.8.* and 3.8dev, use ubuntu:focal
# For ST2_VERSION 3.9.* and 3.9dev, use ubuntu:jammy
# NOTE - Once we have a stable release of 3.9, we will need to update this
# to use ubuntu:jammy for all 3.9 versions and remove the check for 3.9dev
BASE_IMAGE := $(shell \
	if [[ "${ST2_VERSION}" =~ ^'3.8'('.'[0-9]+|dev)?$$ ]]; then \
		echo "ubuntu:focal"; \
	elif [[ "${ST2_VERSION}" =~ ^'3.9'('.'[0-9]+|dev)?$$ ]]; then \
		echo "ubuntu:jammy"; \
	else \
		echo "ERROR: Unsupported ST2_VERSION '${ST2_VERSION}'" >&2; \
		exit 1; \
	fi \
)

# supported values of the TAG_UPDATE_FLAG
# 0 = no additional tags to be set
# 1 = add the major.minor tag
# 2 = add the tags major and major.minor
# 3 = add the tags major, major.minor and latest
TAG_UPDATE_FLAG := $(shell ./determine_needed_tags.sh st2 ${ST2_VERSION})

ifneq ($(shell echo ${ST2_VERSION} | grep -E "${RELEASE_TAG_REGEX}"), )
	RELEASE_VERSION := true
	MAJOR := $(word 1, $(subst ., ,${ST2_VERSION}))
	MINOR := $(word 2, $(subst ., ,${ST2_VERSION}))
	PATCH := $(word 3, $(subst ., ,${ST2_VERSION}))
else
	RELEASE_VERSION := false
endif

# Build all required images (st2 base image plus st2 components)
.PHONY: build
build: verify_tag_update_flag
	@docker build \
		--pull \
		--no-cache \
		--build-arg ST2_VERSION=${ST2_VERSION} \
		--build-arg BASE_IMAGE=${BASE_IMAGE} \
		-t stackstorm/st2:${DOCKER_TAG} base/
	@echo -e "\033[32mSuccessfully built \033[1mstackstorm/st2:${DOCKER_TAG}\033[0m\033[32m common Docker image with StackStorm version \033[1m${ST2_VERSION}\033[0m (Base: ${BASE_IMAGE})"
	@set -e; \
	for component in st2*; do \
		docker build \
			--no-cache \
			--build-arg ST2_VERSION=${ST2_VERSION} \
			--build-arg BASE_IMAGE=${BASE_IMAGE} \
			--tag stackstorm/$$component:${DOCKER_TAG} \
			$$component/; \
		echo -e "\033[32mSuccessfully built \033[1mstackstorm/$$component:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m (Base: ${BASE_IMAGE})"; \
	done
ifeq ($(RELEASE_VERSION), true)
ifeq ($(TAG_UPDATE_FLAG), 1)
	for image in st2 st2*; do \
		docker tag stackstorm/$$image:${DOCKER_TAG} stackstorm/$$image:${MAJOR}.${MINOR}; \
		echo -e "\033[32mSuccessfully tagged \033[1mstackstorm/$$image:${DOCKER_TAG}\033[0m\033[32m with \033[1mstackstorm/$$image:${MAJOR}.${MINOR}\033[0m"; \
	done
else ifeq ($(TAG_UPDATE_FLAG), 2)
	for image in st2 st2*; do \
		docker tag stackstorm/$$image:${DOCKER_TAG} stackstorm/$$image:${MAJOR}; \
		docker tag stackstorm/$$image:${DOCKER_TAG} stackstorm/$$image:${MAJOR}.${MINOR}; \
		echo -e "\033[32mSuccessfully tagged \033[1mstackstorm/$$image:${DOCKER_TAG}\033[0m\033[32m with \033[1mstackstorm/$$image:${MAJOR}\033[0m\033[32m and \033[1mstackstorm/$$image:${MAJOR}.${MINOR}\033[0m"; \
	done
else ifeq ($(TAG_UPDATE_FLAG), 3)
	for image in st2 st2*; do \
		docker tag stackstorm/$$image:${DOCKER_TAG} stackstorm/$$image:${MAJOR}; \
		docker tag stackstorm/$$image:${DOCKER_TAG} stackstorm/$$image:${MAJOR}.${MINOR}; \
		docker tag stackstorm/$$image:${DOCKER_TAG} stackstorm/$$image:latest; \
		echo -e "\033[32mSuccessfully tagged \033[1mstackstorm/$$image:${DOCKER_TAG}\033[0m\033[32m with \033[1mstackstorm/$$image:${MAJOR}\033[0m\033[32m, \033[1mstackstorm/$$image:${MAJOR}.${MINOR}\033[32m and \033[1mstackstorm/$$image:latest\033[0m"; \
	done
endif
endif

.PHONY: push
push: verify_tag_update_flag
	docker push stackstorm/st2:${DOCKER_TAG};
	@echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/st2:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m";
	@set -e; \
	for component in st2*; do \
		docker push stackstorm/$$component:${DOCKER_TAG}; \
		echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$component:${DOCKER_TAG}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	done
ifeq ($(RELEASE_VERSION), true)
ifeq ($(TAG_UPDATE_FLAG), 1)
	for image in st2 st2*; do \
		docker push stackstorm/$$image:${MAJOR}.${MINOR}; \
		echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$image:${MAJOR}.${MINOR}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	done
else ifeq ($(TAG_UPDATE_FLAG), 2)
	for image in st2 st2*; do \
		docker push stackstorm/$$image:${MAJOR}; \
		echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$image:${MAJOR}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
		docker push stackstorm/$$image:${MAJOR}.${MINOR}; \
		echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$image:${MAJOR}.${MINOR}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	done
else ifeq ($(TAG_UPDATE_FLAG), 3)
	for image in st2 st2*; do \
		docker push stackstorm/$$image:${MAJOR}; \
		echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$image:${MAJOR}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
		docker push stackstorm/$$image:${MAJOR}.${MINOR}; \
		echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$image:${MAJOR}.${MINOR}\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
		docker push stackstorm/$$image:latest; \
		echo -e "\033[32mSuccessfully pushed \033[1mstackstorm/$$image:latest\033[0m\033[32m Docker image for StackStorm version \033[1m${ST2_VERSION}\033[0m"; \
	done
endif
endif

verify_tag_update_flag:
ifeq ($(RELEASE_VERSION), true)
ifneq ($(shell echo "${TAG_UPDATE_FLAG}" | grep -vE "^[0-3]"),)
	@echo -e "Failed to identify the tags to be set."
	@echo -e "\033[31mNo images were tagged due to an error when determining the correct tags: ${TAG_UPDATE_FLAG}\033[0m"
	exit 1
endif
endif
