#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   👂 SILENT ECHO — Пассивный сбор информации о цели       ║
# ║   Не отправляет ни одного вредоносного пакета.            ║
# ╚══════════════════════════════════════════════════════════════╝

TARGET=${1:-"http://zero.webappsecurity.com"}
SILENT_DIR="$HOME/.shadow_silent_echo"
mkdir -p "$SILENT_DIR"

echo "╔══════════════════════════════════════════════╗"
echo "║   👂 SILENT ECHO — Пассивная разведка       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# --- 1. Анализ времени ответа (как TIME TRAVELER) ---
echo "[ECHO] ⏱️ Анализирую время ответа..."
BASELINE=$(curl -sk --max-time 5 -o /dev/null -w "%{time_total}" "$TARGET" 2>/dev/null)
for endpoint in "/admin" "/.env" "/api" "/graphql" "/console" "/internal"; do
    TIME1=$(curl -sk --max-time 5 -o /dev/null -w "%{time_total}" "$TARGET$endpoint" 2>/dev/null)
    TIME2=$(curl -sk --max-time 5 -o /dev/null -w "%{time_total}" "$TARGET/nonexistent_$RANDOM" 2>/dev/null)
    DIFF=$(echo "$TIME1 - $TIME2" | bc 2>/dev/null || echo 0)
    [ "$(echo "$DIFF > 0.1" | bc 2>/dev/null)" = "1" ] && echo "  💀 $endpoint СУЩЕСТВУЕТ (Δt=${DIFF}с)" && echo "$endpoint" >> "$SILENT_DIR/timing.txt"
done

# --- 2. Анализ заголовков (как GHOST PROTOCOL) ---
echo "[ECHO] 👻 Анализирую заголовки..."
HEADERS=$(curl -sk --max-time 5 -I "$TARGET" 2>/dev/null)
echo "$HEADERS" | grep -i "Server:" && echo "Server" >> "$SILENT_DIR/headers.txt"
echo "$HEADERS" | grep -i "X-Powered-By:" && echo "X-Powered-By" >> "$SILENT_DIR/headers.txt"
echo "$HEADERS" | grep -i "Set-Cookie:" && echo "Set-Cookie" >> "$SILENT_DIR/headers.txt"

# --- 3. Анализ SSL/TLS (как VOID WHISPER) ---
echo "[ECHO] 🔒 Анализирую SSL/TLS..."
SSL_INFO=$(curl -sk --max-time 5 -v "$TARGET" 2>&1 | grep -E "SSL connection|TLS|subject|issuer")
[ -n "$SSL_INFO" ] && echo "$SSL_INFO" > "$SILENT_DIR/ssl.txt"

echo ""
echo "[ECHO] ✅ Разведка завершена. Цель изучена."
echo "  📁 $SILENT_DIR/"
