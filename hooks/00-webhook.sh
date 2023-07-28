#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

TXT="$1"

curl -XPOST \
  --url "${WEBHOOK_URL}" \
  --header 'Content-Type: application/json' \
  --data "{\"key\": \"$TG_GROUP\", \"text\": \"$TXT\"}" \
  --max-time 10 \
  --retry 5
