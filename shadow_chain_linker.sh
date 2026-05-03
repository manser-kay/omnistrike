#!/bin/bash
# Argus Chain Linker — связывает находки в цепочки атак

SCAN_DIR=${1:-$(ls -t ~/argus_scan_* 2>/dev/null | head -1)}
[ -z "$SCAN_DIR" ] && echo "[CHAIN] Нет сканов" && exit 1

HACKED="$SCAN_DIR/hacked"
OUT="$SCAN_DIR/chains.txt"
echo "[CHAIN] Построение цепочек атак..." > "$OUT"

# Цепочка 1: LFI → Config → DB Creds → SQLi
if [ -f "$HACKED/file_inclusion.txt" ] && [ -f "$HACKED/env_credentials.txt" ]; then
    echo "🔗 ЦЕПОЧКА 1: LFI → Credentials → SQLi" | tee -a "$OUT"
    echo "  Шаг 1: Найден LFI — читаем конфиги" >> "$OUT"
    echo "  Шаг 2: Найдены креды в .env:" >> "$OUT"
    cat "$HACKED/env_credentials.txt" | head -3 >> "$OUT"
    echo "  Шаг 3: Использовать для SQLi атаки" >> "$OUT"
    echo "" >> "$OUT"
fi

# Цепочка 2: Git → Source Code → Hardcoded Secrets → Auth Bypass
if [ -d "$HACKED/git_dump" ] && [ -s "$HACKED/git_dump/HEAD" ]; then
    echo "🔗 ЦЕПОЧКА 2: Git Leak → Source Code → Secrets" | tee -a "$OUT"
    echo "  Шаг 1: Скачан .git репозиторий" >> "$OUT"
    echo "  Шаг 2: Извлечь исходный код: cd $HACKED/git_dump && git checkout HEAD" >> "$OUT"
    echo "  Шаг 3: Найти хардкод-секреты: grep -r 'password\|secret\|key' ." >> "$OUT"
    echo "" >> "$OUT"
fi

# Цепочка 3: SQLi → Dump → Admin Hash → Login
if [ -f "$HACKED/sql_dump.txt" ] && grep -qi "password\|admin" "$HACKED/sql_dump.txt" 2>/dev/null; then
    echo "🔗 ЦЕПОЧКА 3: SQLi → Admin Hash → Auth" | tee -a "$OUT"
    echo "  Шаг 1: Сдампили базу через SQLi" >> "$OUT"
    echo "  Шаг 2: Найдены пароли:" >> "$OUT"
    grep -i "password\|admin" "$HACKED/sql_dump.txt" | head -3 >> "$OUT"
    echo "  Шаг 3: Использовать hashcat или подставить в форму логина" >> "$OUT"
    echo "" >> "$OUT"
fi

# Цепочка 4: Cloud Metadata → IAM Keys → Full Cloud Access
if [ -f "$HACKED/cloud_metadata.txt" ]; then
    echo "🔗 ЦЕПОЧКА 4: Cloud Metadata → IAM → Full Access" | tee -a "$OUT"
    echo "  Шаг 1: Найдены cloud metadata" >> "$OUT"
    echo "  Шаг 2: Извлечь IAM ключи:" >> "$OUT"
    grep -i "AccessKeyId\|SecretAccessKey" "$HACKED/cloud_metadata.txt" | head -3 >> "$OUT"
    echo "  Шаг 3: Использовать AWS CLI / GCP SDK с этими ключами" >> "$OUT"
    echo "" >> "$OUT"
fi

# Цепочка 5: IDOR → User Enum → Mass Data Leak
if [ -f "$HACKED/graphql.txt" ] || grep -qi "IDOR" "$HACKED"/*.txt 2>/dev/null; then
    echo "🔗 ЦЕПОЧКА 5: IDOR/GraphQL → User Enum → Data Leak" | tee -a "$OUT"
    echo "  Шаг 1: Найден IDOR или GraphQL endpoint" >> "$OUT"
    echo "  Шаг 2: Перебрать ID пользователей" >> "$OUT"
    echo "  Шаг 3: Скачать данные всех пользователей" >> "$OUT"
    echo "" >> "$OUT"
fi

CHAIN_COUNT=$(grep -c "🔗" "$OUT")
echo "[CHAIN] Построено цепочек: $CHAIN_COUNT"
echo "[CHAIN] Сохранено: $OUT"
[ "$CHAIN_COUNT" -gt 0 ] && cat "$OUT"
