#!/bin/bash
source ~/argus_logger.sh 2>/dev/null
set -e
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
COMPANY=$(echo "$DOMAIN" | cut -d. -f1)
OUT="$HOME/argus_smart_passwords.txt"

echo "[SMART-BRUTE 2.0] Исследую цель $COMPANY..."
HTML=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)

# Умный сбор данных о компании
EMAILS=$(echo "$HTML" | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | head -5)
YEARS=$(echo "$HTML" | grep -oP '(?:19|20)\d{2}' | sort -u | head -3)
# Ищем утекшие пароли этой компании (публичные базы)
LEAKED=$(curl -sk "https://haveibeenpwned.com/api/v3/breachedaccount/admin@$DOMAIN" 2>/dev/null | grep -c "Name")

> "$OUT"

# Базовые паттерны
echo "${COMPANY}123" >> "$OUT"
echo "${COMPANY}2024" >> "$OUT"
echo "${COMPANY}@2024" >> "$OUT"
echo "admin@${COMPANY}" >> "$OUT"

# Умные паттерны на основе данных
[ -n "$YEARS" ] && for y in $YEARS; do
    echo "${COMPANY}${y}" >> "$OUT"
    echo "${COMPANY}@${y}" >> "$OUT"
done

[ -n "$EMAILS" ] && for e in $EMAILS; do
    user="${e%%@*}"
    echo "${user}123" >> "$OUT"
    echo "${user}@${COMPANY}" >> "$OUT"
    # Популярные паттерны
    echo "${user}${COMPANY}" >> "$OUT"
done

# Если есть утечки — добавляем специальные паттерны
[ "$LEAKED" -gt 0 ] && echo "P@ssw0rd" >> "$OUT" && echo "password123" >> "$OUT"

sort -u "$OUT" -o "$OUT"
echo "[SMART-BRUTE 2.0] Сгенерировано паролей: $(wc -l < "$OUT")"
echo "[SMART-BRUTE 2.0] Файл: $OUT"
