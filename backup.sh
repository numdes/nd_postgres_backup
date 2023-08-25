#!/usr/bin/env bash
#
# Script for backing up PostgreSQL database and upload backup to S3.
# After backup is done, script optionally can send notification to Telegram chat or to private URL

set -euo pipefail
IFS=$'\n\t'

export PGPASSWORD=${POSTGRES_PASSWORD}

# Will create base backup
echo "Backing up [${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}] to\
 [${S3_ENDPOINT}], extra opts - [${POSTGRES_EXTRA_OPTS}]."

pg_dump --username="${POSTGRES_USER}" \
        --host="${POSTGRES_HOST}" \
        --port="${POSTGRES_PORT}" \
        --dbname="${POSTGRES_DB}" \
        "${POSTGRES_EXTRA_OPTS}" \
        > "${POSTGRES_DB}".sql

# Declaring variables for informational purposes
if [[ ${S3_OBJECT_PATH} != "**None**" ]]; then
  ARCHIVE_FILE_NAME=$(basename "${S3_OBJECT_PATH}")
  relative_s3_object_path="${S3_OBJECT_PATH}"
else
  # Will be name of directory in backet yyyy-mm-dd_HH:MM:SS
  timestamp="$(date +%F_%T)"

  ARCHIVE_FILE_NAME="${POSTGRES_DB}.tar.gz"
  relative_s3_object_path="${S3_BUCKET}/${POSTGRES_DB}/${timestamp}/${ARCHIVE_FILE_NAME}"
fi

FULL_S3_DIR_PATH="${S3_ENDPOINT}/${relative_s3_object_path}"

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
mcli alias set backup "${S3_ENDPOINT}" "${S3_ACCESS_KEY}" "${S3_SECRET_KEY}"

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
