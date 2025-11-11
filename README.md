Then when you run `make init` it will perform a docker login, along with setting up the Docker Desktop environment to use "buildx" to create cross-platform Docker Images. You only need to run this once. Running it twice will result in an error. This is expected.

### Initial configuration

Export all environment variables for your desired Open Horizon credentials.

Override the default Open Horizon organization ID by: