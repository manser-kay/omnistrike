#!/bin/bash
# Argus Red — установщик одной командой
# curl -s https://raw.githubusercontent.com/manser-kay/argus-red/main/install.sh | bash

echo "╔══════════════════════════════════════════════╗"
echo "║   🛡️  ARGUS RED — УСТАНОВЩИК               ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Определяем платформу
if [ -d "/data/data/com.termux" ]; then
    PKG="pkg"
    echo "[+] Termux обнаружен"
elif [ -f "/etc/debian_version" ]; then
    PKG="sudo apt"
    echo "[+] Debian/Kali обнаружен"
else
    echo "[!] Неизвестная платформа. Установите зависимости вручную."
fi

# Зависимости
echo "[*] Устанавливаю зависимости..."
$PKG update -y 2>/dev/null
$PKG install -y nmap curl sqlmap python3 git openssl 2>/dev/null

# Клонирование
echo "[*] Клонирую репозиторий..."
git clone https://github.com/manser-kay/argus-red ~/argus-red 2>/dev/null || echo "  Репозиторий уже существует"

# Настройка
cd ~/argus-red
chmod +x argus.sh argus argus_*.sh argus_*.py 2>/dev/null

# Алиас
if ! grep -q "alias argus=" ~/.bashrc 2>/dev/null; then
    echo "alias argus='~/argus-red/argus'" >> ~/.bashrc
    echo "[+] Алиас 'argus' добавлен в .bashrc"
fi

echo ""
echo "✅ Установка завершена!"
echo ""
echo "   argus check   — проверить готовность"
echo "   argus help    — справка"
echo "   argus scan http://target.com — полный скан"
echo ""
echo "   Перезайди в терминал или выполни: source ~/.bashrc"
