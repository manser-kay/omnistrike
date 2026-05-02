#!/bin/bash
# Argus Whisper — 100% пассивная разведка. Ни одного пакета к цели.
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 example.com" && exit 1

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
OUT="$HOME/argus_whisper_${DOMAIN}_$(date +%H%M).txt"

echo "[WHISPER] 🤫 Начинаю бесшумную разведку $DOMAIN..." | tee "$OUT"
echo "" | tee -a "$OUT"

# 1. Wayback Machine
echo "[WHISPER] 📚 Архивные копии (Wayback Machine)..." | tee -a "$OUT"
curl -s "http://web.archive.org/cdx/search/cdx?url=*.$DOMAIN/*&output=text&fl=original&collapse=urlkey&limit=10" 2>/dev/null | head -10 | tee -a "$OUT"
echo "" | tee -a "$OUT"

# 2. SSL сертификаты
echo "[WHISPER] 🔒 SSL сертификаты (crt.sh)..." | tee -a "$OUT"
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>/dev/null | python3 -c "
import sys,json
try:
    data = json.load(sys.stdin)
    names = set()
    for d in data[:20]:
        name = d.get('name_value','')
        for n in name.split('\\n'):
            if n.strip():
                names.add(n.strip())
    for n in sorted(list(names))[:10]:
        print(f'  📜 {n}')
except: pass
" 2>/dev/null | tee -a "$OUT"
echo "" | tee -a "$OUT"

# 3. DNS история
echo "[WHISPER] 🌐 DNS история (SecurityTrails)..." | tee -a "$OUT"
curl -s "https://securitytrails.com/domain/$DOMAIN/dns" 2>/dev/null | grep -oP '"record_type":"[^"]*"' | sort -u | head -5 | tee -a "$OUT"
echo "" | tee -a "$OUT"

# 4. Google Cache
echo "[WHISPER] 🗄️ Google Cache..." | tee -a "$OUT"
CACHE=$(curl -sk "https://webcache.googleusercontent.com/search?q=cache:$DOMAIN" 2>/dev/null)
if [ -n "$CACHE" ]; then
    echo "  ✅ Кэш доступен" | tee -a "$OUT"
    echo "$CACHE" | grep -oP '<title>[^<]*' | head -1 | tee -a "$OUT"
fi
echo "" | tee -a "$OUT"

# 5. Shodan (только публичное)
echo "[WHISPER] 🔍 Shodan (публичный обзор)..." | tee -a "$OUT"
curl -s "https://www.shodan.io/search?query=hostname:$DOMAIN" 2>/dev/null | grep -oP '"http\.host":"[^"]*"' | head -5 | tee -a "$OUT"

echo "" | tee -a "$OUT"
echo "[WHISPER] ✅ Разведка завершена. Отчёт: $OUT" | tee -a "$OUT"
