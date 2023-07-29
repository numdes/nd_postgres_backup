#!/usr/bin/env bash
#
# Use http request to send notification to Telegram chat

set -euo pipefail
IFS=$'\n\t'

TXT="${1}"

curl -XPOST \
  --url "${NOTIFICATION_URL}" \
  --header 'Content-Type: application/json' \
  --data "{\"key\": \"${TELEGRAM_CHAT_ID}\", \"text\": \"${TXT}\"}" \
  --max-time 10 \
  --retry 5
