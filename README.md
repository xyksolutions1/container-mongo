# nfrastack/container-mongo

## About

This repository will build a container for [MongoDB](https://www.mongo.net). A nosql database engine.

## Maintainer

- [Nfrastack](https://www.nfrastack.com)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Installation](#installation)
  - [Prebuilt Images](#prebuilt-images)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
- [Environment Variables](#environment-variables)
  - [Base Images used](#base-images-used)
  - [Core Configuration](#core-configuration)
- [Users and Groups](#users-and-groups)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [Support & Maintenance](#support--maintenance)
- [License](#license)

## Installation

### Prebuilt Images

Feature limited builds of the image are available on the [Github Container Registry](https://github.com/nfrastack/container-mongo/pkgs/container/container-mongo) and [Docker Hub](https://hub.docker.com/r/nfrastack/mongo).

To unlock advanced features, one must provide a code to be able to change specific environment variables from defaults. Support the development to gain access to a code.

To get access to the image use your container orchestrator to pull from the following locations:

```
ghcr.io/nfrastack/container-mongo:(image_tag)
docker.io/nfrastack/mongo:(image_tag)
```

Image tag syntax is:

`<image>:<branch>-<optional tag>-<optional_distribution>_<optional_distribution_variant>`

Example:

`ghcr.io/nfrastack/container-mongo:8` or

`ghcr.io/nfrastack/container-mongo:latest` or

`ghcr.io/nfrastack/container-mongo:8-1.0` or


* `latest` will be the most recent mongo version and commit
* `branch` will be the repositories branch, typically matching with the version of mongo eg `7`
* An optional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - These are the safest
* If there are multiple distribution variations it may include a version - see the registry for availability


Have a look at the container registries and see what tags are available.

#### Multi-Architecture Support

Images are built for `amd64` by default, with optional support for `arm64` and other architectures.

### Quick Start

- The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for your use.

- Map [persistent storage](#persistent-storage) for access to configuration and data files for backup.
- Set various [environment variables](#environment-variables) to understand the capabilities of this image.

### Persistent Storage

The following directories are used for configuration and can be mapped for persistent storage.

| Directory | Description    |
| --------- | -------------- |
| `/data/`  | Database Files |
| `/logs/`  | Logfiles       |

### Environment Variables

#### Base Images used

This image relies on a customized base image in order to work.
Be sure to view the following repositories to understand all the customizable options:

| Image                                                   | Description |
| ------------------------------------------------------- | ----------- |
| [OS Base](https://github.com/nfrastack/container-base/) | Base Image  |

Below is the complete list of available options that can be used to customize your installation.

- Variables showing an 'x' under the `Advanced` column can only be set if the containers advanced functionality is enabled.

#### Core Configuration

| Parameter               | Description                                                      | Default  | _FILE | Advanced |
| ----------------------- | ---------------------------------------------------------------- | -------- | ----- | -------- |
| `SETUP_MODE`            | Auto configure based on environment variables `AUTO` or `MANUAL` | `AUTO`   |       |          |
| `LISTEN_PORT`           | MongoDB Listening Port                                           | `27017`  |       |          |
| `DATA_PATH`             | Data Location                                                    | `/data/` |       |          |
| `LOG_PATH`              | Log Path                                                         | `/logs`  |       |          |
| `LOG_TYPE`              | Write to `FILE`                                                  | `FILE`   |       |          |
| `CONFIG_FILE`           | Map and use a config file. Works with both `SETUP_MODE` values.  |          |       |          |
|                         | All environment variables override config file                   |          |       |          |
| `ENABLE_AUTHENTICATION` | Enable Authentication Features                                   | `TRUE`   |       |          |
| `ADMIN_NAME`            | Administrator Account name                                       | `admin`  | x     |          |
| `ADMIN_PASS`            | Password of Admin user                                           | `admin`  | x     |          |

#### Database Options

Automatically create user databases on startup. This can be done on each container start, and then removed on subsequent starts if desired.
This will only work if your database name is not set to "`admin`"

| Parameter | Description                                | Default | `_FILE` | Advanced |
| --------- | ------------------------------------------ | ------- | ------- | -------- |
| `DB_NAME` | Database Name e.g. `database`              |         | x       |          |
| `DB_USER` | Database User e.g. `user`                  |         | x       |          |
| `DB_PASS` | Database Pass e.g. `password`              |         | x       |          |
| `DB_ROLE` | (optional) Database role to assign to user | dbOwner | x       |          |

**OR**

Create multiple databases and different usernames and passwords and roles to access. You can share usernames and passwords for multiple databases by using the same user and password in each entry.

| Parameter   | Description                                        | Default | `_FILE` | Advanced |
| ----------- | -------------------------------------------------- | ------- | ------- | -------- |
| `DB01_NAME` | First Database Name e.g. `database1`               |         | x       |          |
| `DB01_USER` | First Database User e.g. `user1`                   |         | x       |          |
| `DB01_PASS` | First Database Pass e.g. `password1`               |         | x       |          |
| `DB01_ROLE` | (optional) Database Role - See below               |         |         | x        |
| `DB02_NAME` | Second Database Name e.g. `database1`              |         | x       |          |
| `DB02_USER` | Second Database User e.g. `user2`                  |         | x       |          |
| `DB02_PASS` | Second Database Pass e.g. `password2`              |         | x       |          |
| `DB02_ROLE` | (optional) Database Role - See below               |         |         | x        |
| `DBXX_...`  | As above, should be able to go all the way to `99` |         |         | x        |

>Role Syntax:
>
>`<user>:rolename,rolename` add multiple users and roles to database seperated by a semicolon eg `u1:r1,r2;u2:r1,r2,r3`

Advanced mode allows you to maange more than 3 databases.

#### Replication Options

| Parameter            | Description                                                      | Default                  | `_FILE` | Advanced |
| -------------------- | ---------------------------------------------------------------- | ------------------------ | ------- | -------- |
| `ENABLE_REPLICATION` | Enable Replication                                               | `FALSE`                  |         |          |
| `REPLICATION_SET`    | Name of Replication Set                                          | `rs0`                    |         |          |
| `REPLICATION_INIT`   | Initialize the Replica set                                       |                          |         |          |
| `REPLICATION_HOSTS`  | Comma seperated list of hosts to init the replica set            | `0:localhost:$DB_PORT:1` |         |          |
|                      | Syntax is `id:hostname:port:priority`                            |                          |         |          |
| `SKIP_INIT`          | Skip creating databases and admin users if used in a replica set | `FALSE`                  |         |          |

#### Other Options

| Parameter | Description | Default | `_FILE` | Advanced |
| --------- | ----------- | ------- | ------- | -------- |

## Users and Groups

| Type  | Name    | ID    |
| ----- | ------- | ----- |
| User  | `mongo` | 27017 |
| Group | `mongo` | 27017 |

### Networking

| Port    | Protocol | Description  |
| ------- | -------- | ------------ |
| `27017` | tcp      | Mongo Daemon |
| `28017` | tcp      | Mongo Daemon |

* * *

## Maintenance

### Shell Access

For debugging and maintenance, `bash` and `sh` are available in the container.

- `mongo` and `mongosh` client tools exist inside the container


## Support & Maintenance

- For community help, tips, and community discussions, visit the [Discussions board](/discussions).
- For personalized support or a support agreement, see [Nfrastack Support](https://nfrastack.com/).
- To report bugs, submit a [Bug Report](issues/new). Usage questions will be closed as not-a-bug.
- Feature requests are welcome, but not guaranteed. For prioritized development, consider a support agreement.
- Updates are best-effort, with priority given to active production use and support agreements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
