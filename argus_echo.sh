#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "[ECHO] Слепой детект WAF через timing..."

# Безобидный запрос
START=$(python3 -c "import time; print(time.time()*1000)")
curl -sk --max-time 5 "$TARGET" -o /dev/null 2>/dev/null
NORMAL=$(( $(python3 -c "import time; print(time.time()*1000)") - START ))

# Запрос с SQLi
START=$(python3 -c "import time; print(time.time()*1000)")
curl -sk --max-time 5 "$TARGET?id=1'%20OR%20'1'='1" -o /dev/null 2>/dev/null
SQLI=$(( $(python3 -c "import time; print(time.time()*1000)") - START ))

DIFF=$((SQLI - NORMAL))
echo "[ECHO] Нормальный запрос: ${NORMAL}ms"
echo "[ECHO] SQLi запрос: ${SQLI}ms"
echo "[ECHO] Разница: ${DIFF}ms"

if [ "$DIFF" -gt 100 ]; then
    echo "🔴 WAF ОБНАРУЖЕН (задержка ${DIFF}ms — похоже на Cloudflare/AWS)"
elif [ "$DIFF" -gt 50 ]; then
    echo "🟡 ВОЗМОЖЕН WAF (задержка ${DIFF}ms — похоже на ModSecurity)"
else
    echo "🟢 WAF не обнаружен"
fi
