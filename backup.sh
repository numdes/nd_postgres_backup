#!/usr/bin/env bash
#
# Script made for backup PostgreSQL database from local (${POSTGRES_HOST}=127.0.0.1)
# or remote host. Created backup puts on S3 storage. On completion script calls
# notification script hooks/00-webhook.sh which sends report to given Telegram Chat
#
# TODO (siameseoriental) Implement error handling

set -euo pipefail
IFS=$'\n\t'

# Will be name of directory in backet dd-mm-yyyy_hh-mm-ss
timestamp="$(date date +%FT%T%Z)"

# Export stuff
export PGPASSWORD=${POSTGRES_PASSWORD}

# Will create base backup
echo "Creating backup of ${POSTGRES_DB} database..."
pg_dump --username ${POSTGRES_USER} \
        -h ${POSTGRES_HOST} \
        -p ${POSTGRES_PORT} \
        -d ${POSTGRES_DB} \
        ${POSTGRES_EXTRA_OPTS} \
        > ${POSTGRES_DB}.sql
# Do compression
tar -czvf "${POSTGRES_DB}.${BACKUP_SUFFIX} ${POSTGRES_DB}.sql"

# Set S3 connection configuration
mcli alias set backup "${S3_ENDPOINT} ${S3_ACCESS_KEY_ID} ${S3_SECRET_ACCESS_KEY}"

# Create the bucket (Only enable if neccessary)
#    mcli mb backup/${S3_BUCKET}
mcli cp ${POSTGRES_DB}.${BACKUP_SUFFIX} \
     backup/${S3_BUCKET}/${POSTGRES_DB}/${timestamp}/${POSTGRES_DB}.${BACKUP_SUFFIX}

# Do nettoyage
echo "Maid is here... Doing cleaning..."
rm -f "${POSTGRES_DB}.*"

# Do anounce
txt="Backuped successfully to
${S3_ENDPOINT}/${S3_BUCKET}/${POSTGRES_DB}/${timestamp}/${POSTGRES_DB}.${BACKUP_SUFFIX}"
hooks/00-webhook.sh "${txt}"
