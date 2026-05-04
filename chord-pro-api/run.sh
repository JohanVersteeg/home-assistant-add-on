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

dotnet AzureFunctions.dll &
PID=$!

trap "kill $PID; wait $PID" SIGTERM SIGINT

wait $PID
