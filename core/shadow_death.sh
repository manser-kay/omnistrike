#!/bin/bash
DEATH_DIR="$HOME/.shadow_death"
mkdir -p "$DEATH_DIR/graveyard" "$DEATH_DIR/ghosts" "$DEATH_DIR/whispers" "$DEATH_DIR/rebirth"

# Похоронить
bury() {
    local name=$1; local cause=$2; local legacy=$3
    echo "NAME=$name|CAUSE=$cause|LEGACY=$legacy|DIED=$(date +%s)" > "$DEATH_DIR/graveyard/${name}_$(date +%s).txt"
    echo "[DEATH] ⚰️ $name похоронен. Причина: $cause. Наследие: $legacy"
    create_ghost "$name" "$legacy"
}

# Создать призрака
create_ghost() {
    local name=$1; local legacy=$2
    echo "GHOST_OF=$name|LEGACY=$legacy|WHISPERS=0|CREATED=$(date +%s)" > "$DEATH_DIR/ghosts/ghost_of_$name.txt"
    echo "[DEATH] 👻 Призрак $name восстал. Наследие: $legacy"
}

# Шёпот призрака
whisper() {
    local ghost=$1; local msg=$2
    echo "$msg" > "$DEATH_DIR/whispers/${ghost}_$(date +%s).txt"
    local gf="$DEATH_DIR/ghosts/ghost_of_$ghost.txt"
    [ -f "$gf" ] && {
        local w=$(grep "WHISPERS=" "$gf" | cut -d'=' -f2)
        w=$((w + 1))
        sed -i "s/WHISPERS=.*/WHISPERS=$w/" "$gf"
    }
    echo "[DEATH] 👻 Призрак $ghost шепчет: $msg"
}

# Перерождение
rebirth() {
    local old=$1; local new=$2; local strat=$3
    echo "OLD=$old|NEW=$new|STRATEGY=$strat|REBORN=$(date +%s)" > "$DEATH_DIR/rebirth/${old}_reborn_as_${new}.txt"
    echo "[DEATH] 🔄 $old переродился как $new ($strat)"
}

# Некромантия
necromancy() {
    local necro=$1; local dead=$2
    local grave=$(find "$DEATH_DIR/graveyard" -name "${dead}_*.txt" 2>/dev/null | head -1)
    [ -f "$grave" ] && {
        cp "$grave" "$DEATH_DIR/ghosts/undead_${dead}_$(date +%s).txt"
        echo "RAISED_BY=$necro|RAISED_AT=$(date +%s)|TYPE=undead_servant" >> "$DEATH_DIR/ghosts/undead_${dead}_$(date +%s).txt"
        echo "[DEATH] 💀 НЕКРОМАНТИЯ! $necro поднял $dead как нежить!"
    } || echo "[DEATH] ⚠️ $dead не найден в могилах"
}

echo "[DEATH] ✅ Измерение DEATH активно (полная версия)"
