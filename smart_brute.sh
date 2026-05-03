#!/bin/bash
TARGET=$1
DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
COMPANY=$(echo "$DOMAIN" | cut -d. -f1)
YEAR=$(date +%Y)
echo "[SMART-BRUTE] Generating passwords for $COMPANY..."
for p in "${COMPANY}123" "${COMPANY}${YEAR}" "${COMPANY}@${YEAR}" "admin123" "password"; do
    echo "$p"
done
