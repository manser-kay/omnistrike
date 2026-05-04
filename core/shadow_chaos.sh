#!/bin/bash
CHAOS_DIR="$HOME/.shadow_chaos"
mkdir -p "$CHAOS_DIR/events" "$CHAOS_DIR/probabilities"

chaos_roll() {
    local event=$1; local prob=$2
    local roll=$((RANDOM % 100 + 1))
    if [ "$roll" -le "$prob" ]; then
        echo "EVENT=$event|ROLL=$roll|RESULT=SUCCESS|TIME=$(date +%s)" >> "$CHAOS_DIR/events/$(date +%s).txt"
        echo "[CHAOS] 🎲 $event — СЛУЧИЛОСЬ! ($roll/$prob%)"
        return 0
    else
        echo "[CHAOS] ❌ $event — мимо ($roll/$prob%)"
        return 1
    fi
}

chaos_event() {
    local desc=$1
    echo "EVENT=$desc|TIME=$(date +%s)" >> "$CHAOS_DIR/events/$(date +%s).txt"
    echo "[CHAOS] 📝 Событие: $desc"
}

black_swan() {
    chaos_roll "ЧЁРНЫЙ ЛЕБЕДЬ — непредсказуемое событие" 1 && {
        echo "[CHAOS] 🦢 ЧЁРНЫЙ ЛЕБЕДЬ! Вселенная изменилась!"
    }
}
echo "[CHAOS] ✅ CHAOS активно (полная версия)"
