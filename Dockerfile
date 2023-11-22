# syntax=docker/dockerfile:1.2

FROM debian:stable as base

LABEL org.opencontainers.image.authors="info@numdes.com"
LABEL org.opencontainers.image.vendor="Numerical Design LLC"
LABEL org.opencontainers.image.description="Docker image for complex store and retention backups on S3"

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    curl \
    ca-certificates \
    cron \
    jq \
    postgresql-client \
    postgresql-common \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl --location --output /usr/local/bin/mcli "https://dl.min.io/client/mc/release/linux-amd64/mc" && \
    chmod +x /usr/local/bin/mcli
RUN mcli --version

# PosgeSQL related variables
ENV POSTGRES_DB="**None**" \
    POSTGRES_HOST="db" \
    POSTGRES_PORT=5432 \
    POSTGRES_USER="**None**" \
    POSTGRES_PASSWORD="**None**" \
    POSTGRES_EXTRA_OPTS="--blobs"
# Paths and depth related variables
ENV HOURLY_BACKUP_PATH="hourly" \
    DAILY_BACKUP_PATH="daily" \
    WEEKLY_BACKUP_PATH="weekly" \
    WEEKLY_BACKUP_LIMIT=5 \
    DAILY_BACKUP_LIMIT=10 \
    HOURLY_BACKUP_LIMIT=25
# Notification related variables
ENV NOTIFICATION_SERVER_URL="**None**" \
    TELEGRAM_CHAT_ID="**None**" \
    TELEGRAM_BOT_TOKEN="**None**"
# S3 bucket related variables
ENV S3_OBJECT_PATH="**None**" \
    S3_ACCESS_KEY="**None**" \
    S3_SECRET_KEY="**None**" \
    S3_ENDPOINT="**None**" \
    S3_BUCKET="**None**" \
    S3_ALIAS="backup"

RUN mkdir /script

# Copy scripts
COPY backup.sh /script/backup.sh
COPY retention.sh /script/retention.sh
COPY hooks /hooks

RUN chmod +x /script/backup.sh
RUN chmod +x /script/retention.sh
RUN chmod +x /hooks/0-send_private_notification.sh
RUN chmod +x /hooks/1-send_telegram_message.sh

COPY docker-entrypoint.sh /
RUN chmod +x docker-entrypoint.sh

ADD crontab /etc/cron.d/my-cron-file
RUN chmod 0644 /etc/cron.d/my-cron-file
RUN crontab /etc/cron.d/my-cron-file

ENTRYPOINT ["/docker-entrypoint.sh"]
