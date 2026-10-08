#!/bin/sh
set -e

OPTIONS="/data/options.json"
ALLOWED="/etc/nginx/allowed_webhooks.conf"
REAL_IP="/etc/nginx/real_ip.conf"

HA_URL="$(jq -r '.ha_url // "http://homeassistant:8123"' "$OPTIONS")"
HA_URL="${HA_URL%/}"
RATE="$(jq -r '.rate_limit_per_minute // 30' "$OPTIONS")"
MAX_BODY="$(jq -r '.max_body_size_kb // 64' "$OPTIONS")"

: > "$ALLOWED"
count=0
while IFS= read -r id; do
    [ -z "$id" ] && continue
    case "$id" in
        *[!A-Za-z0-9_-]*)
            echo "[ERROR] Invalid webhook ID in allowed_webhook_ids (allowed characters: A-Z a-z 0-9 _ -)"
            exit 1
            ;;
    esac
    printf '"%s" 1;\n' "$id" >> "$ALLOWED"
    count=$((count + 1))
done <<EOF
$(jq -r '.allowed_webhook_ids[]?' "$OPTIONS")
EOF

: > "$REAL_IP"
proxies=""
while IFS= read -r proxy; do
    [ -z "$proxy" ] && continue
    case "$proxy" in
        *[!0-9A-Fa-f.:/]*)
            echo "[ERROR] Invalid entry in trusted_proxies: ${proxy} (expected an IP or CIDR)"
            exit 1
            ;;
    esac
    printf 'set_real_ip_from %s;\n' "$proxy" >> "$REAL_IP"
    proxies="${proxies} ${proxy}"
done <<EOF
$(jq -r '.trusted_proxies[]?' "$OPTIONS")
EOF
if [ -n "$proxies" ]; then
    printf 'real_ip_header CF-Connecting-IP;\n' >> "$REAL_IP"
fi

sed -e "s|__RATE__|$RATE|" \
    -e "s|__MAX_BODY__|$MAX_BODY|" \
    -e "s|__HA_URL__|$HA_URL|" \
    /etc/nginx/nginx.conf.tpl > /etc/nginx/nginx.conf

echo "[INFO] Proxying to ${HA_URL}/api/webhook/<id>"
echo "[INFO] Allowed webhooks: ${count}, rate limit: ${RATE}/min per IP, max body: ${MAX_BODY} KB"
if [ -n "$proxies" ]; then
    echo "[INFO] Using CF-Connecting-IP from trusted proxies:${proxies}"
else
    echo "[WARNING] No trusted_proxies; rate limit applies per connecting IP (shared by all tunnel traffic)"
fi
if [ "$count" -eq 0 ]; then
    echo "[WARNING] No webhook IDs allowed; every request will get a 404"
fi

nginx -t
exec nginx -g 'daemon off;'
