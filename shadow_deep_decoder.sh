#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   🧬 DEEP DECODER — Универсальный дешифратор               ║
# ║   Препарирует .so библиотеки до инструкций                 ║
# ╚══════════════════════════════════════════════════════════════╝

APK_FILE=$1
[ -z "$APK_FILE" ] && { echo "Usage: $0 /path/to/file.apk"; exit 1; }

DECODER_DIR="$HOME/.shadow_deep_decoder"
mkdir -p "$DECODER_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   🧬 DEEP DECODER — Анализ .so библиотек    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Распаковываем APK
TMP_DIR="$DECODER_DIR/apk_unpacked"
mkdir -p "$TMP_DIR"
unzip -o "$APK_FILE" -d "$TMP_DIR" >/dev/null 2>&1

echo "[DECODER] 📦 APK распакован"

# Анализируем каждую .so библиотеку
find "$TMP_DIR" -name "*.so" -type f | while read so_file; do
    name=$(basename "$so_file")
    size=$(ls -la "$so_file" | awk '{print $5}')

    echo ""
    echo "  📚 Библиотека: $name ($size байт)"
    echo "  ══════════════════════════════════════════"

    # 1. Тип файла
    file_type=$(file "$so_file" 2>/dev/null)
    echo "  📋 Тип: $file_type"

    # 2. Заголовки ELF
    echo "  📋 Секции:"
    readelf -S "$so_file" 2>/dev/null | grep -E "\.text|\.data|\.rodata|\.bss|\.plt|\.got" | head -10 | while read section; do
        echo "    $section"
    done

    # 3. Экспортируемые функции (ищем читерские)
    echo "  📋 Экспортируемые функции:"
    objdump -T "$so_file" 2>/dev/null | grep -iE "esp|aim|wall|hack|cheat|inject|hook|bypass|esp|no_recoil|kill" | head -10 | while read func; do
        echo "    💀 $func"
    done

    # 4. Строки (пароли, URL, ключи)
    echo "  📋 Подозрительные строки:"
    strings "$so_file" 2>/dev/null | grep -iE "http|https|api\.|secret|key|token|password|inject|cheat|hack|bypass" | head -10 | while read str; do
        echo "    🔑 $str"
    done

    # 5. Зависимости
    echo "  📋 Зависимости:"
    objdump -x "$so_file" 2>/dev/null | grep "NEEDED" | head -10 | while read dep; do
        echo "    🔗 $dep"
    done
done

# Сохраняем отчёт
find "$TMP_DIR" -name "*.so" -exec basename {} \; > "$DECODER_DIR/library_list.txt"

echo ""
echo "[DECODER] ✅ Анализ завершён"
echo "  📁 $DECODER_DIR/"
rm -rf "$TMP_DIR"
