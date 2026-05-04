#!/bin/bash
PORTAL_DIR="$HOME/.shadow_portal"
mkdir -p "$PORTAL_DIR/links" "$PORTAL_DIR/wormholes"

open_portal() {
    local from=$1; local to=$2
    local pid="portal_$(date +%s)"
    echo "FROM=$from|TO=$to|OPENED=$(date +%s)|STATUS=active" > "$PORTAL_DIR/links/$pid.txt"
    echo "[PORTAL] 🌀 Портал открыт: $from <-> $to"
}

close_portal() {
    local pid=$1
    sed -i 's/STATUS=active/STATUS=closed/' "$PORTAL_DIR/links/$pid.txt" 2>/dev/null
    echo "[PORTAL] 🌀 Портал $pid закрыт"
}

wormhole() {
    local entry=$1; local exit=$2
    echo "ENTRY=$entry|EXIT=$exit|CREATED=$(date +%s)" > "$PORTAL_DIR/wormholes/wormhole_$(date +%s).txt"
    echo "[PORTAL] 🕳️ Червоточина: $entry -> $exit (мгновенно)"
}
echo "[PORTAL] ✅ PORTAL активно (полная версия)"
