#!/bin/bash
ERRORS=0
echo "ShadowStrike Battle Ready Check"
for cmd in nmap curl python3 bash; do
    command -v $cmd >/dev/null 2>&1 && echo "  ✅ $cmd" || { echo "  ❌ $cmd"; ERRORS=$((ERRORS+1)); }
done
for f in shadow.sh shadow_passive.py shadow_c2_server.py; do
    [ -f ~/$f ] && echo "  ✅ $f" || { echo "  ❌ $f"; ERRORS=$((ERRORS+1)); }
done
curl -sk --max-time 5 "https://google.com" >/dev/null 2>&1 && echo "  ✅ Internet" || { echo "  ❌ Internet"; ERRORS=$((ERRORS+1)); }
echo ""
[ "$ERRORS" -eq 0 ] && echo "READY" || echo "PROBLEMS: $ERRORS"
