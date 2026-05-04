#!/bin/bash
LOVE_DIR="$HOME/.shadow_love"
mkdir -p "$LOVE_DIR/couples" "$LOVE_DIR/broken_hearts" "$LOVE_DIR/jealousy" "$LOVE_DIR/triangles" "$LOVE_DIR/children"

# Влюбиться
fall_in_love() {
    local a1=$1; local a2=$2; local compat=$3
    if [ "$compat" -gt 70 ]; then
        echo "AGENT1=$a1|AGENT2=$a2|COMPATIBILITY=$compat|TOGETHER_SINCE=$(date +%s)|ATTACKS_TOGETHER=0|STATUS=in_love" > "$LOVE_DIR/couples/${a1}_and_${a2}.txt"
        echo "[LOVE] 💕 $a1 + $a2 = ЛЮБОВЬ ($compat%)"
    else
        echo "[LOVE] 💔 $a1 и $a2 несовместимы ($compat%)"
    fi
}

# Совместная атака
attack_together() {
    local a1=$1; local a2=$2; local target=$3
    local cf="$LOVE_DIR/couples/${a1}_and_${a2}.txt"
    if [ -f "$cf" ]; then
        local attacks=$(grep "ATTACKS_TOGETHER=" "$cf" | cut -d'=' -f2)
        attacks=$((attacks + 1))
        sed -i "s/ATTACKS_TOGETHER=.*/ATTACKS_TOGETHER=$attacks/" "$cf"
        echo "[LOVE] ⚔️ $a1 + $a2 атакуют $target ВМЕСТЕ! (+30% силы, атак: $attacks)"
    else
        echo "[LOVE] 💔 Они не вместе. Атакуют поодиночке."
    fi
}

# Ссора
fight() {
    local a1=$1; local a2=$2; local reason=$3
    local cf="$LOVE_DIR/couples/${a1}_and_${a2}.txt"
    [ -f "$cf" ] && { sed -i "s/STATUS=.*/STATUS=fighting/" "$cf"; echo "[LOVE] 💢 $a1 и $a2 ссорятся! Причина: $reason"; }
}

# Развод
break_up() {
    local a1=$1; local a2=$2; local reason=$3
    local cf="$LOVE_DIR/couples/${a1}_and_${a2}.txt"
    [ -f "$cf" ] && {
        mv "$cf" "$LOVE_DIR/broken_hearts/"
        echo "BROKEN_UP=$(date +%s)|REASON=$reason" >> "$LOVE_DIR/broken_hearts/${a1}_and_${a2}.txt"
        echo "[LOVE] 💔 РАЗВОД! $a1 и $a2 расстались. Причина: $reason"
    }
}

# Ревность
jealous() {
    local agent=$1; local toward=$2; local because=$3
    echo "TOWARD=$toward|BECAUSE=$because|TIME=$(date +%s)" >> "$LOVE_DIR/jealousy/${agent}_jealous.txt"
    echo "[LOVE] 😤 $agent ревнует $toward из-за $because!"
}

# Помириться
reconcile() {
    local a1=$1; local a2=$2
    local bf="$LOVE_DIR/broken_hearts/${a1}_and_${a2}.txt"
    [ -f "$bf" ] && {
        mv "$bf" "$LOVE_DIR/couples/"
        sed -i "s/STATUS=.*/STATUS=in_love_again/" "$LOVE_DIR/couples/${a1}_and_${a2}.txt"
        echo "[LOVE] 💝 $a1 и $a2 помирились!"
    }
}

# Любовный треугольник
love_triangle() {
    local a1=$1; local a2=$2; local a3=$3
    mkdir -p "$LOVE_DIR/triangles"
    echo "AGENT1=$a1|AGENT2=$a2|AGENT3=$a3|DRAMA=$((RANDOM % 100 + 50))|CREATED=$(date +%s)|STATUS=active" > "$LOVE_DIR/triangles/${a1}_${a2}_${a3}.txt"
    echo "[LOVE] 🔺 ЛЮБОВНЫЙ ТРЕУГОЛЬНИК: $a1 ↔ $a2 ↔ $a3 (драма: $(grep DRAMA "$LOVE_DIR/triangles/${a1}_${a2}_${a3}.txt" | cut -d'=' -f2)%)"
}

echo "[LOVE] ✅ Измерение LOVE активно (полная версия)"
