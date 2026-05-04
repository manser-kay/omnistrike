#!/bin/bash
echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike v56.1 — One-Click Install    ║"
echo "╚══════════════════════════════════════════════╝"

# Определяем платформу
if [ -d "/data/data/com.termux" ]; then
    PKG="pkg"; OS="Termux"
elif [ -f "/etc/debian_version" ]; then
    PKG="sudo apt -y"; OS="Debian/Kali"
elif [ "$(uname)" = "Darwin" ]; then
    PKG="brew"; OS="macOS"
elif grep -qi microsoft /proc/version 2>/dev/null; then
    PKG="sudo apt -y"; OS="WSL"
else
    PKG=""; OS="Unknown"
fi

echo "[+] $OS detected"

# Зависимости
[ -n "$PKG" ] && $PKG install nmap curl python3 git openssl sqlmap 2>/dev/null

# Клонирование
git clone https://github.com/manser-kay/shadowstrike ~/shadowstrike 2>/dev/null || echo "[*] Already installed"
cd ~/shadowstrike && chmod +x *.sh *.py 2>/dev/null

# Алиас
grep -q "alias shadow=" ~/.bashrc 2>/dev/null || echo "alias shadow='~/shadowstrike/shadow.sh'" >> ~/.bashrc

echo "[+] Done! Run: shadow check"
