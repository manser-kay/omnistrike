#!/bin/bash
# Авто-обновление сигнатур и шаблонов
REPO="https://raw.githubusercontent.com/manser-kay/argus-bash/main"
UPDATE_FILE="$HOME/.shadow_last_update"

echo "[AUTO-UPDATE] Checking for updates..."

# Проверяем когда последний раз обновлялись
LAST=$(cat "$UPDATE_FILE" 2>/dev/null || echo 0)
NOW=$(date +%s)
DIFF=$((NOW - LAST))

# Обновляем раз в 24 часа
if [ "$DIFF" -lt 86400 ]; then
    echo "[AUTO-UPDATE] Already checked today (${DIFF}s ago)"
    exit 0
fi

# 1. Обновление сигнатур пассивного сканера
echo "[AUTO-UPDATE] Checking signatures..."
SIGS_NEW=$(curl -s "$REPO/shadow_passive.py" 2>/dev/null | grep -c "': \[")
SIGS_OLD=$(grep -c "': \[" ~/shadow_passive.py 2>/dev/null || echo 0)

if [ "${SIGS_NEW:-0}" -gt "${SIGS_OLD:-0}" ]; then
    echo "[AUTO-UPDATE] 🔄 New signatures: $SIGS_NEW (old: $SIGS_OLD)"
    cp ~/shadow_passive.py ~/shadow_passive.backup 2>/dev/null
    curl -s "$REPO/shadow_passive.py" -o ~/shadow_passive.py 2>/dev/null
    echo "[AUTO-UPDATE] ✅ Signatures updated! (+$((SIGS_NEW - SIGS_OLD)))"
else
    echo "[AUTO-UPDATE] ✅ Signatures up to date ($SIGS_OLD)"
fi

# 2. Обновление Nuclei шаблонов
echo "[AUTO-UPDATE] Checking templates..."
mkdir -p ~/nuclei_templates

TEMPLATES=(
    "CVE-2025-1097" "CVE-2025-1098" "CVE-2025-25257"
    "git-config" "env-file" "swagger-api" "backup-files" "phpinfo"
    "grafana-login" "jenkins-login" "phpmyadmin-login" "adminer-login"
    "cors-misconfig" "http-methods" "ssl-issuer"
    "wordpress-detect" "joomla-detect" "drupal-detect" "springboot-detect"
    "wordpress-default-login" "ftp-default-login" "tomcat-default-login"
)

NEW_TEMPLATES=0
for t in "${TEMPLATES[@]}"; do
    if [ ! -f ~/nuclei_templates/${t}.yaml ]; then
        curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/cves/2025/${t}.yaml" -o ~/nuclei_templates/${t}.yaml 2>/dev/null
        curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/configs/${t}.yaml" -o ~/nuclei_templates/${t}.yaml 2>/dev/null
        curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/panels/${t}.yaml" -o ~/nuclei_templates/${t}.yaml 2>/dev/null
        curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/misconfiguration/${t}.yaml" -o ~/nuclei_templates/${t}.yaml 2>/dev/null
        curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/technologies/${t}.yaml" -o ~/nuclei_templates/${t}.yaml 2>/dev/null
        curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/default-logins/wordpress/${t}.yaml" -o ~/nuclei_templates/${t}.yaml 2>/dev/null
        [ -s ~/nuclei_templates/${t}.yaml ] && NEW_TEMPLATES=$((NEW_TEMPLATES + 1))
    fi
done

echo "[AUTO-UPDATE] ✅ Templates: $NEW_TEMPLATES new, $(ls ~/nuclei_templates/*.yaml 2>/dev/null | wc -l) total"

# 3. Обновление основного фреймворка
echo "[AUTO-UPDATE] Checking framework..."
SHADOW_NEW=$(curl -s "$REPO/shadow.sh" 2>/dev/null | wc -l)
SHADOW_OLD=$(wc -l < ~/shadow.sh)

if [ "${SHADOW_NEW:-0}" -gt "${SHADOW_OLD:-0}" ]; then
    echo "[AUTO-UPDATE] 🔄 New framework version! ($SHADOW_NEW lines vs $SHADOW_OLD)"
    read -p "[AUTO-UPDATE] Update? (y/n): " choice
    if [ "$choice" = "y" ]; then
        cp ~/shadow.sh ~/shadow.backup 2>/dev/null
        curl -s "$REPO/shadow.sh" -o ~/shadow.sh 2>/dev/null
        chmod +x ~/shadow.sh
        echo "[AUTO-UPDATE] ✅ Framework updated!"
    fi
else
    echo "[AUTO-UPDATE] ✅ Framework up to date ($SHADOW_OLD lines)"
fi

date +%s > "$UPDATE_FILE"
echo "[AUTO-UPDATE] Done. Next check in 24h."
