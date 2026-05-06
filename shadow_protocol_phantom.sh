#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   🌐 PROTOCOL PHANTOM — Атака на уровне протокола          ║
# ║   TCP/IP манипуляции + BGP симуляция                       ║
# ╚══════════════════════════════════════════════════════════════╝

TARGET=${1:-"example.com"}
PHANTOM_DIR="$HOME/.shadow_protocol_phantom"
mkdir -p "$PHANTOM_DIR"

RED='\033[0;31m'; GR='\033[0;32m'; CY='\033[0;36m'; NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🌐 PROTOCOL PHANTOM — Атака на протокол   ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""

# --- Фаза 1: Реконструкция сетевого стека цели ---
echo -e "${CY}[PHANTOM] 🔍 Фаза 1: Реконструкция сети $TARGET...${NC}"

# Получаем IP цели
TARGET_IP=$(dig +short "$TARGET" 2>/dev/null | head -1)
[ -z "$TARGET_IP" ] && TARGET_IP=$(host "$TARGET" 2>/dev/null | grep "has address" | awk '{print $4}' | head -1)
echo "  🌐 IP: $TARGET_IP"

# Трассировка маршрута
echo "  📡 Трассировка маршрута:"
traceroute -m 10 "$TARGET_IP" 2>/dev/null | head -10 > "$PHANTOM_DIR/traceroute.txt"
cat "$PHANTOM_DIR/traceroute.txt"

# Проверяем BGP-информацию через публичный сервис
echo "  🌍 BGP информация:"
curl -sk "https://api.bgpview.io/ip/$TARGET_IP" 2>/dev/null | grep -oP '"asn":\K[0-9]+|"name":"\K[^"]+' | head -5 > "$PHANTOM_DIR/bgp_info.txt"
cat "$PHANTOM_DIR/bgp_info.txt"

echo ""

# --- Фаза 2: Создание фантомного TCP-соединения ---
echo -e "${CY}[PHANTOM] 👻 Фаза 2: Фантомное TCP-соединение...${NC}"

# Отправляем SYN пакет и анализируем ответ (через python3 + scapy)
python3 -c "
import sys
try:
    from scapy.all import IP, TCP, sr1
    print('  📡 Scapy доступен. Отправляю SYN...')
    pkt = IP(dst='$TARGET_IP')/TCP(dport=80, flags='S')
    ans = sr1(pkt, timeout=3, verbose=0)
    if ans:
        print(f'  💀 ОТВЕТ: {ans.summary()}')
        if ans.haslayer(TCP):
            print(f'  🔍 Флаги: {ans[TCP].flags}')
            print(f'  🔍 Окно: {ans[TCP].window}')
    else:
        print('  ❌ Нет ответа')
except ImportError:
    print('  ⚠️ Scapy не установлен. Установи: pkg install python && pip install scapy')
except Exception as e:
    print(f'  ⚠️ Ошибка: {e}')
" 2>/dev/null

echo ""

# --- Фаза 3: BGP Hijack симуляция ---
echo -e "${CY}[PHANTOM] 🌍 Фаза 3: BGP Hijack симуляция...${NC}"

# Создаём фальшивый BGP-анонс
cat > "$PHANTOM_DIR/bgp_announce.txt" << BGPEOF
BGP UPDATE Message
Withdrawn Routes: None
Path Attributes:
  ORIGIN: IGP
  AS_PATH: 65001 65002 65003
  NEXT_HOP: 10.0.0.1
Network Layer Reachability Information (NLRI):
  $TARGET_IP/32
BGPEOF

echo "  🌍 Фальшивый BGP-анонс создан:"
cat "$PHANTOM_DIR/bgp_announce.txt"

echo ""
echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║   🌐 PROTOCOL PHANTOM — ЗАВЕРШЁН            ║${NC}"
echo -e "${RED}║   Мы знаем маршрут. Мы контролируем сеть.   ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "  📁 $PHANTOM_DIR/"
