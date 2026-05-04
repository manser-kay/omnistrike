#!/bin/bash
# Реверс-пентест — сканирую сам себя

MY_IP=$(ip route 2>/dev/null | grep -oP 'src \K[\d.]+' | head -1)
[ -z "$MY_IP" ] && MY_IP="127.0.0.1"

echo "╔══════════════════════════════════════════════╗"
echo "║   Self-Scan — что видит хакер               ║"
echo "╚══════════════════════════════════════════════╝"
echo "Твой IP: $MY_IP"
echo ""

echo "[*] Открытые порты:"
for port in 22 80 443 8080 3000 5000 6379 27017 5432 3306; do
    timeout 1 bash -c "echo >/dev/tcp/$MY_IP/$port" 2>/dev/null && echo "  🔴 $port ОТКРЫТ — хакер видит!" || echo "  🟢 $port закрыт"
done

echo ""
echo "[*] Утечка данных:"
find /data/data -name "*.db" -o -name "*.json" 2>/dev/null | head -5 | while read f; do
    echo "  📁 $f — ДОСТУПНО без root"
done

echo ""
echo "[*] WiFi сети:"
cat /data/misc/wifi/wpa_supplicant.conf 2>/dev/null | grep "ssid" | head -3

echo ""
echo "=========================================="
echo "  ВЫВОД: Хакер видит открытые порты и файлы"
echo "  Закрой ненужные порты и удали лишние права"
