#!/bin/bash
GENESIS_DIR="$HOME/.shadow_genesis"
mkdir -p "$GENESIS_DIR/dna" "$GENESIS_DIR/births" "$GENESIS_DIR/mutations" "$GENESIS_DIR/population"

create_agent() {
    local name=$1; local type=$2
    local dna="DNA_${type}_$(date +%s)_$RANDOM"
    echo "NAME=$name|TYPE=$type|DNA=$dna|BORN=$(date +%s)|GENERATION=1|STATUS=alive" > "$GENESIS_DIR/births/$name.txt"
    echo "$name" >> "$GENESIS_DIR/population/alive.txt"
    echo "[GENESIS] 🧬 Рождён агент: $name ($type)"
}

mutate() {
    local agent=$1; local mutation=$2
    echo "MUTATION=$mutation|TIME=$(date +%s)" >> "$GENESIS_DIR/mutations/$agent.txt"
    echo "[GENESIS] 🧪 Мутация $agent: $mutation"
}

kill_agent() {
    local agent=$1; local cause=$2
    sed -i "s/STATUS=alive/STATUS=dead/" "$GENESIS_DIR/births/$agent.txt" 2>/dev/null
    sed -i "/^$agent$/d" "$GENESIS_DIR/population/alive.txt" 2>/dev/null
    echo "[GENESIS] 💀 $agent умер: $cause"
}

population() {
    local alive=$(wc -l < "$GENESIS_DIR/population/alive.txt" 2>/dev/null || echo 0)
    local born=$(ls "$GENESIS_DIR/births/"*.txt 2>/dev/null | wc -l)
    echo "[GENESIS] 🌍 Популяция: $alive живых | Рождено: $born"
}

echo "[GENESIS] ✅ GENESIS активно (полная версия)"
