#!/usr/bin/env bash
#
# Perform procedure to keep weekly, daily and hourly backups in desired
# store depth in given directories on S3 storage

set -euo pipefail
IFS=$'\n\t'

# Set an alias for S3 interoperation
mcli alias set "${S3_ALIAS}" "${S3_ENDPOINT}" "${S3_ACCESS_KEY}" "${S3_SECRET_KEY}"

####################################
#  Retention procedure for backups in each storage
#  Arguments:
#    Paths to where backups are stored e.g. ${HOURLY_BACKUP_PATH}
#    Maximum allowed number of backups for given periods e.g. ${HOURLY_BACKUP_LIMIT}
####################################
retention_func() {

  local backup_path="$1"
  local backup_limit="$2"
# Here we are getting json-formed data from S3 and convey it to JQ
# where we are sorting and selecting all backup directories except given last ones
# How many backups should remain decides $backup_limit variable.
# Each backup suitable for deletion conveys through `xargs` line for removal
  mcli --json  ls -recursive "${S3_ALIAS}"/"${S3_BUCKET}"/"${backup_path}" | \
  jq -s --arg backup_limit ${backup_limit} '.
      | sort_by(.lastModified)
      | .[0:-($backup_limit | tonumber)]
      | .[] | .key' | \
  xargs -I {} mcli rm --recursive --force "${S3_ALIAS}"/"${S3_BUCKET}"/"${backup_path}"/{}
}

retention_func ${HOURLY_BACKUP_PATH} ${HOURLY_BACKUP_LIMIT}

retention_func ${DAILY_BACKUP_PATH} ${DAILY_BACKUP_LIMIT}

retention_func ${WEEKLY_BACKUP_PATH} ${WEEKLY_BACKUP_LIMIT}