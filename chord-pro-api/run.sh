#!/bin/bash
set -e

OPTIONS="/data/options.json"

if [ -f "$OPTIONS" ]; then
    export GitlabBaseUrl="$(jq -r '.gitlab_base_url // "https://gitlab.com/api/v4"' "$OPTIONS")"

    i=0
    while IFS= read -r origin; do
        export "AllowedOrigins__${i}=${origin}"
        i=$((i + 1))
    done < <(jq -r '.allowed_origins[]?' "$OPTIONS")
fi

echo "[INFO] GitlabBaseUrl=${GitlabBaseUrl}"
env | grep -E "^AllowedOrigins__" | sort || echo "[INFO] No AllowedOrigins vars found"

dotnet Api.dll &
PID=$!

trap "kill -TERM $PID" SIGTERM SIGINT

wait $PID
exit $?
