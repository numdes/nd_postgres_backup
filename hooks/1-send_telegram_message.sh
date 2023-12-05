#!/usr/bin/env bash
#
# Use http request to send notification to Telegram chat through external Telegram API

set -eo pipefail
IFS=$'\n\t'

message_text="Backed up ${BACKUP_SCHEDULE} dump ${ARCHIVE_FILE_NAME}. \
File size: ${ARCHIVE_FILE_SIZE}. To ${FULL_S3_DIR_PATH}"

if [[ ${TELEGRAM_BOT_TOKEN} != "**None**" ]]; then
  if [[ "${TELEGRAM_CHAT_ID}" =~ ^[0-9]{5,32}$ ]]; then
    curl -s \
      --data "text=${message_text}" \
      --data "chat_id=${TELEGRAM_CHAT_ID}" \
      'https://api.telegram.org/bot'${TELEGRAM_BOT_TOKEN}'/sendMessage' > /dev/null
  else
    echo "Telegram chatID doesn't matched to standard pattern. Probably \
    TELEGRAM_BOT_TOKEN variable was set by mistake"
  fi
fi