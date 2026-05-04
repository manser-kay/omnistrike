#!/bin/bash
SCAN_DIR=$(ls -t ~/shadow_scan_* 2>/dev/null | head -1)
TARGET=$(grep "Target:" "$SCAN_DIR/summary.txt" 2>/dev/null | grep -oP 'http\S+')

echo "=== SHADOWSTRIKE AFTER-ACTION REPORT ==="
echo "Target: $TARGET | Date: $(date)"
echo ""
echo "=== FINDINGS ==="
for f in "$SCAN_DIR/hacked/"*.txt; do
    [ -f "$f" ] && echo "[$(basename $f .txt)]" && cat "$f"
done
echo ""
echo "=== METASPLOIT COMMANDS ==="
grep -oP 'CVE-\d{4}-\d{4,}' "$SCAN_DIR/hacked/cve.txt" 2>/dev/null | while read cve; do
    echo "search $cve"
    echo "use exploit/...# set RHOSTS target"
done
echo ""
echo "=== NEXT MOVE ==="
[ -f "$SCAN_DIR/hacked/sqli.txt" ] && echo "1. Dump DB via SQLi"
[ -f "$SCAN_DIR/hacked/lfi.txt" ] && echo "1. Read configs via LFI"
[ -f "$SCAN_DIR/hacked/env_credentials.txt" ] && echo "2. Use stolen creds"
echo "3. Deploy persistence"
