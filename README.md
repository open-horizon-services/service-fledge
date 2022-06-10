# service-fledge

This is a simple, extensible, containerized version of the fledge open-source project designed to be deployed and managed by Open Horizon.

## Prerequisites and setup

You will need Docker Desktop to create cross-platform images.

You need a DockerHub account so you can build and push the container image.  Override the default value by:

``` shell
export DOCKERHUB_ID=<your account here>
```

Then when you run `make init` it will perform a docker login, along with setting up the Docker Desktop environment to use "buildx" to create cross-platform Docker Images.

Override the default Open Horizon organization ID by:

``` shell
export HZN_ORG_ID=<your org ID>
```

Also, export all environment variables for your desired Open Horizon credentials.

## Install

