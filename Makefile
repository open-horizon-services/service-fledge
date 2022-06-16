# Multi-arch docker container instance of the open-source Fledge project intended for Open Horizon Linux edge nodes

export DOCKER_HUB_ID ?= joewxboy
export HZN_ORG_ID ?= examples

export SERVICE_NAME ?= service-fledge
export SERVICE_VERSION ?= 0.0.2
export SERVICE_ORG_ID ?= $(HZN_ORG_ID)
export PATTERN_NAME ?= pattern-fledge

# Don't allow the ARCH to be overridden at this time since only arm64 supported today
export ARCH := amd64
export DOCKER_IMAGE_BASE ?= $(DOCKER_HUB_ID)/service-fledge
export DOCKER_IMAGE_VERSION ?= 1.9.2

# Fledge customizations
export FLEDGE_REST_API_PORT ?= 8083
# not using 8081 since it conflicts with hzn CLI
export FLEDGE_SECURE_REST_API_PORT ?= 1995
export FLEDGE_WEB_UI_PORT ?= 8082

# Detect Operating System running Make
OS := $(shell uname -s)

default:

init:
# Get the latest official Dockerfile from fledge project
	@curl -sS https://raw.githubusercontent.com/fledge-iot/fledge-pkg/develop/docker/latest/Dockerfile.ubuntu1804-arm64 > Dockerfile.arm64
	@curl -sS https://raw.githubusercontent.com/fledge-iot/fledge-pkg/develop/docker/latest/Dockerfile.ubuntu2004 > Dockerfile.amd64
# ensure you are logged in so that you can push built images to DockerHub
	docker login
# enable cross-arch builds using buildx from Docker Desktop
	@docker buildx create --name mybuilder
	@docker buildx use mybuilder
	@docker buildx inspect --bootstrap

build:
# build arm64 container on x86_64 host machine and push to DockerHub
# NOTE: takes about 15 minutes to build on MacBook Pro
	@docker buildx build --push --platform linux/arm64 -t $(DOCKER_IMAGE_BASE)_arm64:$(DOCKER_IMAGE_VERSION) -f ./Dockerfile.arm64 .
	@docker buildx build --push --platform linux/amd64 -t $(DOCKER_IMAGE_BASE)_amd64:$(DOCKER_IMAGE_VERSION) -f ./Dockerfile.amd64 .

push:
	@echo push is not needed since build includes push

clean:
	-docker rmi $(DOCKER_IMAGE_BASE)_arm64:$(DOCKER_IMAGE_VERSION) 2> /dev/null || :
	-docker rmi $(DOCKER_IMAGE_BASE)_amd64:$(DOCKER_IMAGE_VERSION) 2> /dev/null || :

distclean: agent-stop remove-deployment-policy remove-service-policy remove-service clean

stop:
	@docker rm -f $(SERVICE_NAME) >/dev/null 2>&1 || :

run: stop
	@docker run -d \
		--name $(SERVICE_NAME) \
		-p $(FLEDGE_REST_API_PORT):8081 \
		-p $(FLEDGE_SECURE_REST_API_PORT):1995 \
		-p $(FLEDGE_WEB_UI_PORT):80 \
		$(DOCKER_IMAGE_BASE)_$(ARCH):$(DOCKER_IMAGE_VERSION)

attach: 
	@docker exec -it \
		`docker ps -aqf "name=$(SERVICE_NAME)"` \
		/bin/bash		

dev: run attach

test:
	@curl -sS http://127.0.0.1:$(FLEDGE_WEB_UI_PORT)/

browse:
ifeq ($(OS),Darwin)
	@open http://127.0.0.1:$(FLEDGE_WEB_UI_PORT)/
else
	@xdg-open http://127.0.0.1:$(FLEDGE_WEB_UI_PORT)/
endif

publish: publish-service publish-service-policy publish-deployment-policy agent-run browse

publish-service:
	@echo "=================="
	@echo "PUBLISHING SERVICE"
	@echo "=================="
	@hzn exchange service publish -O -P --json-file=horizon/service.definition.json
	@echo ""

remove-service:
	@echo "=================="
	@echo "REMOVING SERVICE"
	@echo "=================="
	@hzn exchange service remove -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-service-policy:
	@echo "========================="
	@echo "PUBLISHING SERVICE POLICY"
	@echo "========================="
	@hzn exchange service addpolicy -f horizon/service.policy.json $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

remove-service-policy:
	@echo "======================="
	@echo "REMOVING SERVICE POLICY"
	@echo "======================="
	@hzn exchange service removepolicy -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-deployment-policy:
	@echo "============================"
	@echo "PUBLISHING DEPLOYMENT POLICY"
	@echo "============================"
	@hzn exchange deployment addpolicy -f horizon/deployment.policy.json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)
	@echo ""

remove-deployment-policy:
	@echo "=========================="
	@echo "REMOVING DEPLOYMENT POLICY"
	@echo "=========================="
	@hzn exchange deployment removepolicy -f $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)
	@echo ""

agent-run:
	@echo "================"
	@echo "REGISTERING NODE"
	@echo "================"
	@hzn register -v --policy=horizon/node.policy.json
	@watch hzn agreement list

agent-stop:
	@echo "==================="
	@echo "UN-REGISTERING NODE"
	@echo "==================="
	@hzn unregister -f
	@echo ""

deploy-check:
	@hzn deploycheck all -t device -B horizon/deployment.policy.json --service=horizon/service.definition.json --service-pol=horizon/service.policy.json --node-pol=horizon/node.policy.json

log:
	@echo "========="
	@echo "EVENT LOG"
	@echo "========="
	@hzn eventlog list
	@echo ""
	@echo "==========="
	@echo "SERVICE LOG"
	@echo "==========="
	@hzn service log -f $(SERVICE_NAME)

.PHONY: build clean distclean init default stop run dev attach test browse push publish publish-service publish-service-policy publish-deployment-policy agent-run distclean deploy-check log remove-deployment-policy remove-service-policy remove-service