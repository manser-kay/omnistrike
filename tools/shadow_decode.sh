#!/bin/bash
INPUT=$1
[ -z "$INPUT" ] && echo "Usage: $0 <string>" && exit 1

echo "[DECODE v2] Многослойный анализ: ${INPUT:0:40}..."

# Слой 1: Base64
echo "--- Base64 ---"
echo "$INPUT" | base64 -d 2>/dev/null && echo "✅" || echo "❌ Не Base64"

# Слой 2: URL decode
echo "--- URL ---"
python3 -c "import urllib.parse; print(urllib.parse.unquote('$INPUT'))" 2>/dev/null

# Слой 3: Hex
echo "--- Hex ---"
echo "$INPUT" | xxd -r -p 2>/dev/null && echo "✅" || echo "❌ Не Hex"

# Слой 4: ROT13
echo "--- ROT13 ---"
echo "$INPUT" | tr 'A-Za-z' 'N-ZA-Mn-za-m'

# Слой 5: JWT
echo "--- JWT ---"
echo "$INPUT" | grep -qE '^eyJ' && for part in $(echo "$INPUT" | tr '.' ' '); do
    echo "$part======" | fold -w4 | sed 's/=$//' | tr -d '\n' | base64 -d 2>/dev/null | python3 -m json.tool 2>/dev/null
done

echo "[DECODE v2] Готово"
