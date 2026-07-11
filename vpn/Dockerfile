FROM ghcr.io/xtls/xray-core:latest AS xray

FROM alpine:3.20
RUN apk add --no-cache gettext ca-certificates tzdata

COPY --from=xray /usr/local/bin/xray /usr/local/bin/xray
COPY --from=xray /usr/local/share/xray /usr/local/share/xray

COPY config.json.template /etc/xray/config.json.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
