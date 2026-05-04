#!/bin/bash
SUBNET=$(ip route 2>/dev/null | grep -oP 'src \K[\d.]+' | head -1 | cut -d. -f1-3)
[ -z "$SUBNET" ] && SUBNET="192.168.1"

echo "[RADAR v2] Сканирую $SUBNET.0/24..."

# База сигнатур IoT устройств
declare -A IOT_DB
IOT_DB["Hikvision"]="554:RTSP"
IOT_DB["Dahua"]="554:RTSP"
IOT_DB["MikroTik"]="2323:telnet"
IOT_DB["Foscam"]="8080:video"
IOT_DB["Boa"]="80:Server: Boa"
IOT_DB["GoAhead"]="80:Server: GoAhead"

for i in {1..10}; do
    ip="$SUBNET.$i"
    ping -c1 -W1 "$ip" >/dev/null 2>&1 || continue
    
    for device in "${!IOT_DB[@]}"; do
        port="${IOT_DB[$device]%%:*}"
        sig="${IOT_DB[$device]##*:}"
        
        if timeout 1 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null; then
            echo "  📡 $ip:$port — $device"
            
            # Проверяем дефолтные пароли
            case "$port" in
                80) for cred in "admin:admin" "admin:12345" "root:root"; do
                        code=$(curl -sk -u "$cred" -o /dev/null -w "%{http_code}" --max-time 3 "http://$ip" 2>/dev/null)
                        [ "$code" = "200" ] && echo "    🔑 ДЕФОЛТ: $cred"
                    done ;;
            esac
        fi
    done
done

echo "[RADAR v2] Сканирование завершено"
