#!/bin/bash
FINDING=$1
SEVERITY=${2:-"INFO"}

# Slack
[ -n "$SLACK_WEBHOOK" ] && curl -sk -X POST "$SLACK_WEBHOOK" \
    -d "{\"text\":\"🔍 ShadowStrike: *$SEVERITY* — $FINDING\"}" 2>/dev/null

# Discord
[ -n "$DISCORD_WEBHOOK" ] && curl -sk -X POST "$DISCORD_WEBHOOK" \
    -d "{\"content\":\"🔍 **$SEVERITY**: $FINDING\"}" 2>/dev/null

# Telegram
[ -n "$TG_BOT_TOKEN" ] && [ -n "$TG_CHAT_ID" ] && curl -sk \
    "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage?chat_id=$TG_CHAT_ID&text=🔍 *$SEVERITY*: $FINDING" 2>/dev/null

echo "[NOTIFY] Sent: $SEVERITY — $FINDING"
