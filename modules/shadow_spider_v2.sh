#!/bin/bash
echo "[SPIDER v2] Network mapping + live hosts..."

SUBNET=$(ip route 2>/dev/null | grep -oP 'src \K[\d.]+' | head -1 | cut -d. -f1-3)
[ -z "$SUBNET" ] && SUBNET="192.168.1"

# ARP таблица
echo "[SPIDER] ARP table:"
arp -a 2>/dev/null

# Живые хосты
echo "[SPIDER] Live hosts in $SUBNET.0/24:"
for i in {1..254}; do
    (ping -c1 -W1 "$SUBNET.$i" >/dev/null 2>&1 && echo "  🟢 $SUBNET.$i") &
done
wait

# Поиск веб-серверов
echo "[SPIDER] Web servers:"
for i in {1..254}; do
    (curl -sk --max-time 2 "http://$SUBNET.$i" -o /dev/null -w "  🌐 $SUBNET.$i → HTTP %{http_code}\n" 2>/dev/null) &
done
wait
