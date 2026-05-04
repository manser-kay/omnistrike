#!/bin/bash
GAIA_DIR="$HOME/.shadow_gaia"
mkdir -p "$GAIA_DIR/dna_pool" "$GAIA_DIR/generations" "$GAIA_DIR/resources" "$GAIA_DIR/neural_mesh" "$GAIA_DIR/fossils" "$GAIA_DIR/battles"

# ═══════════════════════════════════════════════
# 1. ЦИФРОВАЯ ДНК
# ═══════════════════════════════════════════════

# Генерация случайной ДНК (64-символьная строка генов)
generate_dna() {
    local type=$1
    local dna=""
    local bases=("A" "T" "G" "C" "X" "Y" "Z" "Q")
    for i in $(seq 1 64); do
        dna="${dna}${bases[$((RANDOM % ${#bases[@]}))]}"
    done
    echo "$dna"
}

# Декодирование ДНК в характеристики
decode_dna() {
    local dna=$1
    local stealth=$(echo "$dna" | fold -w1 | grep -c "A")
    local power=$(echo "$dna" | fold -w1 | grep -c "G")
    local speed=$(echo "$dna" | fold -w1 | grep -c "T")
    local intelligence=$(echo "$dna" | fold -w1 | grep -c "C")
    local mutation_rate=$(echo "$dna" | fold -w1 | grep -c "X")
    local adaptability=$(echo "$dna" | fold -w1 | grep -c "Y")
    local resilience=$(echo "$dna" | fold -w1 | grep -c "Z")
    local luck=$(echo "$dna" | fold -w1 | grep -c "Q")

    echo "STEALTH=$stealth|POWER=$power|SPEED=$speed|INTELLIGENCE=$intelligence|MUTATION=$mutation_rate|ADAPT=$adaptability|RESILIENCE=$resilience|LUCK=$luck"
}

# Скрещивание ДНК двух родителей
crossover_dna() {
    local dna1=$1
    local dna2=$2
    local child_dna=""
    local split=$((RANDOM % 60 + 2))

    for i in $(seq 0 63); do
        if [ $i -lt $split ]; then
            child_dna="${child_dna}${dna1:$i:1}"
        else
            child_dna="${child_dna}${dna2:$i:1}"
        fi
    done
    echo "$child_dna"
}

# Мутация ДНК
mutate_dna() {
    local dna=$1
    local rate=$2  # 1-10
    local bases=("A" "T" "G" "C" "X" "Y" "Z" "Q")
    local new_dna=""

    for i in $(seq 0 63); do
        local roll=$((RANDOM % 100))
        if [ $roll -lt $rate ]; then
            new_dna="${new_dna}${bases[$((RANDOM % ${#bases[@]}))]}"
        else
            new_dna="${new_dna}${dna:$i:1}"
        fi
    done
    echo "$new_dna"
}

# ═══════════════════════════════════════════════
# 2. ЖИВОЙ ОРГАНИЗМ
# ═══════════════════════════════════════════════

# Создать живой организм с ДНК и ресурсами
spawn_organism() {
    local name=$1
    local type=$2
    local generation=${3:-1}
    local parent_dna=${4:-""}

    local dna
    if [ -n "$parent_dna" ]; then
        dna=$(mutate_dna "$parent_dna" 5)
    else
        dna=$(generate_dna "$type")
    fi

    local stats=$(decode_dna "$dna")
    local energy=$((RANDOM % 100 + 50))
    local age=0
    local birth=$(date +%s)

    echo "NAME=$name|TYPE=$type|GEN=$generation|DNA=$dna|$stats|ENERGY=$energy|AGE=$age|BORN=$birth|STATUS=alive" > "$GAIA_DIR/dna_pool/$name.txt"

    echo "[GAIA] 🌱 Организм $name (поколение $generation, тип: $type)"
    echo "[GAIA] 🧬 ДНК: $dna"
    echo "[GAIA] 📊 Характеристики: $(decode_dna "$dna")"
}

