#!/bin/bash
NEXUS_DIR="$HOME/.shadow_nexus"
MSG_BUS="$NEXUS_DIR/msg_bus"
mkdir -p "$MSG_BUS"

nexus_send() {
    local from=$1; local to=$2; local msg=$3
    echo "FROM=$from|TO=$to|MSG=$msg|TIME=$(date +%s)" > "$MSG_BUS/msg_$(date +%s)_$RANDOM.txt"
    echo "[NEXUS] ✉️ $from -> $to: $msg"
}

nexus_broadcast() {
    local from=$1; local msg=$2
    for dim in "$HOME/.shadow_"*; do
        [ -d "$dim" ] && nexus_send "$from" "$(basename "$dim")" "$msg"
    done
    echo "[NEXUS] 📡 Широковещательное от $from"
}

nexus_check() {
    local for_dim=$1
    echo "[NEXUS] 📬 Сообщения для $for_dim:"
    grep -l "TO=$for_dim" "$MSG_BUS/"*.txt 2>/dev/null | while read f; do
        echo "  📩 $(cat "$f")"
        rm "$f"
    done
}

echo "[NEXUS] ✅ NEXUS активно (полная версия)"
