#!/usr/bin/env bash
#
# Script made for backup PostgreSQL database from local (${POSTGRES_HOST}=127.0.0.1)
# or remote host. Created backup stores in S3 storage. On completion script calls
# notification scripts from hooks/ directory to send report to given Telegram Chat
# based on variables set private or public notification method will be selected

set -euo pipefail
IFS=$'\n\t'

# Will be name of directory in backet yyyy-mm-dd_HH:MM:SS
timestamp="$(date +%F_%T)"

export PGPASSWORD=${POSTGRES_PASSWORD}

# Will create base backup
echo "Creating backup of ${POSTGRES_DB} database that is accessible from [${POSTGRES_HOST}:${POSTGRES_PORT}]\
by username [${POSTGRES_USER}], extra options - [${POSTGRES_EXTRA_OPTS}]."

pg_dump --username="${POSTGRES_USER}" \
        --host="${POSTGRES_HOST}" \
        --port="${POSTGRES_PORT}" \
        --dbname="${POSTGRES_DB}" \
        "${POSTGRES_EXTRA_OPTS}" \
        > "${POSTGRES_DB}".sql

# Declaring variables for informational purposes
ARCHIVE_FILE_NAME="${POSTGRES_DB}.tar.gz"
relative_s3_dir_path="${S3_BUCKET}/${POSTGRES_DB}/${timestamp}"
relative_s3_object_path="${relative_s3_dir_path}/${ARCHIVE_FILE_NAME}"
FULL_S3_DIR_PATH="${S3_ENDPOINT}/${relative_s3_dir_path}"

# Do compression
tar --create \
    --gzip \
    --verbose \
    --file "${ARCHIVE_FILE_NAME}" \
    "${POSTGRES_DB}.sql"

# Count file size
ARCHIVE_FILE_SIZE="$(ls -lh "${ARCHIVE_FILE_NAME}" | awk '{print $5}')"

echo "Created ${ARCHIVE_FILE_NAME} with file size: ${ARCHIVE_FILE_SIZE}"

# Set S3 connection configuration
mcli alias set backup "${S3_ENDPOINT}" "${S3_ACCESS_KEY_ID}" "${S3_SECRET_ACCESS_KEY}"

echo "Starting to copy ${ARCHIVE_FILE_NAME} to ${FULL_S3_DIR_PATH}..."

# Copying backup to S3
mcli cp "${ARCHIVE_FILE_NAME}" backup/"${relative_s3_object_path}"

# Do clean up
echo "Maid is here... Doing cleaning..."
rm --force "${POSTGRES_DB}".*

# Do announce
export ARCHIVE_FILE_NAME
export ARCHIVE_FILE_SIZE
export FULL_S3_DIR_PATH
run-parts --reverse \
          --arg "${ARCHIVE_FILE_NAME}" \
          --arg "${ARCHIVE_FILE_SIZE}" \
          --arg "${FULL_S3_DIR_PATH}" \
          /hooks
