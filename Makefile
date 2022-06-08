#!/usr/bin/env make
include Makehelp

IMAGE_NAME ?= cmdlabs/okta-utils
PLATFORM ?= linux/amd64
RELEASE_VERSION = 3.1.0
BUILD_VERSION ?= testing

ifdef CI_COMMIT_REF_NAME
	BUILD_VERSION=$(CI_COMMIT_REF_NAME)
endif

###Build
## Build Docker Image
dockerBuild:
	docker build --pull -t $(IMAGE_NAME):$(BUILD_VERSION) .
.PHONY: dockerBuild

## Use Buildx  e.g make dockerBuild PLATFORM=linux/amd64,linux/arm64
dockerBuildx:
#	docker --context default buildx build --platform $(PLATFORM) --pull --output type=docker -t $(IMAGE_NAME):$(BUILD_VERSION) .
	docker --context default buildx build --platform $(PLATFORM) --pull --load -t $(IMAGE_NAME):$(BUILD_VERSION) .
.PHONY: dockerBuildx

###Test
## Test Docker Image
dockerTest:
	docker run --rm --entrypoint=oktashell $(IMAGE_NAME):$(BUILD_VERSION) --help
	@echo "All tests completed successfully"
.PHONY: dockerTest

###Tag
## Tag and Push image with latest
dockerTagLatest:
	# docker pull $(IMAGE_NAME):$(BUILD_VERSION)
	docker tag $(IMAGE_NAME):$(BUILD_VERSION) $(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):latest
.PHONY: dockerTagLatest

## Tag and Push release version
tag:
	git tag $(RELEASE_VERSION)
	git push origin $(RELEASE_VERSION)
.PHONY: tag

###Push 
## Push Docker $(BUILD_VERSION) Image
dockerPush:
	docker push $(IMAGE_NAME):$(BUILD_VERSION)
.PHONY: dockerPush
