# syntax=docker/dockerfile:1.2

FROM debian:stable as base

MAINTAINER NumDes <info@numdes.com>

LABEL org.opencontainers.image.vendor="Numerical Design LLC"
LABEL org.opencontainers.image.description="Docker image for universal postgres backups"

ARG GOCRONVER=v0.0.10

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    curl \
    ca-certificates \
    postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && curl --fail \
        --retry 4 \
        --retry-all-errors \
        --output /usr/local/bin/go-cron.gz \
        --location https://github.com/prodrigestivill/go-cron/releases/download/$GOCRONVER/go-cron-linux-amd64.gz \
    && gzip --verbose \
          --no-name \
          --decompress /usr/local/bin/go-cron.gz \
    && chmod a+x /usr/local/bin/go-cron

RUN curl --location --output /usr/local/bin/mcli "https://dl.min.io/client/mc/release/linux-amd64/mc" && \
    chmod +x /usr/local/bin/mcli
RUN mcli --version

ENV POSTGRES_DB="**None**" \
    POSTGRES_HOST="**None**" \
    POSTGRES_PORT=5432 \
    POSTGRES_USER="**None**" \
    POSTGRES_PASSWORD="**None**" \
    POSTGRES_EXTRA_OPTS="--blobs" \
    SCHEDULE="@daily" \
    HEALTHCHECK_PORT=8080 \
    S3_ACCESS_KEY="**None**" \
    S3_SECRET_KEY="**None**" \
    S3_BUCKET="**None**" \
    S3_ENDPOINT="**None**" \


COPY backup.sh /backup.sh
COPY init_script.sh /init_script.sh

COPY hooks /hooks

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["./init_script.sh"]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f "http://localhost:$HEALTHCHECK_PORT/" || exit 1
