#!/bin/bash
# Argus Logger
LOG_DIR="${LOG_DIR:-$HOME/argus_logs}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/argus_$(date +%Y%m%d).log"

log() {
    local level=$1; shift
    local msg="$*"
    local ts=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Ротация если >10MB
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) -gt 10485760 ]; then
        mv "$LOG_FILE" "$LOG_FILE.1"
    fi
    
    echo "[$ts] [$level] $msg" >> "$LOG_FILE"
    
    case "$level" in
        ERROR) echo -e "\033[31m[ERR]\033[0m $msg" ;;
        WARN)  echo -e "\033[33m[WARN]\033[0m $msg" ;;
        INFO)  echo -e "\033[36m[INF]\033[0m $msg" ;;
        OK)    echo -e "\033[32m[OK]\033[0m $msg" ;;
    esac
}
