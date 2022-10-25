# service-fledge
![](https://img.shields.io/github/license/open-horizon-services/service-fledge) ![](https://img.shields.io/badge/architecture-x86,_arm64-green) ![Contributors](https://img.shields.io/github/contributors/open-horizon-services/service-fledge.svg)

This is a simple, extensible, containerized version of the fledge open-source project designed to be deployed and managed by Open Horizon.  The fledge web UI is designed to be run in a web browser, so you will want to navigate to http://localhost:8082/ to use the software once it has been deployed.

## Prerequisites and setup

**Management Hub:** [Install the Open Horizon Management Hub](https://open-horizon.github.io/quick-start) or have access to an existing hub in order to publish this service and register your edge node.  You may also choose to use a downstream commercial distribution based on Open Horizon, such as IBM's Edge Application Manager.  If you'd like to use the Open Horizon community hub, you may [apply for a temporary account](https://wiki.lfedge.org/display/LE/Open+Horizon+Management+Hub+Developer+Instance) and have credentials sent to you.

**Edge Node:** You will need an x86 computer running Linux or macOS, or a Raspberry Pi computer (arm64) running Raspberry Pi OS or Ubuntu to install and use fledge deployed by Open Horizon.  You will need to install the Open Horizon agent software, anax, on the edge node and register it with a hub.

**Optional utilities to install:**  With `brew` on macOS (you may need to install _that_ as well), `apt-get` on Ubuntu or Raspberry Pi OS, `yum` on Fedora, install `gcc`, `make`, `git`, `jq`, `curl`, `net-tools`.  Not all of those may exist on all platforms, and some may already be installed.  But reflexively installing those has proven helpful in having the right tools available when you need them.

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

IMPORTANT: If you intend to publish the service to an Organization different than your account Org, set up the service Org separately:

``` shell
export SERVICE_ORG_ID=<service org ID>
```

## Installation

TBD: Determine if you need any plug-ins on the deployed instance.

NOTE: The REST API has been changed from the original default port of 8081 to 8083 since 8081 is reserved for the Open Horizon Agent REST API calls.  All ports can be overridden through environment variables.

Clone the `service-fledge` GitHub repo from a terminal prompt on the edge node and enter the folder where the artifacts were copied.

  NOTE: This assumes that `git` has been installed on the edge node.

  ``` shell
  git clone https://github.com/open-horizon-services/service-fledge.git
  cd service-fledge
  ```

Run `make clean` to confirm that the "make" utility is installed and working.

Confirm that you have the Open Horizon agent installed by using the CLI to check the version:

  ``` shell
  hzn version
  ```

  It should return values for both the CLI and the Agent (actual version numbers may vary from those shown):

  ``` text
  Horizon CLI version: 2.30.0-744
  Horizon Agent version: 2.30.0-744
  ```

  If it returns "Command not found", then the Open Horizon agent is not installed.

  If it returns a version for the CLI but not the agent, then the agent is installed but not running.  You may run it with `systemctl horizon start` on Linux or `horizon-container start` on macOS.

Check that the agent is in an unconfigured state, and that it can communicate with a hub.  If you have the `jq` utility installed, run `hzn node list | jq '.configstate.state'` and check that the value returned is "unconfigured".  If not, running `make agent-stop` or `hzn unregister -f` will put the agent in an unconfigured state.  Run `hzn node list | jq '.configuration'` and check that the JSON returned shows values for the "exchange_version" property, as well as the "exchange_api" and "mms_api" properties showing URLs.  If those do not, then the agent is not configured to communicate with a hub.  If you do not have `jq` installed, run `hzn node list` and eyeball the sections mentioned above.

## Usage

To manually run fledge locally as a test, enter `make`.  This will open a browser window, but it may do so before fledge is completely ready.  If you get a blank web page, wait about 10 seconds or so and reload the page.  Running `make attach` will connect you to a prompt running inside the container, and you can end that session by entering `exit`.  When you are done, run `make stop` in the terminal to end the test.

To create [the service definition](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/CreateService.md#build-publish-your-hw), publish it to the hub, and then form an agreement to download and run fledge, enter `make publish`.  When installation is complete and an agreement has been formed, exit the watch command with Control-C.  You may then open a browser pointing to fledge by entering `make browse` or visiting [http://localhost:8082/](http://localhost:8082/) in a web browser.

## Advanced details

### Debugging

The Makefile includes several targets to assist you in inspecting what is happening to see if they match your expectations.  They include:

`make log` to see both the event logs and the service logs.

`make deploy-check` to see if the properties and contstraints that you've configured match each other to potentially form an agreement.

`make test` to see if the web server is responding.

`make attach` to connect to the running container and open a shell inside it.

### All Makefile targets

* `default` - init run browse
* `init` - optionally create the docker volume
* `run` - manually run the fledge container locally as a test
* `browse` - open the fledge UI in a web browser
* `stop` - halt a locally-run container
* `dev` - manually run fledge locally and connect to a terminal in the container
* `attach` - connect to a terminal in the fledge container
* `test` - request the web UI from the terminal to confirm that it is running and available
* `clean` - remove the container image and docker volume
* `distclean` - clean (see above) AND unregister the node and remove the service files from the hub
* `build` - Use the Docker Desktop's buildx utility to create docker images for arm64 and amd64 architectures, then push the images to DockerHub
* `push` - N/A
* `publish-service` - Publish the service definition file to the hub in your organization
* `remove-service` - Remove the service definition file from the hub in your organization
* `publish-service-policy` - Publish the [service policy](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/PolicyRegister.md#service-policy) file to the hub in your org
* `remove-service-policy` - Remove the service policy file from the hub in your org
* `publish-deployment-policy` - Publish a [deployment policy](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/PolicyRegister.md#deployment-policy) for the service to the hub in your org
* `remove-deployment-policy` - Remove a deployment policy for the service from the hub in your org
* `agent-run` - register your agent's [node policy](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/PolicyRegister.md#node-policy) with the hub
* `publish` - Publish the service def, service policy, deployment policy, and then register your agent
* `agent-stop` - unregister your agent with the hub, halting all agreements and stopping containers
* `deploy-check` - confirm that a registered agent is compatible with the service and deployment
* `log` - check the agent event logs
