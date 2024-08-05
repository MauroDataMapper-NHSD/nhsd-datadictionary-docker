# Mauro Data Mapper for NHS Data Dictionary

These instructions will explain how to setup and run the Mauro Data Mapper so it can be used to manage the NHS Data Dictionary. This README covers the use of Docker to build images and run the Mauro Data Mapper in containers.

# Deployment

See the ***`aws-deployment.md`*** document in the **`./doc`** directory of this
repository for the deployment process.

# Docker

Before continuing, install Docker and Docker Compose tools by following the [Get Docker](https://docs.docker.com/get-docker/) guide. Installing Docker Desktop is usually the quickest way to install all the necessary tools, and is best for local development/testing.

**Note:** Running Docker Desktop on Windows may require admin privileges.

Alternatively, you can manually install the Docker Engine and related tools by following these guides (Linux):

-   [Install Docker Engine](https://docs.docker.com/engine/install/)
-   [Post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/)

These steps are more useful if setting up a virtual machine for deploying Mauro Data Mapper to a target environment for test/production use.

# System Requirements

Minimum:

- 2 CPUs
- 8 GB RAM

Recommended:

- 4 CPUs
- 16 GB RAM

These requirements account for operating system requirements too. However, the expected operations required for managing the NHS Data Dictionary are expected to be resource intensive, particular on disk I/O and memory. Therefore, you should consider the recommended requirements where possible.

The default install of Docker inside Linux configures the Docker Engine with unlimited access to the server's resources. However, if running in Windows or macOS the Docker Toolbox will need to be configured. See [Mauro Data Mapper - Docker Setup](https://maurodatamapper.github.io/installing/docker-setup/) for more details.

# Quick Start

Follow these quick start steps to build and run the Docker containers on your ***local machine environment***.

First, build the container images by running the following command with the current directory set to the root of this repository:

```bash
    docker compose build
```

This will create two images:

- `postgres` - For running the Postgres database used by Mauro Data Mapper.
- `mauro-data-mapper` - Runs an Apache Tomcat web server for hosting the Mauro Data Mapper web applications, including the customised NHS Data Dictionary Orchestrator.

Once the images are ready, run the containers in detached mode as follows:

```bash
    docker compose up -d
```

This starts the two container images as containers as follows:

-   `postgres` - Listens on port 5432 by default to connect to the Postgresql database via a client e.g. pgAdmin or psql.
-   `mauro-data-mapper` - Hosts the Tomcat web applications, accessible via port 80 by default.

The port number for Mauro and some other parameters are set via envionment variables — these can either be set manually or via the `.env.*` files.

**Note:** After starting the `mauro-data-mapper` container, there is an initial load time that happens before it will respond to web traffic. View the logs in the container to know when it is ready - usually when a log message `org.apache.catalina.startup.Catalina.start Server startup in [x] milliseconds` appears.

**Note:** There is also a more convenient way to perform both (re)build images and start containers in command if you prefer:

```bash
    docker compose up -d --build
```

Once running, in a browser navigate to:

- http://localhost - Access the main Mauro Data Mapper application
- http://localhost/orchestration - Access the NHS Data Dictionary Orchestrator

You can also access the Mauro backend via a HTTP request tool, like Postman or Curl, via http://localhost.

Sign in to the Mauro Data Mapper and the NHS Data Dictionary Orchestrator using the default username/password as explained in the [Mauro setup instructions](https://maurodatamapper.github.io/installing/docker-install/#default-username-password) - though you will be prompted to change the initial password after signing in first time. You are then recommended to create further user accounts via Mauro Data Mapper.

Finally, to shutdown the applications and stop the containers, run:

```bash
    docker compose down
```

# Updating

The `Dockerfile` for the `mauro-data-mapper` container image fetches the Mauro commits/snapshots from git. By default, the `develop` branch of each required repository/snapshot is used during the build, so that the latest changes can be incorporated and run.

To update the running instance:

```bash
    # Stop/shutdown any running application
    docker compose down

    # Rebuild the container images with the latest snapshots
    docker compose build

    # Start the containers again
    docker compose up -d
```

# Volumes and Files

The following shared volumes will be created and used:

- `postgres12` - For storing the postgresql database
- `lucene_index` - For storing the Lucense search index used by Mauro.

Stopping the containers will not remove these volumes, they will persist as storage which the containers connect to.

Docker top-level volumes are stored on the host under `/var/lib/docker/volumes/` by default but this can be modified (along with other Docker data) by configuring the location in `/etc/docker/daemon.json` with the line:

```
 "data-root": "/some/other/path"
```

## Log File

To view the log file generated by Mauro, it is accessible via:

- Source (host): `shared_volumes/logs/maurodatamapper/mauro-data-mapper/mauro-data-mapper.log`
- Destination (container): `/usr/local/tomcat/logs/mauro-data-mapper/mauro-data-mapper.log`

Reading the log file is more useful than viewing the Docker container logs, since the container logs only show STDOUT of the process - this only contains errors and warnings. The log file, however, also shows info and debug messages.

To watch a live stream of the log file, use:

```bash
    tail -f mauro-data-mapper.log
```

# Cleanup

Continually building docker images will leave a lot of loose snapshot images floating around. Use the following commands to cleanup dangling resources: 

*   Clean up stopped containers - `docker rm $(docker ps -a -q)`
*   Clean up dangling images - `docker rmi $(docker images -q --filter "dangling=true")`
*   Clean up dangling volumes - `docker volume rm $(docker volume ls -qf dangling=true)`

For when `/var/lib/docker` gets full there is also a `docker system prune` command that will remove all unused containers, networks, images (dangling and unused) and volumes. Refer to the documentation for more details: https://docs.docker.com/reference/cli/docker/system/prune/

# Docker Compose

The `docker-compose.yml` file controls the build and setup of the containers. It is split into the two services required - the `postgres` and `mauro-data-mapper` services, which will build the images.

Run this command in a terminal to see the final `docker-compose.yml` file that will be used once all environment variables are interpolated in:

```bash
    docker compose config
```

The following sections explain the setup in more detail.

## Environment Variables

The `docker-compose.yml` file has been written to allow [environment variables](https://docs.docker.com/compose/environment-variables/) to be passed into the container images for building/running correctly for your environment. By default, the `.env` file in the repo has set key variables to:

- Pull commits/snapshots for Mauro and the NHS tools from the latest builds (rather than published, release builds).
- Set the port mapping to access the web applications to port 80.
- Tag the Docker application build with the `nhsd-snapshot` name.

These are suitable for a local development build. However, you may need to adjust these for deploying to other environments - such as building to a particulat git commit/tag for a known version.

You can create multiple `.env` files and name them appropriately e.g. `.env.live`, `.env.test` etc. To use an `.env` file that is not named after the default, use the `--env-file` argument in the `docker compose tools, e.g.

```env
    # .env.live file, for building a particular released version of Mauro
    MDM_APPLICATION_COMMIT=5.3.0
    MDM_UI_COMMIT=7.3.0

    MDM_PORT=80

    MDM_TAG=nhsd-1.0.0
```

```bash
    # Build the images on the live environment
    docker compose --env-file .env.live build
```

## Build and Runtime Configuration

For the `mauro-data-mapper` service, Mauro can be configured by passing in Grails properties as environment variables, in dot-notation. For example, the Grails property in `application.yml`:

```yml
    database:
      host: localhost
```

Would be overridden by `docker-compose.yml` as:

```yml
    services:
      mauro-data-mapper:
        environment:
            database.host: another-host
```

To make it simpler, there are two files listed in the repo to control these configuration properties, found in `mauro-data-mapper/config`:

1. `build.yml` - This is built into the service when the Docker image is being built; this is a standard Grails `application.yml` file.
2. `runtime.yml` - This will be loaded into the container via `docker-compose.yml`, and is intended as the environment variable overrides.

## Properties to override

The following variables need to be overriden/set when starting up a new `mauro-data-mapper` image. Usually this is done in the `docker-compose.yml` or the `build.yml` file.

* `grails.cors.allowedOrigins` - Should be set to a single FQDN URL which is the host where MDM will be accessed from. If using a proxy to break SSL then the origin would be the hostname where the proxy sits, not the host of the server running the docker containers. The origin must include the protocol, i.e. `https` or `http`
* `maurodatamapper.authority.name` - A unique name used to distinguish a running MDM instance.
* `maurodatamapper.authority.url` - The full URL to the location of the catalogue. This is considered a unique identifier to distinguish any instance from another and therefore no two instances should use the same URL.
* `simplejavamail.smtp.host` - This is the FQDN of the mail server to use when sending emails.
* `simplejavamail.smtp.username` - To allow the catalogue to send emails this needs to be a valid username for the SMTP host.
* `simplejavamail.smtp.password` - To allow the catalogue to send emails this needs to be a valid password for the SMTP host.

## Free space

There is a lot of space being used by docker in `/ver/lib/docker` — this can be release with:

```bash
    docker system prune
```

