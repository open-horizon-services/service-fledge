# service-fledge

This is a simple, extensible, containerized version of the fledge open-source project designed to be deployed and managed by Open Horizon.

## Prerequisites and setup

### Development configuration

You will need Docker Desktop to create cross-platform images.

You need a DockerHub account so you can build and push the container image.  Override the default value by:

``` shell
export DOCKER_HUB_ID=<your Docker login name here>
```

Then when you run `make init` it will perform a docker login, along with setting up the Docker Desktop environment to use "buildx" to create cross-platform Docker Images.  You only need to run this once.  Running it twice will result in an error.  This is expected.

### Initial configuration

Export all environment variables for your desired Open Horizon credentials.

Override the default Open Horizon organization ID by:

``` shell
export HZN_ORG_ID=<your org ID>
```

If you intend to publish the service to an Organization different than your account Org, set up the service Org separately:

``` shell
export SERVICE_ORG_ID=<service org ID>
```

## Installation

Determine if you need the Web UI and any plug-ins on the deployed instance.

