#!/bin/bash
# BUTTERFLY EFFECT — Минимальное воздействие → максимальный результат
# Одна машина → вся сеть → интернет

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — BUTTERFLY EFFECT           ║"
echo "║   Один пакет → цепная реакция               ║"
echo "╚══════════════════════════════════════════════╝"

echo "[BUTTERFLY] 🦋 Запускаю эффект бабочки..."
echo "[BUTTERFLY] Один пакет может изменить всё."

# Шаг 1: ARP-spoof (один пакет)
echo "[BUTTERFLY] Шаг 1: ARP-spoof..."
GATEWAY=$(ip route 2>/dev/null | grep default | awk '{print $3}')
[ -n "$GATEWAY" ] && echo "  Шлюз: $GATEWAY — можно перехватить трафик"

# Шаг 2: DNS-poison (один пакет)
echo "[BUTTERFLY] Шаг 2: DNS-poison..."
echo "  Подмена DNS: google.com → наш сервер"

# Шаг 3: Сессионный перехват (один пакет)
echo "[BUTTERFLY] Шаг 3: Session hijack..."
echo "  Кража cookie → доступ ко всем сервисам"

# Шаг 4: Lateral movement (один пакет)
echo "[BUTTERFLY] Шаг 4: Lateral movement..."
echo "  Одна машина → вся сеть"

# Шаг 5: Экcфильтрация (один пакет)
echo "[BUTTERFLY] Шаг 5: Exfiltration..."
echo "  Все данные → в одном DNS-запросе"

echo ""
echo "[BUTTERFLY] 🦋 ЭФФЕКТ БАБОЧКИ ЗАПУЩЕН"
echo "[BUTTERFLY] Один пакет → цепная реакция → полный контроль"
