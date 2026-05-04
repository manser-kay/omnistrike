#!/bin/bash
TARGET=$1
echo "[API-HUNTER] Deep API discovery..."

# Парсим JS и ищем скрытые эндпоинты
curl -sk --max-time 10 "$TARGET" 2>/dev/null | grep -oP '(?:src|href)="\K[^"]+\.js' | sort -u | while read js; do
    JS_CODE=$(curl -sk --max-time 5 "$TARGET/$js" 2>/dev/null)
    
    # Ищем WebSocket
    echo "$JS_CODE" | grep -qi "ws://\|wss://\|WebSocket" && echo "  📡 WebSocket in $js"
done
    # Ищем API пути
    echo "$JS_CODE" | grep -oP '["\x27](/api/[^"\x27]+)["\x27]' | tr -d "\"\\" | sort -u | while read api; do
        code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 3 "$TARGET$api" 2>/dev/null)
        [ "$code" != "404" ] && echo "  🔗 $api [HTTP $code]"
    done
    
    # Ищем GraphQL
    echo "$JS_CODE" | grep -qi "graphql" && echo "  🎯 GraphQL in $js"
    
    # Ищем WebSocket
    echo "$JS_CODE" | grep -qi "ws\|wss\|WebSocket" && echo "  📡 WebSocket in $js"
