# Multi-arch docker container instance of the open-source Fledge project intended for Open Horizon Linux edge nodes

DOCKERHUB_ID ?= joewxboy
SERVICE_NAME := "service-fledge"
SERVICE_VERSION := "0.0.1"
PATTERN_NAME := "pattern-fledge"
ARCH ?= "arm"
HZN_ORG_ID ?= examples
DOCKER_IMAGE_BASE ?= "openhorizon/service-fledge"

e current architecture
build:
  docker build -t $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION) -f ./Dockerfile.$(ARCH) .

clean:
  -docker rmi $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION) 2> /dev/null || :

.PHONY: build clean
 
