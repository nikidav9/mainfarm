#!/bin/sh
set -eu

: "${VLESS_UUID:?VLESS_UUID env var is required}"
: "${PORT:=8443}"
: "${REALITY_PRIVATE_KEY:?REALITY_PRIVATE_KEY env var is required}"
: "${REALITY_SHORT_ID:?REALITY_SHORT_ID env var is required}"
: "${REALITY_DEST:=www.microsoft.com:443}"
: "${REALITY_SERVER_NAME:=www.microsoft.com}"

export PORT VLESS_UUID REALITY_PRIVATE_KEY REALITY_SHORT_ID REALITY_DEST REALITY_SERVER_NAME

envsubst '${PORT} ${VLESS_UUID} ${REALITY_PRIVATE_KEY} ${REALITY_SHORT_ID} ${REALITY_DEST} ${REALITY_SERVER_NAME}' \
  < /etc/xray/config.json.template > /etc/xray/config.json

exec xray run -config /etc/xray/config.json
