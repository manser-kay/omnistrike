#!/bin/bash
echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — SMOKE TEST                 ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

ERRORS=0

# Проверка синтаксиса
echo "[TEST] Checking syntax..."
for f in ~/shadow*.sh; do
    bash -n "$f" 2>/dev/null || { echo "  ❌ $(basename $f)"; ERRORS=$((ERRORS+1)); }
done
echo "  Bash errors: $ERRORS"

# Проверка Python
PY_ERRORS=0
for f in ~/shadow*.py; do
    python3 -c "import py_compile; py_compile.compile('$f', doraise=True)" 2>/dev/null || { echo "  ❌ $(basename $f)"; PY_ERRORS=$((PY_ERRORS+1)); }
done
echo "  Python errors: $PY_ERRORS"

# Проверка интернета
curl -sk --max-time 5 "https://google.com" >/dev/null 2>&1 && echo "  ✅ Internet" || echo "  ❌ Internet"

# Проверка зависимостей
for cmd in nmap curl python3 bash; do
    command -v $cmd >/dev/null 2>&1 && echo "  ✅ $cmd" || echo "  ❌ $cmd"
done

echo ""
echo "══════════════════════════════════════════════"
echo "  Total errors: $((ERRORS + PY_ERRORS))"
echo "  Status: $([ $((ERRORS + PY_ERRORS)) -eq 0 ] && echo '🟢 PASSED' || echo '🔴 FAILED')"
echo "══════════════════════════════════════════════"
