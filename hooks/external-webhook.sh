#!/usr/bin/env bash
#
# Use http request to send notification to Telegram chat through external Telegram API

set -euo pipefail
IFS=$'\n\t'

message_text="${1}"

curl -s \
     --data "text=${message_text}" \
     --data "chat_id=${TELEGRAM_CHAT_ID}" \
     'https://api.telegram.org/bot'${TELEGRAM_BOT_TOKEN}'/sendMessage' > /dev/null
