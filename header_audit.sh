#!/bin/bash
TARGET=$1
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
echo "[HEADERS] Security audit for $TARGET"
echo "$HEADERS" | grep -qi "Content-Security-Policy" && echo "✅ CSP" || echo "❌ CSP missing"
echo "$HEADERS" | grep -qi "X-Frame-Options" && echo "✅ X-Frame" || echo "❌ X-Frame missing"
echo "$HEADERS" | grep -qi "X-Content-Type-Options" && echo "✅ X-Content" || echo "❌ X-Content missing"
echo "$HEADERS" | grep -qi "Strict-Transport-Security" && echo "✅ HSTS" || echo "❌ HSTS missing"
