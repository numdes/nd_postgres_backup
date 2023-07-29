#!/usr/bin/env bash
#
# Use http request to send notification to Telegram chat through local Telegram bot

set -euo pipefail
IFS=$'\n\t'

message_text="${1}"

curl -XPOST \
  --url "${NOTIFICATION_URL}" \
  --header 'Content-Type: application/json' \
  --data "{\"key\": \"${TELEGRAM_CHAT_ID}\", \"text\": \"${message_text}\"}" \
  --max-time 10 \
  --retry 5
