#!/bin/bash
# Argus Plugin Guard — защита плагинов от удаления и изменения

PLUGIN_DIR="$HOME/argus-red/plugins"
HASHES_FILE="$HOME/.argus_plugin_hashes"

# Создаём папку если нет
mkdir -p "$PLUGIN_DIR"

echo "[GUARD] 🛡️ Проверяю целостность плагинов..."

# Если файла с хешами нет — создаём его (первый запуск)
if [ ! -f "$HASHES_FILE" ]; then
    find "$PLUGIN_DIR" -name "plugin_*.sh" -exec md5sum {} \; > "$HASHES_FILE" 2>/dev/null
    echo "[GUARD] Первый запуск — сохранены контрольные суммы $(wc -l < "$HASHES_FILE") плагинов"
    exit 0
fi

# Сравниваем текущие хеши с сохранёнными
CHANGED=0
while read -r hash file; do
    if [ -f "$file" ]; then
        CURRENT_HASH=$(md5sum "$file" | cut -d' ' -f1)
        if [ "$hash" != "$CURRENT_HASH" ]; then
            echo "  ⚠️ Изменён: $file"
            CHANGED=$((CHANGED + 1))
            # Восстанавливаем из Git
            cd "$HOME/argus-red" && git checkout -- "$file" 2>/dev/null
            echo "  ✅ Восстановлен из репозитория"
        fi
    else
        echo "  ⚠️ Удалён: $file"
        CHANGED=$((CHANGED + 1))
        # Восстанавливаем из Git
        cd "$HOME/argus-red" && git checkout -- "$file" 2>/dev/null
        echo "  ✅ Восстановлен из репозитория"
    fi
done < "$HASHES_FILE"

# Проверяем новые плагины (добавленные после последней проверки)
find "$PLUGIN_DIR" -name "plugin_*.sh" | while read new_file; do
    if ! grep -q "$new_file" "$HASHES_FILE"; then
        echo "  🆕 Новый плагин: $(basename $new_file)"
    fi
done

# Обновляем хеши
find "$PLUGIN_DIR" -name "plugin_*.sh" -exec md5sum {} \; > "$HASHES_FILE" 2>/dev/null

if [ "$CHANGED" -gt 0 ]; then
    echo "[GUARD] ⚠️ Восстановлено плагинов: $CHANGED"
else
    echo "[GUARD] ✅ Все плагины в порядке"
fi
