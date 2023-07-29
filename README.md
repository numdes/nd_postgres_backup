# nd_postgres_backup
Docker image for universal postgres backups

# Roadmap
- [X] Add support for S3
- [X] Add CI/CD to publish image to DockerHub
- [ ] Add retention policy settings by env vars
- [ ] Notify about backup status by HTTP-request
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
    -e NOTIFICATION_URL=http://webhook \
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
    -e NOTIFICATION_URL=http://webhook \
    -e TELEGRAM_CHAT_ID=point_to_notify_group \
    -e POSTGRES_PORT=if_not_5432 \
    numdes/nd_postgres_backup:v*.*.*
```

## Variables

| Name              |  Description                                        |
|-------------------|-----------------------------------------------------|
|TELEGRAM_METHOD    | By default used `private`                           |
|TELEGRAM_CHAT_ID   | Notifying group                                     |
|NOTIFICATION_URL   | Notifier URL                                        |
|TELEGRAM_BOT_TOKEN | Only used when TELEGRAM_METHOD is set to `external` |
|DOCKERHUB_LOGIN    | `Actions` Repository secret                         |
|DOCKERHUB_PASSWORD | `Actions` Repository secret                         |

### TELEGRAM_METHOD environment variable

Variable is used to select which notification method is going to be used. In case of usage
local Telegram bot variable must be set to `private` (default). If public Telegram API
going to be selected then `TELEGRAM_METHOD` must be set to `external`.
- If TELEGRAM_METHOD variable is set to `private` `private-webhook.sh` will be executed
and notification processing will be passed to internal Telegram bot. Along with
`private` flag following variables come: `TELEGRAM_CHAT_ID`, `NOTIFICATION_URL`
- If TELEGRAM_METHOD variable is set to `external` `external-webhook.sh` will be executed
and notification processing will be passed to standard Telegram API URL. Along with
`external` flag following variables come: `TELEGRAM_CHAT_ID`, `TELEGRAM_BOT_TOKEN`

In `docker ...` command need to replace:
```
-e NOTIFICATION_URL=http://webhook \
-e TELEGRAM_CHAT_ID=point_to_notify_group \
```
to
```
    -e TELEGRAM_METHOD=external \
    -e TELEGRAM_BOT_TOKEN='XXXXXXX:XXXXxxxxXXXXxxx' \
    -e TELEGRAM_CHAT_ID=000000000 \
``` 
- If TELEGRAM_METHOD variable is set to anything else only `echo` will be used
