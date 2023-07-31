#!/usr/bin/env bash
#
# Script made for backup PostgreSQL database from local (${POSTGRES_HOST}=127.0.0.1)
# or remote host. Created backup stores in S3 storage. On completion script calls
# notification script hooks/00-webhook.sh which sends report to given Telegram Chat

set -euox pipefail
IFS=$'\n\t'

# Will be name of directory in backet yyyy-mm-dd_HH:MM:SS
timestamp="$(date +%F_%T)"

export PGPASSWORD=${POSTGRES_PASSWORD}

# Will create base backup
echo "Creating backup of ${POSTGRES_DB} database. From ${POSTGRES_HOST} and port \
is ${POSTGRES_PORT}. Username: ${POSTGRES_USER}. With following extra options: \
${POSTGRES_EXTRA_OPTS}"
pg_dump --username="${POSTGRES_USER}" \
        --host="${POSTGRES_HOST}" \
        --port="${POSTGRES_PORT}" \
        --dbname="${POSTGRES_DB}" \
        "${POSTGRES_EXTRA_OPTS}" \
        > "${POSTGRES_DB}".sql

# Declaring variables for informational purposes
copy_file_name="${POSTGRES_DB}.tar.gz"
copy_path="${S3_BUCKET}/${POSTGRES_DB}/${timestamp}"
mcli_copy_path="${copy_path}/${copy_file_name}"
info_copy_path="${S3_ENDPOINT}/${copy_path}"

# Do compression
#tar -czvf "${copy_file_name}" "${POSTGRES_DB}.sql"
tar --create \
    --gzip \
    --verbose \
    --file "${copy_file_name}" \
    "${POSTGRES_DB}.sql"

# Count file size
send_file_size="$(ls -lh | grep "${copy_file_name}" | awk '{print $5}')"

echo "Created ${copy_file_name} with file size: ${send_file_size}"

# Set S3 connection configuration
mcli alias set backup "${S3_ENDPOINT}" "${S3_ACCESS_KEY_ID}" "${S3_SECRET_ACCESS_KEY}"

echo "Starting to copy ${copy_file_name} to ${info_copy_path}..."

# Copying backup to S3
mcli cp "${copy_file_name}" backup/"${mcli_copy_path}"

# Do nettoyage
echo "Maid is here... Doing cleaning..."
rm --force "${POSTGRES_DB}".*

# Do anounce
run-parts --reverse \
          --arg "${copy_file_name}" \
          --arg "${send_file_size}" \
          --arg "${info_copy_path}" \
          /hooks
