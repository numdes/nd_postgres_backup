# PostgreSQL Backup to S3 and retention container

# Roadmap

- [X] Add support for S3
- [X] Add CI/CD to publish image to DockerHub
- [X] Add retention policy settings by env vars
- [X] Notify about backup status by HTTP-request
- [X] Add docker-compose example

## Description

Image created to automate backing up procedure of PostgreSQL databases, store backups to S3 Object storage and implement retention of stored archives with `Grandfather-father-son` backup rotation [scheme](https://en.wikipedia.org/wiki/Backup_rotation_scheme).     
It is also possible to use this container to create a single backup of specific DB.  

## Usage

Key idea of usage was to add this container as a service to `docker-compose.yml` manifest alongside with PostgreSQL database container. See `compose-example/docker-compose.yml`.    
To run container as a standalone backupper, to backup cloud SaaS or bare-metal deployed PostgreSQL, for example, use following command:

```shell
docker run -d --rm \
    --env POSTGRES_HOST="DB_IP_OR_HOSTNAME" \
    --env POSTGRES_DB="DB_NAME" \
    --env POSTGRES_USER="DB_USERNAME" \
    --env POSTGRES_PORT="NON_DEFAULT_PORT" \
    --env POSTGRES_PASSWORD="DB_USERNAME_PASSWORD" \
    --env NOTIFICATION_SERVER_URL="ONLY_SET_IF_PRIVATE_TELEGRAM_BOT_USED" \
    --env TELEGRAM_CHAT_ID="PRIVATE_OR_TELEGRAM_BOT_ID" \
    --env S3_ENDPOINT="S3_API_URL" \
    --env S3_ACCESS_KEY="S3_ACCESS_KEY" \
    --env S3_SECRET_KEY="S3_SECERT_KEY" \
    --env S3_BUCKET="S3_BUCKET_NAME(+POSSIBLE_PATH_DEEPER)" \
    --env S3_ALIAS="S3_CONFIG_SET_ALIAS" \
    numdes/nd_postgres_backup:latest
```

### Manual one-time backup without schedule

Set full S3 path (e.g `bucket_name/project_name/stage_branch/database_name.tar.gz`) as the value of variable `S3_OBJECT_PATH`  to execute single backup 

```shell
docker run -d --rm \
    --env POSTGRES_HOST="DB_IP_OR_HOSTNAME" \
    --env POSTGRES_DB="DB_NAME" \
    --env POSTGRES_USER="DB_USERNAME" \
    --env POSTGRES_PORT="NON_DEFAULT_PORT" \
    --env POSTGRES_PASSWORD="DB_USERNAME_PASSWORD" \
    --env NOTIFICATION_SERVER_URL="ONLY_SET_IF_PRIVATE_TELEGRAM_BOT_USED" \
    --env TELEGRAM_CHAT_ID="PRIVATE_OR_TELEGRAM_BOT_ID" \
    --env S3_ENDPOINT="S3_API_URL" \
    --env S3_ACCESS_KEY="S3_ACCESS_KEY" \
    --env S3_SECRET_KEY="S3_SECERT_KEY" \
    --env S3_OBJECT_PATH="FULL_S3_PATH (e.g `bucket_name/project_name/stage_branch/database_name.tar.gz`)" \
    --env S3_ALIAS="S3_CONFIG_SET_ALIAS" \
    numdes/nd_postgres_backup:latest
```

## Backup strategy

By default set to make backup every hour, plus one separate backup a day, plus one separate backup a week

Schedule can be tuned or changed by editing of `crontab` file

## Disabling hourly backups

In case if each hour backup procedure is excessive it is possible to switch it off by setting
variable HOURLY_BACKUP_LIMIT to 0 `$HOURLY_BACKUP_LIMIT=0` 

## Retention strategy

Maximum depth of storage for each type of backup can be tuned by changing values of these variables:

- `WEEKLY_BACKUP_LIMIT`
- `DAILY_BACKUP_LIMIT`
- `HOURLY_BACKUP_LIMIT`
- `MONTHLY_BACKUP_LIMIT`

Schedule of retention script (`retention.sh`) execution can be edited in `crontab` file 

## Variables

### `Gitlab Actions`
*[variables](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)*:

| Name               | Description                 |
|--------------------|-----------------------------|
| DOCKERHUB_USERNAME | `Actions` Repository secret |
| DOCKERHUB_TOKEN    | `Actions` Repository secret |

### Notification environmental variables

| Name                      | Description                                                           |
|---------------------------|-----------------------------------------------------------------------|
| NOTIFICATION_SERVER_URL   | URL of private telegram bot                                           |
| TELEGRAM_CHAT_ID          | Custom bot ID or Telegram Bot ID when bot created using `@botfather`  |
| TELEGRAM_BOT_TOKEN        | Created by `@botfather` bot security token                            |

### Environmental variables

| Variable Name             | Default Value | Is Mandatory? | Description                                                          |
|---------------------------|:-------------:|:-------------:|----------------------------------------------------------------------|
| HOURLY_BACKUP_PATH        | `hourly`      |     NO        | Path suffix to hourly-made backups storage                           |
| DAILY_BACKUP_PATH         | `daily`       |     NO        | Path suffix to daily-made backups storage                            |
| WEEKLY_BACKUP_PATH        | `weekly`      |     NO        | Path suffix to weekly-made backups storage                           |
| MONTHLY_BACKUP_PATH        | `monthly`      |     NO        | Path suffix to monthly-made backups storage                           |
| HOURLY_BACKUP_LIMIT       | `25`          |     NO        | Max number of hourly backups                                         |
| DAILY_BACKUP_LIMIT        | `10`          |     NO        | Max number of daily backups                                          |
| WEEKLY_BACKUP_LIMIT       | `16`           |     NO        | Max number of weekly backups                                         |
| MONTHLY_BACKUP_LIMIT       | `24`           |     NO        | Max number of monthly backups                                         |
| S3_ACCESS_KEY             | -             |     YES       | ${S3_BUCKET} READ-WRITE S3 ACCESS KEY                                |
| S3_SECRET_KEY             | -             |     YES       | ${S3_BUCKET} READ-WRITE S3 ACCESS SECRET                             |
| S3_ENDPOINT               | -             |     YES       | S3 API URL                                                           |
| S3_BUCKET                 | -             |     YES       | Path to hourly, daily, weekly directories. Including bucket name     |
| S3_ALIAS                  | `backup`      |     NO        | Name of config set in `mcli` command `mcli alias set`                |
| S3_OBJECT_PATH            | -             |     NO        | Optional variable to use single backup [functionality](#manual-backup-without-schedule) |
| POSTGRES_DB               | -             |     YES       | PostgreSQL database name                                             |
| POSTGRES_HOST             | -             |     YES       | PostgreSQL IP or host name                                           |
| POSTGRES_PORT             | `5432`        |     NO        | TCP connection port                                                  |
| POSTGRES_USER             | -             |     YES       | DB usermane                                                          |
| POSTGRES_PASSWORD         | -             |     YES       | DB username password                                                 |
| POSTGRES_EXTRA_OPTS       | `--blobs`     |     NO        | `pg_dump` extra options                                              |

