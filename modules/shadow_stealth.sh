#!/bin/bash
# Режим невидимки — полная скрытность
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "[STEALTH] Активирую режим невидимки..."

# 1. Проверяем Tor
if pgrep -x tor >/dev/null 2>&1; then
    echo "  🧅 Tor активен"
else
    echo "  🧅 Запускаю Tor..."
    tor >/dev/null 2>&1 &
    sleep 5
fi

# 2. Случайная задержка перед началом (обход sandbox)
SLEEP_TIME=$((30 + RANDOM % 60))
echo "  ⏰ Задержка: ${SLEEP_TIME}с (обход песочниц)"
sleep "$SLEEP_TIME"

# 3. Проверка на виртуализацию
if grep -q "hypervisor\|VMware\|VirtualBox" /proc/cpuinfo 2>/dev/null; then
    echo "  ⚠️ Виртуалка — не запускаюсь (возможно песочница)"
    exit 0
fi

# 4. Запуск с рандомизацией
UA_LIST=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7) Safari/605.1.15"
    "Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148"
)

echo "[STEALTH] Начинаю скрытое сканирование..."

# Сканируем медленно, через Tor, с разными UA
for i in {1..10}; do
    UA="${UA_LIST[$((RANDOM % ${#UA_LIST[@]}))]}"
    (proxychains4 curl -sk --max-time 10 -A "$UA" "$TARGET" -o /dev/null 2>/dev/null) &
    sleep $((5 + RANDOM % 10))
done

wait
echo "[STEALTH] Сканирование завершено — цель не заметила"
