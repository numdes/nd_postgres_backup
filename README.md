# nd_postgres_backup
Docker image for universal postgres backups

# Roadmap
- [X] Add support for S3
- [X] Add CI/CD to publish image to DockerHub
- [ ] Add retention policy settings by env vars
- [ ] Notify about backup status by HTTP-request
- [ ] Add docker-compose example

## Docker build
```
docker build . -t pg-backups:0.0.1
```

# Usage
## Backup manually:
```
docker run --rm -it \
    -e POSTGRES_HOST="FQDN-OR-IP" \
    -e POSTGRES_DB="DB-NAME" \
    -e POSTGRES_USER="DB-USER" \
    -e POSTGRES_PASSWORD="PASS" \
    -e S3_ENDPOINT=http://YOUR-S3 \
    -e S3_ACCESS_KEY_ID="KEY-ID" \
    -e S3_SECRET_ACCESS_KEY="KEY-SECRET" \
    -e S3_BUCKET="BUCKET-NAME" \
    -e WEBHOOK_URL=http://webhook \
    -e TG_GROUP=point_to_notify_group \
    -e POSTGRES_PORT=if_not_5432 \
    --entrypoint /bin/bash \
    IMAGE-NAME:tag
```
```
# ./backup.sh
```

## Backup using `go-cron`
```
docker run -d \
    -e POSTGRES_HOST="FQDN-OR-IP" \
    -e POSTGRES_DB="DB-NAME" \
    -e POSTGRES_USER="DB-USER" \
    -e POSTGRES_PASSWORD="PASS" \
    -e S3_ENDPOINT=http://YOUR-S3 \
    -e S3_ACCESS_KEY_ID="KEY-ID" \
    -e S3_SECRET_ACCESS_KEY="KEY-SECRET" \
    -e S3_BUCKET="BUCKET-NAME" \
    -e WEBHOOK_URL=http://webhook \
    -e TG_GROUP=point_to_notify_group \
    -e POSTGRES_PORT=if_not_5432 \
    IMAGE-NAME:tag
```

## Variables

| Name              |  Description                  |
|-------------------|-------------------------------|
|TG_GROUP           | Notifying group               |
|WEBHOOK_URL        | Notificator URL               |
|DOCKERHUB_LOGIN    | `Actions` Repository secret   |
|DOCKERHUB_PASSWORD | `Actions` Repository secret   |
