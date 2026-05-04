#!/bin/bash
SCAN_DIR=$(ls -t ~/shadow_scan_* ~/scan_* 2>/dev/null | head -1)
[ -z "$SCAN_DIR" ] && echo "Нет данных" && exit 1

BRIEF="$SCAN_DIR/BRIEFING.txt"

cat > "$BRIEF" << EOF
SHADOWSTRIKE AFTER-ACTION REPORT
TARGET: $TARGET | DATE: $(date)

===== ATTACK VECTORS =====
$(for f in "$SCAN_DIR/hacked/"*.txt; do [ -f "$f" ] && echo "[$(basename $f .txt)]" && cat "$f" && echo ""; done)

===== LOOT =====
$(ls ~/shadow_loot 2>/dev/null && echo "Loot available" || echo "No loot")

===== PIVOT POINTS =====
$(grep "open" "$SCAN_DIR/nmap.txt" 2>/dev/null | awk '{print "  " $1 " (" $3 ")"}')

===== METASPLOIT READY =====
$(for f in "$SCAN_DIR/hacked/cve.txt" 2>/dev/null; do [ -f "$f" ] && while read cve; do echo "search $cve"; done < "$f"; done)

===== NEXT MOVE =====
$(if [ -f "$SCAN_DIR/hacked/sqli.txt" ]; then echo "1. Dump DB via SQLi"; elif [ -f "$SCAN_DIR/hacked/lfi.txt" ]; then echo "1. Read configs via LFI"; elif [ -f "$SCAN_DIR/hacked/ssrf.txt" ]; then echo "1. Pivot via SSRF"; else echo "1. Deploy Mimic Implant"; fi)
$(if [ -f "$SCAN_DIR/hacked/env_credentials.txt" ]; then echo "2. Use stolen creds ($(wc -l < "$SCAN_DIR/hacked/env_credentials.txt") creds)"; fi)
$(if [ -f "$SCAN_DIR/hacked/sqli.txt" ] || [ -f "$SCAN_DIR/hacked/lfi.txt" ]; then echo "3. Escalate to root via shadow_escalate.sh"; fi)
EOF

cat "$BRIEF"
