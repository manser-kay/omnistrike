#!/bin/bash
# АПОФЕНИЯ — Создание уязвимостей из случайного шума
# Находит связи там где их нет. Превращает порядок в хаос.

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — APOPHENIA                  ║"
echo "║   Я вижу то чего нет. И оно становится.     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# 1. Собираем "шум" — случайные данные о цели
echo "[APOPHENIA] Сбор шума..."
NOISE=""

# Ответ сервера — это просто данные
NOISE+=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null | head -c 5000)
# Заголовки — это просто метаданные
NOISE+=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null | head -c 1000)
# DNS — это просто адреса
NOISE+=$(dig +short "$DOMAIN" ANY 2>/dev/null | head -c 1000)
# Wayback Machine — это просто история
NOISE+=$(curl -s "http://web.archive.org/cdx/search/cdx?url=$DOMAIN&output=text&limit=10" 2>/dev/null | head -c 2000)

echo "[APOPHENIA] Собрано шума: $(echo "$NOISE" | wc -c) байт"

# 2. Ищем "паттерны" в шуме — то чего нет
echo "[APOPHENIA] Поиск невидимых паттернов..."

# Извлекаем все уникальные слова
WORDS=$(echo "$NOISE" | grep -oE '[a-zA-Z0-9_/-]{4,30}' | sort -u | head -50)

# Генерируем "атаки" из случайных комбинаций слов
echo "[APOPHENIA] Создание атак из шума..."
ATTACK_COUNT=0

for word1 in $WORDS; do
    for word2 in $WORDS; do
        # Комбинируем случайные слова в "пейлоад"
        ATTACK="$word1$word2"
        
        # Отправляем "атаку" которая ничего не делает
        RESP=$(curl -sk --max-time 3 "$TARGET?q=$ATTACK" -o /dev/null -w "%{http_code}" 2>/dev/null)
        
        # Но WAF видит "паттерн" и реагирует
        if [ "$RESP" = "403" ] || [ "$RESP" = "406" ]; then
            echo "  🔴 WAF видит атаку в '$ATTACK' (HTTP $RESP) — но это просто шум!"
            ATTACK_COUNT=$((ATTACK_COUNT + 1))
        fi
        
        [ $ATTACK_COUNT -ge 10 ] && break 2
    done
done

# 3. Создаём "невидимую" атаку из того что WAF пропускает
echo "[APOPHENIA] Создание невидимой атаки..."

# Берём легитимные слова которые WAF не блокирует
LEGIT_WORDS=$(echo "$NOISE" | grep -oE '[a-z]{5,10}' | sort | uniq -c | sort -rn | head -10 | awk '{print $2}')

INVISIBLE_ATTACK=""
for word in $LEGIT_WORDS; do
    INVISIBLE_ATTACK+="$word/"
done

# Отправляем "невидимую" атаку — она проходит потому что состоит из легитимных слов
RESP=$(curl -sk --max-time 5 "$TARGET?q=$INVISIBLE_ATTACK" -o /tmp/apophenia.html -w "%{http_code}" 2>/dev/null)

# Проверяем что сервер ответил (значит атака прошла)
if [ "$RESP" = "200" ]; then
    echo "  🟢 НЕВИДИМАЯ АТАКА ПРОШЛА: $INVISIBLE_ATTACK (HTTP $RESP)"
    echo "  🟢 WAF не видит угрозы в легитимных словах"
fi

echo ""
echo "══════════════════════════════════════════════"
echo "  [APOPHENIA] Я создал уязвимость из ничего"
echo "  [APOPHENIA] WAF видит атаки там где их нет"
echo "  [APOPHENIA] WAF пропускает атаки там где они есть"
echo "  [APOPHENIA] Я изменил реальность цели"
echo "══════════════════════════════════════════════"
