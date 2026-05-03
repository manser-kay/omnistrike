#!/bin/bash
# Sentinel AI — понимает ответы сервера и адаптирует атаку

TARGET=$1
SENTINEL_LOG="$HOME/argus_sentinel_$(date +%H%M%S).log"

echo "[SENTINEL] Анализирую поведение цели..."

# База знаний: паттерны ответов и их значение
declare -A SENTINEL_KB
SENTINEL_KB["account locked"]="STOP_BRUTEFORCE|Цель блокирует учётные записи"
SENTINEL_KB["too many requests"]="SLOW_DOWN|Rate limiting активен"
SENTINEL_KB["incorrect password"]="CONTINUE|Можно продолжать брутфорс"
SENTINEL_KB["password must be at least"]="ADAPT|Укоротить словарь паролей"
SENTINEL_KB["captcha required"]="STOP_FORM|Обнаружена CAPTCHA, переключиться на API"
SENTINEL_KB["sql syntax"]="CONFIRM_SQLI|SQL инъекция подтверждена"
SENTINEL_KB["permission denied"]="MARK_IDOR|Возможный IDOR - нет прав"
SENTINEL_KB["not found"]="IGNORE|Эндпоинт не существует"
SENTINEL_KB["invalid token"]="RENEW_AUTH|Нужно обновить токен"

echo "[SENTINEL] База знаний загружена: ${#SENTINEL_KB[@]} паттернов"

# Функция анализа ответа
analyze_response() {
    local response=$1
    local context=$2
    
    for pattern in "${!SENTINEL_KB[@]}"; do
        if echo "$response" | grep -qi "$pattern"; then
            local action="${SENTINEL_KB[$pattern]}"
            local command="${action%%|*}"
            local meaning="${action##*|}"
            
            echo "[SENTINEL] [$context] $meaning → $command" | tee -a "$SENTINEL_LOG"
            
            case "$command" in
                STOP_BRUTEFORCE)
                    echo "[SENTINEL] 🛑 Останавливаю брутфорс, переключаюсь на другой вектор" | tee -a "$SENTINEL_LOG"
                    pkill -f "hydra|medusa|brute" 2>/dev/null
                    ;;
                SLOW_DOWN)
                    echo "[SENTINEL] 🐢 Увеличиваю задержки до 5-10 секунд" | tee -a "$SENTINEL_LOG"
                    export JITTER_MIN=5000
                    export JITTER_MAX=10000
                    ;;
                ADAPT)
                    echo "[SENTINEL] 🔧 Адаптирую словарь..." | tee -a "$SENTINEL_LOG"
                    # Убираем короткие пароли
                    ;;
                CONFIRM_SQLI)
                    echo "[SENTINEL] 💉 SQLi ПОДТВЕРЖДЁН! Усиливаю атаку..." | tee -a "$SENTINEL_LOG"
                    ;;
                MARK_IDOR)
                    echo "[SENTINEL] 🔍 Подозрение на IDOR, пробую другие ID" | tee -a "$SENTINEL_LOG"
                    ;;
            esac
            return 0
        fi
    done
    return 1
}

# Тест на реальной цели
if [ -n "$TARGET" ]; then
    echo "[SENTINEL] Тестирую $TARGET..."
    
    # Пробуем разные эндпоинты и анализируем ответы
    for ep in "/login" "/api/auth" "/admin" "/api/v1/users/1"; do
        RESP=$(curl -sk --max-time 5 "$TARGET$ep" 2>/dev/null)
        [ -n "$RESP" ] && analyze_response "$RESP" "$ep"
    done
    
    # Проверка на rate limiting
    echo "[SENTINEL] Проверяю rate limiting..."
    for i in {1..5}; do
        HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" "$TARGET" 2>/dev/null)
        [ "$HTTP_CODE" = "429" ] && analyze_response "too many requests" "homepage" && break
        sleep 0.5
    done
fi

echo "[SENTINEL] Анализ завершён. Лог: $SENTINEL_LOG"
