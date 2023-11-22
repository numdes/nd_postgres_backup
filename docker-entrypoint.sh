#!/usr/bin/env bash
#
# Script exports environmet variables to make them
# accessible to cron job and checks if mandatory variables are set

set -euo pipefail
IFS=$'\n\t'

# Begin values check
if [[ ${S3_ACCESS_KEY} == "**None**" ]] ||
   [[ ${S3_SECRET_KEY} == "**None**" ]] ||
   [[ ${S3_ENDPOINT} == "**None**" ]] ||
   [[ ${POSTGRES_DB} == "**None**" ]] ||
   [[ ${POSTGRES_USER} == "**None**" ]] ||
   [[ ${POSTGRES_PASSWORD} == "**None**" ]]; then
  echo "One or more mandatory values is missing. Check your configuration..." >&2
  exit 1
fi

# check if we run container only to make backup once
if [[ ${S3_BUCKET} == "**None**" ]]; then
  echo "Target path (S3_BUCKET) is not set. Let's make backup \
        to ${S3_OBJECT_PATH} (S3_OBJECT_PATH variable) and leave..."
  exec /script/backup.sh
  exit 0
fi

echo "Export environment variables and then run cron"
export > /script/.env
cron -f
