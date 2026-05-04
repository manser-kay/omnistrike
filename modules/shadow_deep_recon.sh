#!/bin/bash
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
OUT="$HOME/shadow_recon_$DOMAIN"
mkdir -p "$OUT"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — DEEP RECON                 ║"
echo "╚══════════════════════════════════════════════╝"

# 1. SSL сертификаты
echo "[RECON] SSL Certificates..."
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    names = set()
    for d in data[:30]:
        for n in d.get('name_value','').split('\n'):
            if n.strip(): names.add(n.strip())
    print(f'  Сертификатов: {len(names)}')
    for n in sorted(list(names))[:15]:
        print(f'  📜 {n}')
except: print('  Нет данных')
" 2>/dev/null

# 2. Wayback Machine
echo "[RECON] Wayback Machine..."
curl -s "http://web.archive.org/cdx/search/cdx?url=*.$DOMAIN/*&output=text&fl=original&collapse=urlkey&limit=20" 2>/dev/null | head -20 > "$OUT/wayback.txt"
echo "  URL: $(wc -l < "$OUT/wayback.txt")"

# 3. DNS записи
echo "[RECON] DNS Records..."
for type in A AAAA MX NS TXT CNAME; do
    dig +short "$DOMAIN" "$type" 2>/dev/null | head -3 | while read line; do
        [ -n "$line" ] && echo "  $type: $line"
    done
done

# 4. Соседи по IP
IP=$(dig +short "$DOMAIN" 2>/dev/null | head -1)
if [ -n "$IP" ]; then
    echo "[RECON] Reverse IP ($IP)..."
    curl -s "https://api.hackertarget.com/reverseiplookup/?q=$IP" 2>/dev/null | head -10
fi

# 5. Технологии
echo "[RECON] Technologies..."
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
echo "$HEADERS" | grep -qi "cf-ray" && echo "  🛡️ Cloudflare"
echo "$HEADERS" | grep -qi "X-Powered-By" && echo "  ⚡ $(echo "$HEADERS" | grep -i "X-Powered-By" | head -1)"
echo "$HEADERS" | grep -qi "Server:" && echo "  📡 $(echo "$HEADERS" | grep -i "Server:" | head -1)"

echo "[RECON] Done: $OUT"