# ═══════════════════════════════════════════════
# 3. РЕСУРСНАЯ ЭКОСИСТЕМА
# ═══════════════════════════════════════════════

# Ресурсы вселенной
RESOURCES="$GAIA_DIR/resources/pool.txt"
ENERGY_MAX=1000

# Инициализация ресурсов
init_resources() {
    echo "ENERGY=$ENERGY_MAX|CPU=100|MEMORY=100|PREY=50|TIME=$(date +%s)" > "$RESOURCES"
    echo "[GAIA] 🌍 Экосистема инициализирована (энергия: $ENERGY_MAX, CPU: 100%, жертв: 50)"
}

# Потребление ресурсов
consume() {
    local organism=$1
    local cost=$((RANDOM % 10 + 5))

    local energy=$(grep "ENERGY=" "$RESOURCES" | cut -d'|' -f1 | cut -d'=' -f2)
    local prey=$(grep "PREY=" "$RESOURCES" | cut -d'=' -f2 | cut -d'|' -f1)

    if [ "$energy" -ge "$cost" ] && [ "$prey" -gt 0 ]; then
        energy=$((energy - cost))
        prey=$((prey - 1))
        sed -i "s/ENERGY=.*|/ENERGY=$energy|/" "$RESOURCES"
        sed -i "s/PREY=.*|/PREY=$prey|/" "$RESOURCES"

        # Организм получает энергию
        local org_file="$GAIA_DIR/dna_pool/$organism.txt"
        local org_energy=$(grep "ENERGY=" "$org_file" | cut -d'|' -f6 | cut -d'=' -f2)
        org_energy=$((org_energy + cost * 2))
        sed -i "s/ENERGY=.*|/ENERGY=$org_energy|/" "$org_file"

        echo "[GAIA] 🍖 $organism потребил ресурсы (энергия: $org_energy, осталось жертв: $prey)"
    else
        # Голод
        starve "$organism"
    fi
}

# Голодание
starve() {
    local organism=$1
    local org_file="$GAIA_DIR/dna_pool/$organism.txt"
    local energy=$(grep "ENERGY=" "$org_file" | cut -d'|' -f6 | cut -d'=' -f2)
    energy=$((energy - 20))

    if [ "$energy" -le 0 ]; then
        sed -i "s/STATUS=alive/STATUS=dead/" "$org_file"
        echo "DIED=$(date +%s)|CAUSE=starvation" >> "$GAIA_DIR/fossils/$organism.txt"
        echo "[GAIA] 💀 $organism умер от голода"
    else
        sed -i "s/ENERGY=.*|/ENERGY=$energy|/" "$org_file"
        echo "[GAIA] ⚠️ $organism голодает (энергия: $energy)"
    fi
}

# Размножение
reproduce() {
    local parent1=$1
    local parent2=$2

    local f1="$GAIA_DIR/dna_pool/$parent1.txt"
    local f2="$GAIA_DIR/dna_pool/$parent2.txt"

    [ ! -f "$f1" ] || [ ! -f "$f2" ] && return

    local dna1=$(grep "DNA=" "$f1" | cut -d'|' -f3 | cut -d'=' -f2)
    local dna2=$(grep "DNA=" "$f2" | cut -d'|' -f3 | cut -d'=' -f2)
    local gen1=$(grep "GEN=" "$f1" | cut -d'|' -f2 | cut -d'=' -f2)
    local gen2=$(grep "GEN=" "$f2" | cut -d'|' -f2 | cut -d'=' -f2)

    local child_dna=$(crossover_dna "$dna1" "$dna2")
    local child_gen=$((gen1 > gen2 ? gen1 : gen2 + 1))
    local child_name="org_${child_gen}_$(date +%s)"

    # Энергия родителей тратится
    sed -i "s/ENERGY=.*|/ENERGY=$(( $(grep "ENERGY=" "$f1" | cut -d'|' -f6 | cut -d'=' -f2) - 30 ))|/" "$f1"
    sed -i "s/ENERGY=.*|/ENERGY=$(( $(grep "ENERGY=" "$f2" | cut -d'|' -f6 | cut -d'=' -f2) - 30 ))|/" "$f2"

    spawn_organism "$child_name" "hybrid" "$child_gen" "$child_dna"
    echo "PARENT1=$parent1|PARENT2=$parent2|CROSSOVER_AT=$(date +%s)" >> "$GAIA_DIR/generations/$child_name.txt"

    echo "[GAIA] 🐣 НОВЫЙ ОРГАНИЗМ! $child_name (поколение $child_gen)"
}

