#!/bin/bash
# Авто-тайминг — атака в лучшее время
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "[TIMING] Анализирую лучшее время для атаки..."

# Проверяем время ответа сервера (меньше задержка = меньше нагрузка = админ спит)
HOURS=()
for h in {0..23}; do
    TIME=$(curl -sk --max-time 5 -o /dev/null -w '%{time_total}' "$TARGET" 2>/dev/null)
    HOURS+=("$TIME")
    [ "${TIME%.*}" -lt 1 ] && echo "  $h:00 — СЕРВЕР СВОБОДЕН (${TIME}s)"
done

# Лучшее время — 3 часа ночи
BEST_HOUR=3
NOW=$(date +%H)
if [ "$NOW" -eq "$BEST_HOUR" ]; then
    echo "[TIMING] ⚡ ИДЕАЛЬНОЕ ВРЕМЯ! Запускаю атаку..."
    ~/shadow.sh "$TARGET"
else
    WAIT=$(( (24 - NOW + BEST_HOUR) % 24 ))
    echo "[TIMING] ⏰ Атака через ${WAIT} часов (в ${BEST_HOUR}:00)"
fi
