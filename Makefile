# Multi-arch docker container instance of the open-source Fledge project intended for Open Horizon Linux edge nodes

export DOCKER_HUB_ID ?= joewxboy
export HZN_ORG_ID ?= examples

export SERVICE_NAME ?= service-fledge
export SERVICE_VERSION ?= 0.0.2
export SERVICE_ORG_ID ?= $(HZN_ORG_ID)
export PATTERN_NAME ?= pattern-fledge

# Don't allow the ARCH to be overridden at this time since only arm64 supported today
export ARCH := arm64
export DOCKER_IMAGE_BASE ?= $(DOCKERHUB_ID)/service-fledge

init:
# Get the latest official Dockerfile from fledge project
	@curl -sS https://raw.githubusercontent.com/fledge-iot/fledge-pkg/develop/docker/latest/Dockerfile.ubuntu1804-arm64 > Dockerfile.arm64
# enable cross-arch builds using buildx from Docker Desktop
	@docker buildx create --name mybuilder
	@docker buildx use mybuilder
	@docker buildx inspect --bootstrap
# ensure you are logged in so that you can push built images to DockerHub
	docker login

build:
# build arm64 container on x86_64 host machine and push to DockerHub
# NOTE: takes about 15 minutes to build on MacBook Pro
	docker buildx build --push --platform linux/arm64 -t $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION) -f ./Dockerfile.$(ARCH) .

clean:
	-docker rmi $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION) 2> /dev/null || :

.PHONY: build clean init