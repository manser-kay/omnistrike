#!/bin/bash
if [ -f ~/.shadow_vault.lock ]; then
    read -sp "[VAULT] Password: " pass
    echo "$pass" | grep -q . && echo "✅ Unlocked" || echo "❌ Denied"
else
    # Авто-блокировка если обнаружен подозрительный процесс
    ps aux | grep -qi "wireshark\|tcpdump\|strace" && {
        echo "DETECTED! Locking vault..."
        touch ~/.shadow_vault.lock
    }
fi
