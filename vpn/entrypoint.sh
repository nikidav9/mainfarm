#!/bin/sh
set -eu

: "${VLESS_UUID:?VLESS_UUID env var is required}"
: "${PORT:?PORT env var is required (Railway sets this automatically)}"
: "${VLESS_WS_PATH:=/vless}"

export PORT VLESS_UUID VLESS_WS_PATH

envsubst '${PORT} ${VLESS_UUID} ${VLESS_WS_PATH}' \
  < /etc/xray/config.json.template > /etc/xray/config.json

exec xray run -config /etc/xray/config.json
