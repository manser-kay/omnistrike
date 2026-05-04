#!/bin/bash
# SHADOW NET — Теневая сеть из заражённых узлов
# Каждый узел становится частью распределённой инфраструктуры

NET_DIR="$HOME/.shadow_net"
mkdir -p "$NET_DIR/nodes" "$NET_DIR/tunnels" "$NET_DIR/data"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — SHADOW NET                 ║"
echo "║   Теневая сеть                              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Регистрация узла
register_node() {
    local ip=$1
    local role=$2
    
    echo "IP=$ip|ROLE=$role|SINCE=$(date +%s)|STATUS=active" > "$NET_DIR/nodes/$ip.txt"
    echo "[NET] 🔗 Узел $ip ($role) подключён"
}

# Создание туннеля между узлами
create_tunnel() {
    local from=$1
    local to=$2
    local port=$3
    
    echo "FROM=$from|TO=$to|PORT=$port|CREATED=$(date +%s)" > "$NET_DIR/tunnels/${from}_${to}.txt"
    echo "[NET] 🚇 Туннель: $from → $to:$port"
}

# Поиск соседей
discover_nodes() {
    local subnet=$1
    
    for i in $(seq 1 254); do
        local ip="$subnet.$i"
        (ping -c1 -W1 "$ip" >/dev/null 2>&1 && echo "  🔍 Найден: $ip") &
    done
    wait
}

# Демонстрация
MY_IP=$(ip route 2>/dev/null | grep -oP 'src \K[\d.]+' | head -1)
[ -z "$MY_IP" ] && MY_IP="127.0.0.1"
SUBNET=$(echo "$MY_IP" | cut -d. -f1-3)

echo "[NET] Мой IP: $MY_IP"
register_node "$MY_IP" "relay"

echo "[NET] Сканирую сеть $SUBNET.0/24..."
discover_nodes "$SUBNET"

echo "[NET] Теневая сеть готова"
