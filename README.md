# nd_postgres_backup
Docker image for universal postgres backups

# Roadmap
- [ ] Add support for S3
- [ ] Add retention policy settings by env vars
- [ ] Notify about backup status by HTTP-request

# Docker build
```
docker build . -t pg-backups:0.0.1
```

# How to backup manually
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
    --entrypoint /bin/bash \
    IMAGE-NAME:tag
```
```
# ./backup.sh
```

# How to backup using `go-cron`
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
    IMAGE-NAME:tag
```
