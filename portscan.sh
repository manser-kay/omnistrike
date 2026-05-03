#!/bin/bash
TARGET=$1
echo "[PORT] Scanning top 20 ports..."
for port in 22 80 443 8080 8443 3306 5432 6379 27017 25 21 53 110 143 993 995 3389 5900 8888 9000; do
    timeout 1 bash -c "echo >/dev/tcp/$(echo $TARGET | sed 's|https\?://||;s|/.*||')/$port" 2>/dev/null && echo "  🟢 $port open"
done
