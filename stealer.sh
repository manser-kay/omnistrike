#!/bin/bash
# ShadowStealer — аудит утечек данных (без отправки)

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStealer — Data Leak Audit           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

echo "[*] Браузеры..."
for browser in "com.android.chrome" "org.mozilla.firefox"; do
    find /data/data/$browser \( -name "Cookies" -o -name "Login Data" \) 2>/dev/null | while read f; do
        echo "  📁 $(basename $f) — МОЖЕТ УТЕЧЬ"
    done
done

echo "[*] Крипта..."
for wallet in "trust" "metamask" "binance"; do
    find /data/data -maxdepth 2 -path "*$wallet*" -type d 2>/dev/null | head -1 | while read d; do
        echo "  💰 $wallet — ДОСТУПЕН"
    done
done

echo "[*] Соцсети..."
for app in "facebook" "instagram" "telegram" "whatsapp"; do
    find /data/data -maxdepth 2 -path "*$app*" -type d 2>/dev/null | head -1 | while read d; do
        echo "  📱 $app — ДОСТУПЕН"
    done
done

echo "[*] Система..."
[ -f /data/misc/wifi/wpa_supplicant.conf ] && echo "  🔐 WiFi пароли — ДОСТУПНЫ"
[ -f /data/data/com.android.providers.contacts/databases/contacts2.db ] && echo "  📞 Контакты — ДОСТУПНЫ"

echo ""
echo "=========================================="
echo "  Баз данных доступно: $(find /data/data -name '*.db' 2>/dev/null | wc -l)"
echo "=========================================="
