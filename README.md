# github.com/tiredofit/docker-db-backup

[![GitHub release](https://img.shields.io/github/v/tag/tiredofit/docker-db-backup?style=flat-square)](https://github.com/tiredofit/docker-db-backup/releases/latest)
[![Build Status](https://img.shields.io/github/workflow/status/tiredofit/docker-db-backup/build?style=flat-square)](https://github.com/tiredofit/docker-db-backup/actions?query=workflow%3Abuild)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/db-backup.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/db-backup/)
[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/db-backup.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/db-backup/)
[![Become a sponsor](https://img.shields.io/badge/sponsor-tiredofit-181717.svg?logo=github&style=flat-square)](https://github.com/sponsors/tiredofit)
[![Paypal Donate](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square)](https://www.paypal.me/tiredofit)

* * *
## About

This will build a container for backing up multiple types of DB Servers

Currently backs up CouchDB, InfluxDB, MySQL, MongoDB, Postgres, Redis servers.

* dump to local filesystem or backup to S3 Compatible services
* select database user and password
* backup all databases
* choose to have an MD5 or SHA1 sum after backup for verification
* delete old backups after specific amount of time
* choose compression type (none, gz, bz, xz, zstd)
* connect to any container running on the same system
* Script to perform restores
* Zabbix Monitoring capabilities
* select how often to run a dump
* select when to start the first dump, whether time of day or relative to container start time
* Execute script after backup for monitoring/alerting purposes

## Maintainer

- [Dave Conroy](https://github.com/tiredofit)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
  - [Persistent Storage](#persistent-storage)
- [Prerequisites and Assumptions](#prerequisites-and-assumptions)
- [Installation](#installation)
  - [Build from Source](#build-from-source)
  - [Prebuilt Images](#prebuilt-images)
    - [Multi Architecture](#multi-architecture)
- [Configuration](#configuration)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage-1)
  - [Environment Variables](#environment-variables)
    - [Base Images used](#base-images-used)
    - [Backing Up to S3 Compatible Services](#backing-up-to-s3-compatible-services)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
  - [Manual Backups](#manual-backups)
  - [Custom Scripts](#custom-scripts)
- [Support](#support)
  - [Usage](#usage)
  - [Bugfixes](#bugfixes)
  - [Feature Requests](#feature-requests)
  - [Updates](#updates)
- [License](#license)

> **NOTE**: If you are using this with a docker-compose file along with a seperate SQL container, take care not to set the variables to backup immediately, more so have it delay execution for a minute, otherwise you will get a failed first backup.
### Persistent Storage

## Prerequisites and Assumptions
*  You must have a working connection to one of the supported DB Servers and appropriate credentials

## Installation

### Build from Source
Clone this repository and build the image with `docker build <arguments> (imagename) .`

### Prebuilt Images
Builds of the image are available on [Docker Hub](https://hub.docker.com/r/tiredofit/db-backup) and is the recommended method of installation.

The following image tags are available along with their tagged release based on what's written in the [Changelog](CHANGELOG.md):

| Alpine Base | Tag       |
| ----------- | --------- |
| latest      | `:latest` |

```bash
docker pull tiredofit/db-backup:(imagetag)
```
#### Multi Architecture
Images are built primarily for `amd64` architecture, and may also include builds for `arm/v7`, `arm64` and others. These variants are all unsupported. Consider [sponsoring](https://github.com/sponsors/tiredofit) my work so that I can work with various hardware. To see if this image supports multiple architecures, type `docker manifest (image):(tag)`

## Configuration

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [docker-compose.yml](examples/docker-compose.yml) that can be modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this image.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.
* Make [networking ports](#networking) available for public access if necessary
### Persistent Storage

The following directories are used for configuration and can be mapped for persistent storage.
| Directory                | Description                                                                        |
| ------------------------ | ---------------------------------------------------------------------------------- |
| `/backup`                | Backups                                                                            |
| `/assets/custom-scripts` | *Optional* Put custom scripts in this directory to execute after backup operations |

### Environment Variables

#### Base Images used

This image relies on an [Alpine Linux](https://hub.docker.com/r/tiredofit/alpine) or [Debian Linux](https://hub.docker.com/r/tiredofit/debian) base image that relies on an [init system](https://github.com/just-containers/s6-overlay) for added capabilities. Outgoing SMTP capabilities are handlded via `msmtp`. Individual container performance monitoring is performed by [zabbix-agent](https://zabbix.org). Additional tools include: `bash`,`curl`,`less`,`logrotate`, `nano`,`vim`.

Be sure to view the following repositories to understand all the customizable options:

| Image                                                  | Description                            |
| ------------------------------------------------------ | -------------------------------------- |
| [OS Base](https://github.com/tiredofit/docker-alpine/) | Customized Image based on Alpine Linux |

#### Container Options

| Parameter         | Description                                                                                                                      | Default         |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `BACKUP_LOCATION` | Backup to `FILESYSTEM` or `S3` compatible services like S3, Minio, Wasabi                                                        | `FILESYSTEM`    |
| `MODE`            | `AUTO` mode to use internal scheduling routines or `MANUAL` to simply use this as manual backups only executed by your own means | `AUTO`          |
| `TEMP_LOCATION`   | Perform Backups and Compression in this temporary directory                                                                      | `/tmp/backups/` |
| `DB_AUTH`         | (Mongo Only - Optional) Authentication Database                                                                                  |                 |
| `DEBUG_MODE`      | If set to `true`, print copious shell script messages to the container log. Otherwise only basic messages are printed.           | `FALSE`         |
| `POST_SCRIPT`     | Fill this variable in with a command to execute post the script backing up                                                       |                 |
| `SPLIT_DB`        | If using root as username and multiple DBs on system, set to TRUE to create Seperate DB Backups instead of all in one.           | `FALSE`         |

### Database Specific Options
| Parameter | Description                                                                                   | Default |
| --------- | --------------------------------------------------------------------------------------------- | ------- |
| `DB_TYPE` | Type of DB Server to backup `couch` `influx` `mysql` `pgsql` `mongo` `redis` `sqlite3`        |         |
| `DB_HOST` | Server Hostname e.g. `mariadb`. For `sqlite3`, full path to DB file e.g. `/backup/db.sqlite3` |         |
| `DB_NAME` | Schema Name e.g. `database`                                                                   |         |
| `DB_USER` | username for the database - use `root` to backup all MySQL of them.                           |         |
| `DB_PASS` | (optional if DB doesn't require it) password for the database                                 |         |
| `DB_PORT` | (optional) Set port to connect to DB_HOST. Defaults are provided                              | varies  |
### Scheduling Options
| Parameter         | Description                                                                                                                                                                                        | Default |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `DB_DUMP_FREQ`    | How often to do a dump, in minutes. Defaults to 1440 minutes, or once per day.                                                                                                                     | `1440`  |
| `DB_DUMP_BEGIN`   | What time to do the first dump. Defaults to immediate. Must be in one of two formats                                                                                                               |         |
|                   | Absolute HHMM, e.g. `2330` or `0415`                                                                                                                                                               |         |
|                   | Relative +MM, i.e. how many minutes after starting the container, e.g. `+0` (immediate), `+10` (in 10 minutes), or `+90` in an hour and a half                                                     |         |
| `DB_CLEANUP_TIME` | Value in minutes to delete old backups (only fired when dump freqency fires). 1440 would delete anything above 1 day old. You don't need to set this variable if you want to hold onto everything. | `FALSE` |

- You may need to wrap your `DB_DUMP_BEGIN` value in quotes for it to properly parse. There have been reports of backups that start with a `0` get converted into a different format which will not allow the timer to start at the correct time.
### Backup Options
| Parameter                     | Description                                                                                                                  | Default |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------- |
| `ENABLE_COMPRESSION`          | Use either Gzip `GZ`, Bzip2 `BZ`, XZip `XZ`, ZSTD `ZSTD` or none `NONE`                                                      | `GZ`    |
| `ENABLE_PARALLEL_COMPRESSION` | Use multiple cores when compressing backups `TRUE` or `FALSE`                                                                | `TRUE`  |
| `COMPRESSION_LEVEL`           | Numberical value of what level of compression to use, most allow `1` to `9` except for `ZSTD` which allows for `1` to `19` - | `3`     |
| `ENABLE_CHECKSUM`             | Generate either a MD5 or SHA1 in Directory, `TRUE` or `FALSE`                                                                | `TRUE`  |
| `CHECKSUM`                    | Either `MD5` or `SHA1`                                                                                                       | `MD5`   |
| `EXTRA_OPTS`                  | If you need to pass extra arguments to the backup command, add them here e.g. `--extra-command`                              |         |
| `MYSQL_MAX_ALLOWED_PACKET`    | Max allowed packet if backing up MySQL / MariaDB                                                                             | `512M`  |
| `MYSQL_SINGLE_TRANSACTION`    | Backup in a single transaction with MySQL / MariaDB                                                                          | `TRUE`  |
| `MYSQL_STORED_PROCEDURES`     | Backup stored procedures with MySQL / MariaDB                                                                                | `TRUE`  |
- When using compression with MongoDB, only `GZ` compression is possible.

#### Backing Up to S3 Compatible Services

If `BACKUP_LOCATION` = `S3` then the following options are used.

| Parameter             | Description                                                                               | Default |
| --------------------- | ----------------------------------------------------------------------------------------- | ------- |
| `S3_BUCKET`           | S3 Bucket name e.g. `mybucket`                                                            |         |
| `S3_KEY_ID`           | S3 Key ID                                                                                 |         |
| `S3_KEY_SECRET`       | S3 Key Secret                                                                             |         |
| `S3_PATH`             | S3 Pathname to save to e.g. '`backup`'                                                    |         |
| `S3_REGION`           | Define region in which bucket is defined. Example: `ap-northeast-2`                       |         |
| `S3_HOST`             | Hostname (and port) of S3-compatible service, e.g. `minio:8080`. Defaults to AWS.         |         |
| `S3_PROTOCOL`         | Protocol to connect to `S3_HOST`. Either `http` or `https`. Defaults to `https`.          | `https` |
| `S3_EXTRA_OPTS`       | Add any extra options to the end of the `aws-cli` process execution                       |         |
| `S3_CERT_CA_FILE`     | Map a volume and point to your custom CA Bundle for verification e.g. `/certs/bundle.pem` |         |
| _*OR*_                |                                                                                           |         |
| `S3_CERT_SKIP_VERIFY` | Skip verifying self signed certificates when connecting                                   | `TRUE`  |

## Maintenance


### Shell Access

For debugging and maintenance purposes you may want access the containers shell.

``bash
docker exec -it (whatever your container name is) bash
``
### Manual Backups
Manual Backups can be performed by entering the container and typing `backup-now`

### Restoring Databases
Entering in the container and executing `restore` will execute a menu based script to restore your backups.

You will be presented with a series of menus allowing you to choose:
   - What file to restore
   - What type of DB Backup
   - What Host to restore to
   - What Database Name to restore to
   - What Database User to use
   - What Database Password to use
   - What Database Port to use

The image will try to do autodetection based on the filename for the type, hostname, and database name.
The image will also allow you to use environment variables or Docker secrets used to backup the images

The script can also be executed skipping the interactive mode by using the following syntax/

    `restore <filename> <db_type> <db_hostname> <db_name> <db_user> <db_pass> <db_port>`

If you only enter some of the arguments you will be prompted to fill them in.

### Custom Scripts

If you want to execute a custom script at the end of backup, you can drop bash scripts with the extension of `.sh` in this directory. See the following example to utilize:

````bash
$ cat post-script.sh
##!/bin/bash

# #### Example Post Script
# #### $1=EXIT_CODE (After running backup routine)
# #### $2=DB_TYPE (Type of Backup)
# #### $3=DB_HOST (Backup Host)
# #### #4=DB_NAME (Name of Database backed up
# #### $5=BACKUP START TIME (Seconds since Epoch)
# #### $6=BACKUP FINISH TIME (Seconds since Epoch)
# #### $7=BACKUP TOTAL TIME (Seconds between Start and Finish)
# #### $8=BACKUP FILENAME (Filename)
# #### $9=BACKUP FILESIZE
# #### $10=HASH (If CHECKSUM enabled)

echo "${1} ${2} Backup Completed on ${3} for ${4} on ${5} ending ${6} for a duration of ${7} seconds. Filename: ${8} Size: ${9} bytes MD5: ${10}"
````

      ## script EXIT_CODE DB_TYPE DB_HOST DB_NAME STARTEPOCH FINISHEPOCH DURATIONEPOCH BACKUP_FILENAME FILESIZE CHECKSUMVALUE
      ${f} "${exit_code}" "${dbtype}" "${dbhost}" "${dbname}" "${backup_start_timme}" "${backup_finish_time}" "${backup_total_time}" "${target}" "${FILESIZE}" "${checksum_value}"


Outputs the following on the console:

`0 mysql Backup Completed on example-db for example on 1647370800 ending 1647370920 for a duration of 120 seconds. Filename: mysql_example_example-db_202200315-000000.sql.bz2 Size: 7795 bytes Hash: 952fbaafa30437494fdf3989a662cd40`

If you wish to change the size value from bytes to megabytes set environment variable `SIZE_VALUE=megabytes`

## Support

These images were built to serve a specific need in a production environment and gradually have had more functionality added based on requests from the community.
### Usage
- The [Discussions board](../../discussions) is a great place for working with the community on tips and tricks of using this image.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) personalized support.
### Bugfixes
- Please, submit a [Bug Report](issues/new) if something isn't working as expected. I'll do my best to issue a fix in short order.

### Feature Requests
- Feel free to submit a feature request, however there is no guarantee that it will be added, or at what timeline.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) regarding development of features.

### Updates
- Best effort to track upstream changes, More priority if I am actively using the image in a production environment.
- Consider [sponsoring me](https://github.com/sponsors/tiredofit) for up to date releases.

## License
MIT. See [LICENSE](LICENSE) for more details.