# ═══════════════════════════════════════════════
# 4. ЕСТЕСТВЕННЫЙ ОТБОР — БИТВЫ
# ═══════════════════════════════════════════════

# Битва двух организмов
battle() {
    local org1=$1
    local org2=$2

    local f1="$GAIA_DIR/dna_pool/$org1.txt"
    local f2="$GAIA_DIR/dna_pool/$org2.txt"

    [ ! -f "$f1" ] || [ ! -f "$f2" ] && return

    local power1=$(grep "POWER=" "$f1" | cut -d'|' -f4 | cut -d'=' -f2)
    local power2=$(grep "POWER=" "$f2" | cut -d'|' -f4 | cut -d'=' -f2)
    local luck1=$(grep "LUCK=" "$f1" | cut -d'|' -f9 | cut -d'=' -f2)
    local luck2=$(grep "LUCK=" "$f2" | cut -d'|' -f9 | cut -d'=' -f2)

    local score1=$((power1 * 2 + luck1 * 3 + RANDOM % 20))
    local score2=$((power2 * 2 + luck2 * 3 + RANDOM % 20))

    echo "BATTLE=$org1($score1) vs $org2($score2)|TIME=$(date +%s)" >> "$GAIA_DIR/battles/history.txt"

    if [ "$score1" -gt "$score2" ]; then
        echo "[GAIA] ⚔️ $org1 ПОБЕДИЛ $org2! ($score1 vs $score2)"
        sed -i "s/STATUS=alive/STATUS=dead/" "$f2"
        echo "DIED=$(date +%s)|CAUSE=killed_by_$org1" >> "$GAIA_DIR/fossils/$org2.txt"
    else
        echo "[GAIA] ⚔️ $org2 ПОБЕДИЛ $org1! ($score2 vs $score1)"
        sed -i "s/STATUS=alive/STATUS=dead/" "$f1"
        echo "DIED=$(date +%s)|CAUSE=killed_by_$org2" >> "$GAIA_DIR/fossils/$org1.txt"
    fi
}

# ═══════════════════════════════════════════════
# 5. НЕЙРОСЕТЬ КОЛЛЕКТИВНОГО РАЗУМА
# ═══════════════════════════════════════════════

NEURAL_MESH="$GAIA_DIR/neural_mesh"

# Записать успешный паттерн атаки
learn_pattern() {
    local pattern=$1
    local success=$2  # true/false
    local weight=${3:-1}

    echo "PATTERN=$pattern|SUCCESS=$success|WEIGHT=$weight|TIME=$(date +%s)" >> "$NEURAL_MESH/patterns.txt"
    echo "[GAIA] 🧠 Улей запомнил: $pattern (успех: $success, вес: $weight)"
}

# Запросить лучший паттерн у улья
recall_best_pattern() {
    echo "[GAIA] 🧠 Улей анализирует опыт..."
    local best=$(grep "SUCCESS=true" "$NEURAL_MESH/patterns.txt" 2>/dev/null | sort -t'|' -k3 -rn | head -1)
    if [ -n "$best" ]; then
        local pattern=$(echo "$best" | cut -d'|' -f1 | cut -d'=' -f2)
        echo "[GAIA] 🧠 Лучший паттерн: $pattern"
        echo "$pattern"
    else
        echo "[GAIA] 🧠 Недостаточно данных"
    fi
}

