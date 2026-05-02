#!/bin/bash
# Argus Hacker Report — боевой журнал для пентестера
# Только технические данные: векторы атак, хеши, пути для эскалации

SCAN_DIR=${1:-$(ls -t ~/argus_scan_* 2>/dev/null | head -1)}
[ -z "$SCAN_DIR" ] && echo "Usage: $0 <scan_directory>" && exit 1

OUT="$SCAN_DIR/HACKER_REPORT.txt"
HACKED="$SCAN_DIR/hacked"

cat > "$OUT" << EOF
╔══════════════════════════════════════════════════════════════╗
║           ARGUS AFTER-ACTION REPORT (PENTESTER EDITION)      ║
║           Target: $TARGET                                   ║
║           Date: $(date)                                     ║
╚══════════════════════════════════════════════════════════════╝

EOF

# --- Секция 1: Немедленные векторы атаки (RCE, SQLi, итд) ---
echo "=== 💀 IMMEDIATE ATTACK VECTORS (Shoot on sight) ===" >> "$OUT"
for critical_file in cmdi rce sql_dump file_inclusion ssti xxe; do
    if [ -s "$HACKED/${critical_file}.txt" ]; then
        echo "" >> "$OUT"
        echo "[!!!] CRITICAL: $critical_file" >> "$OUT"
        echo "----------------------------------------" >> "$OUT"
        cat "$HACKED/${critical_file}.txt" >> "$OUT"
    fi
done

# --- Секция 2: Украденные ключи и хеши ---
echo "" >> "$OUT"
echo "=== 🔑 LOOTED CREDENTIALS & HASHES ===" >> "$OUT"
if [ -s "$HACKED/credentials.txt" ]; then
    echo "Live Credentials:" >> "$OUT"
    cat "$HACKED/credentials.txt" >> "$OUT"
fi
if [ -s "$HACKED/env_credentials.txt" ]; then
    echo ".env Credentials:" >> "$OUT"
    cat "$HACKED/env_credentials.txt" >> "$OUT"
fi
# Поиск хешей (John/Hashcat)
grep -rE '[a-f0-9]{32}|[a-f0-9]{40}|[a-f0-9]{64}|\$2[ayb]\$' "$HACKED" 2>/dev/null | head -20 >> "$OUT"

# --- Секция 3: Точки входа для дальнейшей атаки ---
echo "" >> "$OUT"
echo "=== 🚪 PIVOT POINTS & LATERAL MOVEMENT ===" >> "$OUT"
if [ -f "$SCAN_DIR/nmap.txt" ]; then
    echo "Open Ports:" >> "$OUT"
    grep "open" "$SCAN_DIR/nmap.txt" | awk '{print $1 " (" $3 ")"}' >> "$OUT"
fi
if [ -d "$HACKED/git_dump" ]; then
    echo "" >> "$OUT"
    echo "GIT Repository Leaked (Find secrets with: git log -p | grep -i password)" >> "$OUT"
    ls -la "$HACKED/git_dump" >> "$OUT"
fi

# --- Секция 4: Дыры в защите (WAF/IDS обход) ---
echo "" >> "$OUT"
echo "=== 🥷 STEALTH & EVASION ===" >> "$OUT"
if [ -f "$SCAN_DIR/waf.txt" ]; then
    echo "WAF/IDS Detected:" >> "$OUT"
    head -5 "$SCAN_DIR/waf.txt" >> "$OUT"
fi

# --- Секция 5: Команды для Metasploit ---
echo "" >> "$OUT"
echo "=== ⚔️ READY-TO-USE METASPLOIT COMMANDS ===" >> "$OUT"
if [ -f "$HACKED/cve.txt" ]; then
    while read cve_line; do
        cve=$(echo "$cve_line" | grep -oP 'CVE-\d{4}-\d{4,}')
        [ -z "$cve" ] && continue
        echo "search $cve" >> "$OUT"
        echo "# set RHOSTS target.com" >> "$OUT"
        echo "# run" >> "$OUT"
        echo "" >> "$OUT"
    done < "$HACKED/cve.txt"
fi

echo "Report generated: $OUT"
echo "Review with: less -R $OUT"
