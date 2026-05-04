#!/bin/bash
echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike v56.1 — Установщик           ║"
echo "╚══════════════════════════════════════════════╝"

# Определяем платформу
if [ -d "/data/data/com.termux" ]; then
    PKG="pkg"
elif [ -f "/etc/debian_version" ]; then
    PKG="sudo apt"
else
    PKG=""
fi

# Зависимости
echo "[*] Зависимости..."
[ -n "$PKG" ] && $PKG install -y nmap curl python3 git 2>/dev/null

# Клонирование
echo "[*] Установка ShadowStrike..."
git clone https://github.com/manser-kay/argus-bash ~/shadowstrike 2>/dev/null || echo "  Уже установлен"

# Настройка
cd ~/shadowstrike 2>/dev/null || cd ~/argus-github
chmod +x shadow*.sh shadow*.py shadow 2>/dev/null

# Алиас
grep -q "shadow=" ~/.bashrc 2>/dev/null || echo "alias shadow='~/shadow.sh'" >> ~/.bashrc

echo "✅ Готово! Запуск: shadow http://target.com"
