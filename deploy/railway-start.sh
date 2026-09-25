#!/bin/sh
set -eu

: "${APP_USERNAME:?Set APP_USERNAME in Railway variables}"
: "${APP_PASSWORD:?Set APP_PASSWORD in Railway variables}"

mkdir -p /data/storage
if [ ! -f /data/config.toml ]; then
    cp /MoneyPrinterTurbo/config.example.toml /data/config.toml
fi

# Keep rendered videos and uploads on the mounted Railway volume.
rm -rf /MoneyPrinterTurbo/storage
ln -s /data/storage /MoneyPrinterTurbo/storage

APP_PASSWORD_HASH="$(caddy hash-password --plaintext "$APP_PASSWORD")"
export APP_PASSWORD_HASH
caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile >/dev/null 2>&1 &

exec streamlit run /MoneyPrinterTurbo/webui/Main.py \
    --server.address=127.0.0.1 \
    --server.port=8501 \
    --browser.gatherUsageStats=false \
    --client.toolbarMode=minimal \
    --logger.hideWelcomeMessage=true \
    --server.showEmailPrompt=false
