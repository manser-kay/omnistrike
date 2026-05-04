#!/bin/bash
# Живая разведка — карта сети в реальном времени
MAP_DIR="$HOME/.shadow_map"
mkdir -p "$MAP_DIR"

echo "[LIVE-RECON] Мониторинг сети..."

while true; do
    TIMESTAMP=$(date +%H:%M:%S)
    
    # Текущие хосты
    arp -a 2>/dev/null | grep -oP '\(\K[\d.]+' > "$MAP_DIR/current.txt"
    
    # Новые хосты
    if [ -f "$MAP_DIR/previous.txt" ]; then
        NEW=$(comm -13 "$MAP_DIR/previous.txt" "$MAP_DIR/current.txt" 2>/dev/null)
        GONE=$(comm -23 "$MAP_DIR/previous.txt" "$MAP_DIR/current.txt" 2>/dev/null)
        [ -n "$NEW" ] && echo "🟢 $TIMESTAMP NEW: $NEW"
        [ -n "$GONE" ] && echo "🔴 $TIMESTAMP GONE: $GONE"
    fi
    
    mv "$MAP_DIR/current.txt" "$MAP_DIR/previous.txt" 2>/dev/null
    
    # Открытые порты на новых хостах
    for ip in $NEW; do
        for port in 22 80 443 445 3389 8080; do
            timeout 1 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null && echo "  📡 $ip:$port"
        done
    done
    
    sleep 10
done
