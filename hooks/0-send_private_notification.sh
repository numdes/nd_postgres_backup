#!/usr/bin/env bash
#
# Use http request to send notification to Telegram chat through local Telegram bot

set -eo pipefail
IFS=$'\n\t'

message_text="Backed up ${BACKUP_SCHEDULE} dump ${ARCHIVE_FILE_NAME}. \
File size: ${ARCHIVE_FILE_SIZE}. To ${FULL_S3_DIR_PATH}"

if [[ "${NOTIFICATION_SERVER_URL}" != "**None**" ]]; then
    curl -XPOST \
      --url "${NOTIFICATION_SERVER_URL}" \
      --header 'Content-Type: application/json' \
      --data "{\"key\": \"${TELEGRAM_CHAT_ID}\", \"text\": \"${message_text}\"}" \
      --max-time 10 \
      --retry 5
fi