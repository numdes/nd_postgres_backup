# nd_postgres_backup

Docker image for universal postgres backups

# Roadmap

- [X] Add support for S3
- [X] Add CI/CD to publish image to DockerHub
- [ ] Add retention policy settings by env vars
- [X] Notify about backup status by HTTP-request
- [ ] Add docker-compose example

# Usage

## Backup manually:
Use next command if you need to backup DB manually:
```shell
docker run --rm \
    --env POSTGRES_HOST="FQDN-OR-IP" \
    --env POSTGRES_DB="DB-NAME" \
    --env POSTGRES_USER="DB-USER" \
    --env POSTGRES_PASSWORD="PASS" \
    --env S3_ENDPOINT=https://YOUR-S3 \
    --env S3_ACCESS_KEY="access-key" \
    --env S3_SECRET_KEY="secret-key" \
    --env S3_BUCKET="BUCKET-NAME" \
    --entrypoint '' \
    numdes/nd_postgres_backup:v0.2.1 \
    /bin/bash -c "./backup.sh"
```
It will backup given Postgres DB and upload it to S3 bucket.

## Backup using `go-cron`

```shell
docker run --detach \
    --env POSTGRES_HOST="FQDN-OR-IP" \
    --env POSTGRES_DB="DB-NAME" \
    --env POSTGRES_USER="DB-USER" \
    --env POSTGRES_PASSWORD="PASS" \
    --env S3_ENDPOINT=http://YOUR-S3 \
    --env S3_ACCESS_KEY="KEY-ID" \
    --env S3_SECRET_KEY="KEY-SECRET" \
    --env S3_BUCKET="BUCKET-NAME" \
    --env PRIVATE_NOTIFICATION_URL=http://webhook \
    --env TELEGRAM_CHAT_ID=point_to_notify_group \
    --env POSTGRES_PORT=if_not_5432 \
    --env SCHEDULE=Chosen_schedule \
    numdes/nd_postgres_backup:v0.2.1
```

:wave: By default `SCHEDULE` variable is set to `@daily` in case if you need other scheduling options, please refer
to `go-cron` *[Documentation](https://pkg.go.dev/github.com/robfig/cron?utm_source=godoc#hdr-Predefined_schedules)*.

## Variables

### `Gitlab Actions`
*[variables](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)*:

| Name               | Description                 |
|--------------------|-----------------------------|
| DOCKERHUB_LOGIN    | `Actions` Repository secret |
| DOCKERHUB_PASSWORD | `Actions` Repository secret |

### Notification environmental variables

| Name                     | Description                             |
|--------------------------|-----------------------------------------|
| TELEGRAM_CHAT_ID         | Notifying group                         |
| PRIVATE_NOTIFICATION_URL | Private notifier URL                    |
| TELEGRAM_BOT_TOKEN       | Only used to call Telegram's public API |

### Environmental variables

| Name                | Default value | Is mandatory | Description                                                               |
|---------------------|:--------------|:------------:|---------------------------------------------------------------------------|
| POSTGRES_DB         | -             |     YES      | Database name                                                             |
| POSTGRES_HOST       | -             |     YES      | PostgreSQL IP address or hostname                                         |
| POSTGRES_PORT       | 5432          |      -       | Connection TCP port                                                       |
| POSTGRES_USER       | -             |     YES      | Database user                                                             |
| POSTGRES_PASSWORD   | -             |     YES      | Database user password                                                    |
| POSTGRES_EXTRA_OPTS | --blobs       |      -       | Extra options `pg_dump` run                                               |
| SCHEDULE            | @daily        |      -       | `go-cron` schedule. See [this](#backup-using-go-cron)                     |
| HEALTHCHECK_PORT    | 8080          |      -       | Port listening for cron-schedule health check.                            |
| S3_ACCESS_KEY       | -             |     YES      | Key or username with RW access to bucket                                  |
| S3_SECRET_KEY       | -             |     YES      | Secret or password for `S3_ACCESS_KEY`                                    |
| S3_BUCKET           | -             |     YES      | Name of S3 bucket                                                         |
| S3_ENDPOINT         | -             |     YES      | URL of S3 storage                                                         |
| S3_OBJECT_PATH      | -             |      NO      | Full path to archive including bucket name and desired file name. If not present will be generated automatically |

### Notification selection

It is possible to use either private Telegram bot if you have it or Telegram public API.

In scenario with private bot `PRIVATE_NOTIFICATION_URL` must be set alongside with `TELEGRAM_CHAT_ID`.

In scenario with Telegram's public API `TELEGRAM_BOT_TOKEN` must be set as it is
received (`Use this token to access the HTTP API:`) from `@BotFather` Telegram Bot. Variable `TELEGRAM_CHAT_ID` must be
a proper Telegram ID of bot

In `docker ...` command need to replace:

```
    --env PRIVATE_NOTIFICATION_URL=http://webhook \
    --env TELEGRAM_CHAT_ID=point_to_notify_group \
```

to

```
    --env TELEGRAM_BOT_TOKEN='XXXXXXX:XXXXxxxxXXXXxxx' \
    --env TELEGRAM_CHAT_ID=000000000 \
```

- If `TELEGRAM_CHAT_ID` has a proper format (Only digits not less than 5 not more than 32) and `TELEGRAM_BOT_TOKEN` is
  set, script will try to send notification through Telegram's public API.
