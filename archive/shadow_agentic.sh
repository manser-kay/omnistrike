#!/bin/bash
TARGET=$1
HTML=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)
LEARNED="$HOME/.shadow_learned_$(echo $TARGET | md5sum | cut -c1-8)"

echo "[AGENTIC v2] Анализирую с самообучением..."
echo "$HTML" | grep -qi "wp-content" && echo "WordPress → wpscan" | tee "$LEARNED" && exit 0
echo "$HTML" | grep -qi "graphql" && echo "GraphQL → introspection" | tee "$LEARNED" && exit 0
echo "$HTML" | grep -qi "<form.*login" && echo "Login form → brute" | tee "$LEARNED" && exit 0

# Если уже сканировали этот тип — используем прошлый опыт
[ -f "$LEARNED" ] && echo "Learned: $(cat $LEARNED)"
