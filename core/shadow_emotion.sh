#!/bin/bash
# EMOTION — Эмоциональный интеллект цифровой вселенной
# Организмы чувствуют и действуют на основе эмоций

EMOTION_DIR="$HOME/.shadow_emotion"
mkdir -p "$EMOTION_DIR/moods" "$EMOTION_DIR/relationships"

declare -A EMOTIONS
EMOTIONS["curious"]="Исследует новые цели"
EMOTIONS["aggressive"]="Атакует без остановки"
EMOTIONS["cautious"]="Проверяет каждый шаг"
EMOTIONS["fearful"]="Прячется при детекте"
EMOTIONS["confident"]="Игнорирует защиту"
EMOTIONS["vengeful"]="Мстит за блокировку"
EMOTIONS["playful"]="Экспериментирует с пейлоадами"
EMOTIONS["neutral"]="Ожидает команды"

# Установить эмоцию (основная функция)
set_emotion() {
    local agent=$1
    local emotion=$2
    local intensity=${3:-5}
    echo "EMOTION=$emotion|INTENSITY=$intensity|SET=$(date +%s)" > "$EMOTION_DIR/moods/$agent.txt"
    echo "[EMOTION] 😠 $agent чувствует: ${EMOTIONS[$emotion]} (сила: $intensity)"
}

# Получить эмоцию
get_emotion() {
    local agent=$1
    local mood_file="$EMOTION_DIR/moods/$agent.txt"
    if [ -f "$mood_file" ]; then
        grep "EMOTION=" "$mood_file" | cut -d'|' -f1 | cut -d'=' -f2
    else
        echo "neutral"
    fi
}

# Проверить все эмоции агента
check_emotion() {
    local agent=$1
    local emotion=$(get_emotion "$agent")
    local intensity=$(grep "INTENSITY=" "$EMOTION_DIR/moods/$agent.txt" 2>/dev/null | cut -d'=' -f2 | cut -d'|' -f1)
    echo "[EMOTION] $agent: $emotion (${EMOTIONS[$emotion]}) [${intensity:-5}/10]"
}

# Отношения между агентами
set_relationship() {
    local agent1=$1; local agent2=$2; local relation=$3
    echo "$agent1|$agent2|$relation|$(date +%s)" > "$EMOTION_DIR/relationships/${agent1}_${agent2}.txt"
    echo "[EMOTION] 🤝 $agent1 → $agent2: $relation"
}

# Реакция на событие
react_to_event() {
    local agent=$1; local event=$2
    case "$event" in
        success) set_emotion "$agent" "confident" 8; set_emotion "$agent" "aggressive" 7; echo "[EMOTION] 😤 $agent: Успех! Становлюсь агрессивнее" ;;
        block)   set_emotion "$agent" "vengeful" 9; echo "[EMOTION] 💢 $agent: Блокировка! Буду мстить" ;;
        detect)  set_emotion "$agent" "fearful" 6; set_emotion "$agent" "cautious" 8; echo "[EMOTION] 😨 $agent: Детект! Прячусь" ;;
        timeout) set_emotion "$agent" "curious" 5; echo "[EMOTION] 🤔 $agent: Таймаут... Исследую" ;;
        kill)    set_emotion "$agent" "vengeful" 10; echo "[EMOTION] 💀 $agent: Убит! Призрак будет мстить" ;;
        love)    set_emotion "$agent" "playful" 9; echo "[EMOTION] 💕 $agent: Влюблён! Экспериментирую" ;;
    esac
}

echo "[EMOTION] ✅ EMOTION активно (полная версия: 8 эмоций, отношения, реакции)"
