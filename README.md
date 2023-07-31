# nd_postgres_backup
Docker image for universal postgres backups

# Roadmap
- [X] Add support for S3
- [X] Add CI/CD to publish image to DockerHub
- [ ] Add retention policy settings by env vars
- [X] Notify about backup status by HTTP-request
- [ ] Add docker-compose example

## Docker build
```shell
docker build . -t numdes/nd_postgres_backup:v*.*.*
```

# Usage
## Backup manually:
```shell
docker run --rm -it \
    -e POSTGRES_HOST="FQDN-OR-IP" \
    -e POSTGRES_DB="DB-NAME" \
    -e POSTGRES_USER="DB-USER" \
    -e POSTGRES_PASSWORD="PASS" \
    -e S3_ENDPOINT=http://YOUR-S3 \
    -e S3_ACCESS_KEY_ID="KEY-ID" \
    -e S3_SECRET_ACCESS_KEY="KEY-SECRET" \
    -e S3_BUCKET="BUCKET-NAME" \
    -e PRIVATE_NOTIFICATION_URL=http://webhook \
    -e TELEGRAM_CHAT_ID=point_to_notify_group \
    -e POSTGRES_PORT=if_not_5432 \
    --entrypoint /bin/bash \
    numdes/nd_postgres_backup:v*.*.*
```
To run backup, in active container shell call `backup.sh` script
```shell
./backup.sh
```

## Backup using `go-cron`
```shell
docker run -d \
    -e POSTGRES_HOST="FQDN-OR-IP" \
    -e POSTGRES_DB="DB-NAME" \
    -e POSTGRES_USER="DB-USER" \
    -e POSTGRES_PASSWORD="PASS" \
    -e S3_ENDPOINT=http://YOUR-S3 \
    -e S3_ACCESS_KEY_ID="KEY-ID" \
    -e S3_SECRET_ACCESS_KEY="KEY-SECRET" \
    -e S3_BUCKET="BUCKET-NAME" \
    -e PRIVATE_NOTIFICATION_URL=http://webhook \
    -e TELEGRAM_CHAT_ID=point_to_notify_group \
    -e POSTGRES_PORT=if_not_5432 \
    -e SCHEDULE=[Chosen_schedule][^1]
    numdes/nd_postgres_backup:v*.*.*
```
[^1]: By default `SCHEDULE` variable is set to `@daily` in case if you need other scheduling options, please refer to `go-cron` *[Documentation](https://pkg.go.dev/github.com/robfig/cron?utm_source=godoc#hdr-Predefined_schedules)*.

## Variables
### `Gitlab Actions` *[variables](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)*:
| Name              |  Description                                        |
|-------------------|-----------------------------------------------------|
|DOCKERHUB_LOGIN    | `Actions` Repository secret                         |
|DOCKERHUB_PASSWORD | `Actions` Repository secret                         |

### Notification environmental variables
| Name                      |  Description                                        |
|---------------------------|-----------------------------------------------------|
|TELEGRAM_CHAT_ID           | Notifying group                                     |
|PRIVATE_NOTIFICATION_URL   | Private notifier URL                                |
|TELEGRAM_BOT_TOKEN         | Only used to call Telegram's public API             |

### Environmental variables
| Name                   | Default    | Description                                    |
|                        | value      |                                                |
|------------------------|  :------   |------------------------------------------------|
| POSTGRES_DB            |  -         | Database name                                  |
| POSTGRES_HOST          |  -         | PostgreSQL IP address or hostname              |
| POSTGRES_PORT          | 5432       | Connection TCP port                            |
| POSTGRES_USER          |  -         | Database user                                  |
| POSTGRES_PASSWORD      |  -         | Database user password                         |
| POSTGRES_EXTRA_OPTS    | --blobs    | Extra options `pg_dump` run                    |
| SCHEDULE               | @daily     | `go-cron` schedule. See [this](#backup-using-go-cron) |
| HEALTHCHECK_PORT       | 8080       | Port listening for cron-schedule health check. |
| S3_ACCESS_KEY_ID       |  -         | Key or username with RW access to bucket       |
| S3_SECRET_ACCESS_KEY   |  -         | Secret or password for `S3_ACCESS_KEY_ID`      |
| S3_BUCKET              |  -         | Name of bucket created for backups             |
| S3_ENDPOINT            |  -         | URL of S3 storage                              |

### Notification selection

It is possible to use either private Telegram bot if you have it or Telegram public API.

In scenario with private bot `PRIVATE_NOTIFICATION_URL` must be set alongside with `TELEGRAM_CHAT_ID`.

In scenario with Telegram's public API `TELEGRAM_BOT_TOKEN` must be set as it is received (`Use this token to access the HTTP API:`) from `@BotFather` Telegram Bot. Variable `TELEGRAM_CHAT_ID` must be a proper Telegram ID of bot

In `docker ...` command need to replace:
```
    -e PRIVATE_NOTIFICATION_URL=http://webhook \
    -e TELEGRAM_CHAT_ID=point_to_notify_group \
```
to
```
    -e TELEGRAM_BOT_TOKEN='XXXXXXX:XXXXxxxxXXXXxxx' \
    -e TELEGRAM_CHAT_ID=000000000 \
```
- If `TELEGRAM_CHAT_ID` has a proper format (Only digits not less than 5 not more than 32) and `TELEGRAM_BOT_TOKEN` is set, script will try to send notification through Telegram's public API.
