#!/usr/bin/env bash
#
# Script made for backup PostgreSQL database from local (${POSTGRES_HOST}=127.0.0.1)
# or remote host. Created backup puts on S3 storage. On completion script calls
# notification script hooks/00-webhook.sh which sends report to given Telegram Chat

set -euo pipefail
IFS=$'\n\t'

# Will be name of directory in backet dd-mm-yyyy_hh-mm-ss
timestamp="$(date +%F_%T)"

# Export stuff
export PGPASSWORD=${POSTGRES_PASSWORD}

# Will create base backup
echo "Creating backup of ${POSTGRES_DB} database. From ${POSTGRES_HOST} and port \
is ${POSTGRES_PORT}. Username: ${POSTGRES_USER}. With following extra options: \
${POSTGRES_EXTRA_OPTS}"
pg_dump --username "${POSTGRES_USER}" \
        -h "${POSTGRES_HOST}" \
        -p "${POSTGRES_PORT}" \
        -d "${POSTGRES_DB}" \
        "${POSTGRES_EXTRA_OPTS}" \
        > "${POSTGRES_DB}".sql

# Declaring variables for informational purposes
copy_file_name="${POSTGRES_DB}.${BACKUP_SUFFIX}"
copy_path="${S3_BUCKET}/${POSTGRES_DB}/${timestamp}"
mcli_copy_path="${copy_path}/${copy_file_name}"
info_copy_path="${S3_ENDPOINT}/${copy_path}"

# Do compression
tar -czvf "${copy_file_name}" "${POSTGRES_DB}.sql"

# Count file size
size_in_bytes="$(du -b "${copy_file_name}" | awk '{print $1}')"
if (( size_in_bytes < 1048576 )); then
  file_measure=" Kb"
  file_size="$((size_in_bytes / 1024))"
  send_file_size="${file_size}${file_measure}"
elif (( size_in_bytes < 1073741824 )); then
  file_measure=" Mb"
  file_size="$((size_in_bytes / (1024 * 1024)))"
  send_file_size="${file_size}${file_measure}"
else
  file_measure=" Gb"
  file_size="$((size_in_bytes / (1024 * 1024 * 1024)))"
  send_file_size="${file_size}${file_measure}"
fi


echo "Backed up ${copy_file_name} with file size: ${send_file_size}"

# Set S3 connection configuration
mcli alias set backup "${S3_ENDPOINT}" "${S3_ACCESS_KEY_ID}" "${S3_SECRET_ACCESS_KEY}"

echo "Starting to copy ${copy_file_name} to ${info_copy_path}..."

# Create the bucket (Only enable if neccessary)
#    mcli mb backup/${S3_BUCKET}
mcli cp "${copy_file_name}" backup/"${mcli_copy_path}"

# Do nettoyage
echo "Maid is here... Doing cleaning..."
rm -f "${POSTGRES_DB}.*"

# Do anounce
if [[ ${TELEGRAM_METHOD} == 'private' ]]; then
  txt="Backed up ${copy_file_name} with file size: ${send_file_size} \
  to ${info_copy_path}"
  hooks/private-webhook.sh "${txt}"
elif [[ ${TELEGRAM_METHOD} == 'external' ]]; then
  txt="Backed up ${copy_file_name} with file size: ${send_file_size} \
  to ${info_copy_path}"
  hooks/external-webhook.sh "${txt}"
else
  echo "No notification methods selected"
fi
