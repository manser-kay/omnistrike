#!/bin/bash
DATA=$1
# Слой 1: base64
B64=$(echo "$DATA" | base64 -w0)
# Слой 2: инвертирование
REV=$(echo "$B64" | rev)
# Слой 3: оборачивание в легитимные структуры
echo "/* jQuery v3.7.1 | (c) OpenJS Foundation */"
echo "var _c='${REV}';"
echo "function _d(){return atob(_c.split('').reverse().join(''));}"
