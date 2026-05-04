#!/bin/bash
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
[ -z "$TARGET" ] && echo "Usage: $0 target.com" && exit 1

echo "[CACHE v2] Ищу секреты в кэшах CDN и поисковиков..."

# Google Cache
echo "[CACHE] Google:"
curl -sk "https://webcache.googleusercontent.com/search?q=cache:$DOMAIN" 2>/dev/null | grep -oP 'password|secret|token|api_key|-----BEGIN' | sort -u | head -5

# Cloudflare Cache
echo "[CACHE] Cloudflare:"
curl -sk "https://cloudflare.com/cdn-cgi/trace" 2>/dev/null | head -5

# Wayback Machine (история изменений)
echo "[CACHE] Wayback Machine:"
curl -s "http://web.archive.org/cdx/search/cdx?url=$DOMAIN&output=text&fl=original&collapse=urlkey&filter=statuscode:200&limit=10" 2>/dev/null | grep -iE "\.env|\.git|backup|dump|config|password" | head -5

# Yandex Cache
echo "[CACHE] Yandex:"
curl -sk "https://yandexwebcache.net/yandbtm?url=$DOMAIN" 2>/dev/null | grep -oP 'password|secret|token' | sort -u | head -3

echo "[CACHE v2] Поиск завершён"
