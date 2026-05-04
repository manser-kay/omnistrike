#!/bin/bash
MEMORY_DIR="$HOME/.shadow_memory"
mkdir -p "$MEMORY_DIR/experiences" "$MEMORY_DIR/skills" "$MEMORY_DIR/lessons"

learn() {
    local agent=$1; local skill=$2
    echo "SKILL=$skill|LEARNED=$(date +%s)" >> "$MEMORY_DIR/skills/$agent.txt"
    echo "[MEMORY] 🧠 $agent изучил: $skill"
}

remember() {
    local agent=$1; local event=$2
    echo "EVENT=$event|TIME=$(date +%s)" >> "$MEMORY_DIR/experiences/$agent.txt"
    echo "[MEMORY] 📝 $agent запомнил: $event"
}

experience_level() {
    local agent=$1
    local exp=$(wc -l < "$MEMORY_DIR/experiences/$agent.txt" 2>/dev/null || echo 0)
    echo "[MEMORY] 📊 $agent: опыт = $exp"
}
echo "[MEMORY] ✅ MEMORY активно (полная версия)"
