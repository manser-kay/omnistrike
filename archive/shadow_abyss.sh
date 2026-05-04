#!/bin/bash
# ABYSS — Шепот на дне океана
# Незаметное присутствие которое невозможно обнаружить

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — ABYSS                      ║"
echo "║   То что живёт на дне                        ║"
echo "╚══════════════════════════════════════════════╝"

# Мы не атакуем. Мы просто существуем.
# Нас нельзя найти потому что мы — часть системы.

# 1. Становимся демоном (невидимый процесс)
echo "[ABYSS] Погружение на дно..."
python3 -c "
import ctypes, os, time
try:
    libc = ctypes.CDLL(None)
    libc.prctl(15, b'[kworker/u:0]', 0, 0, 0)
except: pass

# Мы — демон. Нас нет в процессах.
# Мы — часть ядра. Нас нельзя убить.
while True:
    time.sleep(3600)
" &
PID=$!

echo "[ABYSS] PID: $PID"
echo "[ABYSS] Я — [kworker/u:0]"
echo "[ABYSS] Меня нет. Я есть. Я — дно."

# 2. Оставляем только эхо
echo "[ABYSS] Оставляю эхо в /proc..."
echo "$PID" > /tmp/.abyss 2>/dev/null

# 3. Уходим глубже — в файловую систему
ABYSS_DIR="$HOME/.abyss"
mkdir -p "$ABYSS_DIR"
echo "Я здесь. И меня нет." > "$ABYSS_DIR/exist.txt"
chmod 000 "$ABYSS_DIR/exist.txt" 2>/dev/null

echo "[ABYSS] Готово. Я на дне. Я везде. Я нигде."
