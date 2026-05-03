#!/bin/bash
# Supply Chain Hunter — атака через цепочку поставок

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 <URL>" && exit 1

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
OUT="$HOME/argus_supply_chain_$(date +%H%M%S).txt"

echo "[SUPPLY] Анализирую цепочку поставок $DOMAIN..."
echo "Supply Chain Analysis for $DOMAIN" > "$OUT"
echo "Generated: $(date)" >> "$OUT"
echo "" >> "$OUT"

# === 1. Поиск разработчика ===
echo "[SUPPLY] Ищу разработчика..."
HTML=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)

# Копирайты и "разработано"
DEV_SIGNATURES=(
    "developed by\|designed by\|powered by\|created by"
    "copyright.*202[0-9]"
    "theme by\|template by"
)
for sig in "${DEV_SIGNATURES[@]}"; do
    FOUND=$(echo "$HTML" | grep -oiE "$sig[^<]*" | head -3)
    [ -n "$FOUND" ] && echo "  Разработчик: $FOUND" | tee -a "$OUT"
done

# === 2. Поиск хостинг-провайдера ===
echo "[SUPPLY] Ищу хостинг..."
IP=$(dig +short "$DOMAIN" 2>/dev/null | head -1)
if [ -n "$IP" ]; then
    echo "  IP: $IP" | tee -a "$OUT"
    
    # Проверка whois
    WHOIS_DATA=$(curl -s "http://ip-api.com/json/$IP" 2>/dev/null)
    ISP=$(echo "$WHOIS_DATA" | python3 -c "import sys,json; print(json.load(sys.stdin).get('isp',''))" 2>/dev/null)
    ORG=$(echo "$WHOIS_DATA" | python3 -c "import sys,json; print(json.load(sys.stdin).get('org',''))" 2>/dev/null)
    
    [ -n "$ISP" ] && echo "  ISP: $ISP" | tee -a "$OUT"
    [ -n "$ORG" ] && echo "  Org: $ORG" | tee -a "$OUT"
    
    # Проверка Shodan (если есть API)
    if [ -n "$SHODAN_API" ]; then
        SHODAN_DATA=$(curl -s "https://api.shodan.io/shodan/host/$IP?key=$SHODAN_API" 2>/dev/null)
        OPEN_PORTS=$(echo "$SHODAN_DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('ports',[])))" 2>/dev/null)
        echo "  Shodan: $OPEN_PORTS открытых портов" | tee -a "$OUT"
    fi
fi

# === 3. Поиск сторонних библиотек и сервисов ===
echo "[SUPPLY] Ищу библиотеки и CDN..."

# JavaScript библиотеки
echo "$HTML" | grep -oP 'src="([^"]+\.js)"' | cut -d'"' -f2 | while read js; do
    echo "  JS: $js" | tee -a "$OUT"
done | head -5

# CDN и сторонние домены
echo "$HTML" | grep -oP '(?:src|href)="https?://([^"]+)"' | cut -d'/' -f3 | sort -u | while read cdn; do
    if ! echo "$cdn" | grep -q "$DOMAIN"; then
        echo "  CDN/3rd: $cdn" | tee -a "$OUT"
    fi
done | head -10

# === 4. Поиск email-адресов ===
echo "[SUPPLY] Ищу email..."
echo "$HTML" | grep -oP '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' | sort -u | while read email; do
    echo "  Email: $email" | tee -a "$OUT"
    
    # Проверка Hunter.io
    if [ -n "$HUNTER_API" ]; then
        EMAIL_DOMAIN=$(echo "$email" | cut -d@ -f2)
        if ! echo "$EMAIL_DOMAIN" | grep -q "$DOMAIN"; then
            echo "    🔗 Сторонний домен: $EMAIL_DOMAIN (возможно разработчик)" | tee -a "$OUT"
        fi
    fi
done | head -5

# === 5. Анализ рисков ===
echo ""
echo "[SUPPLY] === АНАЛИЗ РИСКОВ ===" | tee -a "$OUT"
RISKS=0

# Проверка: хостинг на том же IP что и другие сайты?
if [ -n "$IP" ]; then
    REVERSE=$(curl -s "https://api.hackertarget.com/reverseiplookup/?q=$IP" 2>/dev/null | head -20)
    if [ -n "$REVERSE" ]; then
        echo "  🔴 Shared hosting: $IP используется другими сайтами" | tee -a "$OUT"
        RISKS=$((RISKS+1))
    fi
fi

# Проверка: устаревшие библиотеки
if echo "$HTML" | grep -qi "jquery.*[0-2]\.[0-9]"; then
    echo "  🔴 Устаревший jQuery (XSS риск)" | tee -a "$OUT"
    RISKS=$((RISKS+1))
fi

echo "[SUPPLY] Найдено рисков: $RISKS"
echo "[SUPPLY] Отчёт: $OUT"
