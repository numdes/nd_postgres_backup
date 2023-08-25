#!/usr/bin/env bash
#
# Script checks if mandatory variables are set and starts cron job for DB backup 

set -euo pipefail
IFS=$'\n\t'


# Begin values check
if [[ ${S3_ACCESS_KEY} == "**None**" ]] ||
   [[ ${S3_SECRET_KEY} == "**None**" ]] ||
   [[ ${S3_BUCKET} == "**None**" ]] ||
   [[ ${S3_ENDPOINT} == "**None**" ]] ||
   [[ ${POSTGRES_DB} == "**None**" ]] ||
   [[ ${POSTGRES_HOST} == "**None**" ]] ||
   [[ ${POSTGRES_USER} == "**None**" ]] ||
   [[ ${POSTGRES_PASSWORD} == "**None**" ]]; then
  echo "One or more mandatory values is missing. Check your configuration..." >&2
  exit 1
fi

# check if $SCEDULE is set
if [[ ${SCHEDULE} == "**None**" ]]; then
  echo "Schedule is not set. Let's make backup and leave..."
  exec /backup.sh
  exit 0
fi

echo "Run backup with schedule: $SCHEDULE"
exec /usr/local/bin/go-cron -s $SCHEDULE -p $HEALTHCHECK_PORT -- /backup.sh
