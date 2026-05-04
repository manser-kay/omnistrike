#!/bin/bash
# Живая карта v2.0 — отслеживает изменения в сети
MAP_DIR="$HOME/.shadow_map"
mkdir -p "$MAP_DIR"

echo "[MAP v2] Запускаю мониторинг сети..."

while true; do
    TIMESTAMP=$(date +%H:%M:%S)
    echo "=== $TIMESTAMP ===" >> "$MAP_DIR/live.log"
    
    # ARP-таблица
    arp -a 2>/dev/null >> "$MAP_DIR/live.log"
    
    # Новые устройства (сравниваем с предыдущим снимком)
    arp -a 2>/dev/null | grep -oP '\(\K[\d.]+' > "$MAP_DIR/current_hosts.txt"
    if [ -f "$MAP_DIR/prev_hosts.txt" ]; then
        NEW=$(comm -13 "$MAP_DIR/prev_hosts.txt" "$MAP_DIR/current_hosts.txt" 2>/dev/null)
        GONE=$(comm -23 "$MAP_DIR/prev_hosts.txt" "$MAP_DIR/current_hosts.txt" 2>/dev/null)
        [ -n "$NEW" ] && echo "  🟢 Новые: $NEW" | tee -a "$MAP_DIR/live.log"
        [ -n "$GONE" ] && echo "  🔴 Исчезли: $GONE" | tee -a "$MAP_DIR/live.log"
    fi
    mv "$MAP_DIR/current_hosts.txt" "$MAP_DIR/prev_hosts.txt" 2>/dev/null
    
    clear
    echo "[MAP v2] $(date)"
    tail -10 "$MAP_DIR/live.log"
    sleep 30
done
