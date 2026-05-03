#!/bin/bash
# Авто-Vault: сам запрашивает пароль и расшифровывает при старте

VAULT_DIR="$HOME/.argus_vault"
COOKIE_JAR="$HOME/.cookie_jar.json"
CONFIG="$HOME/argus.conf"
PASS_FILE="$VAULT_DIR/.pass_check"

# Если файлы уже открыты — ничего не делаем
[ -f "$COOKIE_JAR" ] && [ -f "$CONFIG" ] && return 0

# Если зашифрованы — запрашиваем пароль
if [ -f "$VAULT_DIR/.cookie_jar.json.enc" ]; then
    read -sp "[VAULT] Пароль для расшифровки: " PASS
    echo
    
    # Проверяем пароль
    if openssl enc -aes-256-cbc -pbkdf2 -d -in "$PASS_FILE" -pass pass:"$PASS" 2>/dev/null | grep -q "OK"; then
        for enc in "$VAULT_DIR"/*.enc; do
            orig="$HOME/$(basename "$enc" .enc)"
            openssl enc -aes-256-cbc -pbkdf2 -d -in "$enc" -out "$orig" -pass pass:"$PASS" 2>/dev/null
        done
        
        # Запускаем авто-закрытие в фоне (через 30 минут бездействия)
        (
            sleep 1800
            for f in "$COOKIE_JAR" "$CONFIG"; do
                [ -f "$f" ] && openssl enc -aes-256-cbc -pbkdf2 -salt -in "$f" -out "$VAULT_DIR/$(basename $f).enc" -pass pass:"$PASS" 2>/dev/null && shred -u "$f" 2>/dev/null
            done
        ) &
        
        echo "[VAULT] ✅ Расшифровано. Авто-закрытие через 30 мин."
    else
        echo "[VAULT] ❌ Неверный пароль"
        exit 1
    fi
    unset PASS
fi
