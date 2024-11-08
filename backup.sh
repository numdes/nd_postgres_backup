#!/usr/bin/env bash
#
# Script for backing up PostgreSQL database and upload backup to S3.
# After backup is done, script optionally can send notification to Telegram chat or to private URL

set -euo pipefail
IFS=$'\n\t'

# Check if we have gotten path argument from scheduler if not set path to /
if [[ -z "$1" ]]; then
  backup_path=""
elif  [[ ! "$1" == */ ]]; then
  backup_path="$1/"
else
  backup_path="$1"
fi

# Disable hourly backups
if [[ "${HOURLY_BACKUP_LIMIT}" == "0" && "${backup_path}" =~ ^hourly.? ]]; then
  echo "Hourly backups are disabled. Exiting..."
  exit 0
fi

export PGPASSWORD=${POSTGRES_PASSWORD}

mkdir --parents $backup_path
cd $backup_path

echo "Starting $1 backup in $(pwd)"

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
  relative_s3_object_path="${S3_BUCKET}/${backup_path}${timestamp}/${ARCHIVE_FILE_NAME}"
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

# Set an alias for S3 interoperation
mcli alias set "${S3_ALIAS}" "${S3_ENDPOINT}" "${S3_ACCESS_KEY}" "${S3_SECRET_KEY}"

echo "Starting to copy ${ARCHIVE_FILE_NAME} to ${FULL_S3_DIR_PATH}..."

# Copying backup to S3
mcli cp "${ARCHIVE_FILE_NAME}" "${S3_ALIAS}"/"${relative_s3_object_path}"

# Do clean up
echo "Maid is here... Doing cleaning..."
cd ..
rm --recursive --force $backup_path

# Do announce
# We are not going to spam chat every hour. Excluded hourly backups from notifications
if [[ ! ${backup_path} =~ ^hourly.? ]]; then
  echo "Starting notification routine..."
# Check which backup routine applied  
  if [[ ${backup_path} =~ ^daily.? ]]; then
    BACKUP_SCHEDULE="-=DAILY=-"
  elif [[ ${backup_path} =~ ^weekly.? ]]; then
    BACKUP_SCHEDULE="-=WEEKLY=-"
  elif [[ ${backup_path} =~ ^monthly.? ]]; then
    BACKUP_SCHEDULE="-=MONTHLY=-"
  else
    BACKUP_SCHEDULE="-=UNCERTAIN SCHEDULE=-"
  fi
# Set variables globally  
  export ARCHIVE_FILE_NAME
  export ARCHIVE_FILE_SIZE
  export FULL_S3_DIR_PATH
  export BACKUP_SCHEDULE
# Start execution of notification scripts
  find /hooks -type f -name '*.sh' -print0 | \
        sort -z | \
        xargs -0 -I {} sh -c 'echo "Running: {}" && {}'
fi