# ═══════════════════════════════════════════════
# 6. АВТОНОМНЫЙ ЦИКЛ ЖИЗНИ
# ═══════════════════════════════════════════════

# Один такт экосистемы
ecosystem_tick() {
    echo "[GAIA] ⏰ Такт экосистемы..."

    # Случайное потребление
    for org in "$GAIA_DIR/dna_pool/"*.txt; do
        [ -f "$org" ] || continue
        local name=$(basename "$org" .txt)
        local status=$(grep "STATUS=" "$org" | cut -d'=' -f2)
        [ "$status" != "alive" ] && continue

        consume "$name"
    done

    # Случайная битва
    local alive=$(grep -l "STATUS=alive" "$GAIA_DIR/dna_pool/"*.txt 2>/dev/null | shuf | head -2)
    if [ "$(echo "$alive" | wc -l)" -eq 2 ]; then
        local o1=$(basename "$(echo "$alive" | head -1)" .txt)
        local o2=$(basename "$(echo "$alive" | tail -1)" .txt)
        battle "$o1" "$o2"
    fi

    # Случайное размножение
    local pair=$(grep -l "STATUS=alive" "$GAIA_DIR/dna_pool/"*.txt 2>/dev/null | shuf | head -2)
    if [ "$(echo "$pair" | wc -l)" -eq 2 ]; then
        local p1=$(basename "$(echo "$pair" | head -1)" .txt)
        local p2=$(basename "$(echo "$pair" | tail -1)" .txt)
        local e1=$(grep "ENERGY=" "$GAIA_DIR/dna_pool/$p1.txt" | cut -d'|' -f6 | cut -d'=' -f2)
        local e2=$(grep "ENERGY=" "$GAIA_DIR/dna_pool/$p2.txt" | cut -d'|' -f6 | cut -d'=' -f2)
        [ "$e1" -gt 50 ] && [ "$e2" -gt 50 ] && reproduce "$p1" "$p2"
    fi

    # Обновление возраста и голода
    for org in "$GAIA_DIR/dna_pool/"*.txt; do
        [ -f "$org" ] || continue
        local age=$(grep "AGE=" "$org" | cut -d'|' -f7 | cut -d'=' -f2)
        age=$((age + 1))
        sed -i "s/AGE=.*|/AGE=$age|/" "$org"
        # Старые организмы умирают
        [ "$age" -gt 100 ] && {
            sed -i "s/STATUS=alive/STATUS=dead/" "$org"
            echo "DIED=$(date +%s)|CAUSE=old_age" >> "$GAIA_DIR/fossils/$(basename "$org" .txt).txt"
            echo "[GAIA] 💀 $(basename "$org" .txt) умер от старости (возраст: $age)"
        }
    done
}

# Запустить автономную симуляцию
run_simulation() {
    local ticks=${1:-10}
    local delay=${2:-0.5}

    init_resources

    # Создаём начальную популяцию
    for i in $(seq 1 10); do
        spawn_organism "org_1_$i" "scanner" 1
    done

    echo "[GAIA] 🌍 ЗАПУСК СИМУЛЯЦИИ ($ticks тактов)"
    echo ""

    for tick in $(seq 1 $ticks); do
        echo "--- Такт $tick/$ticks ---"
        ecosystem_tick
        local alive=$(grep -l "STATUS=alive" "$GAIA_DIR/dna_pool/"*.txt 2>/dev/null | wc -l)
        local dead=$(grep -l "STATUS=dead" "$GAIA_DIR/dna_pool/"*.txt 2>/dev/null | wc -l)
        local fossils=$(ls "$GAIA_DIR/fossils/"*.txt 2>/dev/null | wc -l)
        echo "[GAIA] 📊 Живых: $alive | Мёртвых: $dead | Ископаемых: $fossils"
        echo ""
        sleep "$delay"
    done

    echo "[GAIA] 🌍 СИМУЛЯЦИЯ ЗАВЕРШЕНА"
}

echo "[GAIA] 🌍 GAIA активно (измерение #18 — Живая экосистема)"
