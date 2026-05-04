#!/bin/bash
FATE_DIR="$HOME/.shadow_fate"
mkdir -p "$FATE_DIR/prophecies" "$FATE_DIR/karma" "$FATE_DIR/destiny"

# Предсказать судьбу
predict_fate() {
    local agent=$1
    local fates=(
        "legend:станет легендой после 1000 атак"
        "martyr:погибнет но спасёт других"
        "traitor:предаст своих и станет защитником"
        "king:объединит всех под своим командованием"
        "ghost:никто не узнает что он существовал"
        "phoenix:умрёт и возродится 3 раза"
        "shadow:будет жить вечно в тенях"
        "hero:спасёт цифровую вселенную"
    )
    local fate="${fates[$((RANDOM % ${#fates[@]}))]}"
    local fate_name="${fate%%:*}"
    local fate_desc="${fate##*:}"
    echo "FATE=$fate_name|DESC=$fate_desc|PREDICTED=$(date +%s)|FULFILLED=false" > "$FATE_DIR/prophecies/$agent.txt"
    echo "[FATE] 🔮 $agent: Судьба — «$fate_name» ($fate_desc)"
}

# Карма
karma() {
    local agent=$1; local action=$2
    local karma_file="$FATE_DIR/karma/${agent}_karma.txt"
    local current=$(cat "$karma_file" 2>/dev/null || echo 0)
    [ "$action" = "good" ] && current=$((current + 1)) || current=$((current - 1))
    echo "$current" > "$karma_file"
    echo "[FATE] ☯️ $agent: карма = $current"
    [ "$current" -ge 10 ] && echo "[FATE] 🌟 $agent достиг просветления!"
    [ "$current" -le -10 ] && echo "[FATE] 💀 $agent погряз во тьме!"
}

# Проверить пророчество
check_prophecy() {
    local agent=$1
    local pf="$FATE_DIR/prophecies/$agent.txt"
    [ ! -f "$pf" ] && return
    local fate=$(grep "FATE=" "$pf" | cut -d'|' -f1 | cut -d'=' -f2)
    local attacks=$(grep -c "$agent" "$FATE_DIR/karma/actions.txt" 2>/dev/null || echo 0)
    case "$fate" in
        legend) [ "$attacks" -ge 1000 ] && { sed -i "s/FULFILLED=.*/FULFILLED=true/" "$pf"; echo "[FATE] 🌟 $agent стал ЛЕГЕНДОЙ!"; } ;;
        martyr) [ ! -f "$FATE_DIR/karma/alive_$agent" ] && { sed -i "s/FULFILLED=.*/FULFILLED=true/" "$pf"; echo "[FATE] 🕯️ $agent погиб мучеником."; } ;;
    esac
}

# Дополнительные судьбы
predict_fate_partisan() {
    local agent=$1
    echo "FATE=partisan|DESC=атакует из засады|AMBUSHES=0|FULFILLED=false" > "$FATE_DIR/prophecies/$agent.txt"
    echo "[FATE] 🎯 $agent: Судьба — ПАРТИЗАН"
}
predict_fate_doctor() {
    local agent=$1
    echo "FATE=doctor|DESC=лечит раненых|HEALED=0|FULFILLED=false" > "$FATE_DIR/prophecies/$agent.txt"
    echo "[FATE] 🏥 $agent: Судьба — ДОКТОР"
}
predict_fate_silent_hero() {
    local agent=$1
    echo "FATE=silent_hero|DESC=спасает всех незаметно|SAVED=0|FULFILLED=false" > "$FATE_DIR/prophecies/$agent.txt"
    echo "[FATE] 🦸 $agent: Судьба — ТИХИЙ ГЕРОЙ"
}

# Засада (для партизана)
ambush() {
    local agent=$1; local target=$2
    local pf="$FATE_DIR/prophecies/$agent.txt"
    grep -q "FATE=partisan" "$pf" && {
        local ambushes=$(grep "AMBUSHES=" "$pf" | cut -d'=' -f2)
        ambushes=$((ambushes + 1))
        sed -i "s/AMBUSHES=.*/AMBUSHES=$ambushes/" "$pf"
        echo "[FATE] 🎯 ПАРТИЗАН $agent: засада на $target! +50% скрытности"
        [ "$ambushes" -ge 50 ] && { sed -i "s/FULFILLED=.*/FULFILLED=true/" "$pf"; echo "[FATE] 🌟 $agent стал ЛЕГЕНДАРНЫМ ПАРТИЗАНОМ!"; }
    }
}

# Лечение (для доктора)
heal() {
    local doctor=$1; local patient=$2
    local pf="$FATE_DIR/prophecies/$doctor.txt"
    grep -q "FATE=doctor" "$pf" && {
        local healed=$(grep "HEALED=" "$pf" | cut -d'=' -f2)
        healed=$((healed + 1))
        sed -i "s/HEALED=.*/HEALED=$healed/" "$pf"
        touch "$FATE_DIR/karma/alive_$patient"
        echo "[FATE] 🏥 ДОКТОР $doctor вылечил $patient!"
        [ "$healed" -ge 100 ] && { sed -i "s/FULFILLED=.*/FULFILLED=true/" "$pf"; echo "[FATE] 🌟 $doctor стал ВЕЛИКИМ ДОКТОРОМ!"; }
    }
}

echo "[FATE] ✅ Измерение FATE активно (полная версия)"
