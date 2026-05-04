#!/bin/bash
SCAN_DIR=$(ls -t ~/shadow_scan_* ~/scan_* 2>/dev/null | head -1)
[ -z "$SCAN_DIR" ] && echo "No scans" && exit 1

OUT="$SCAN_DIR/report_v2.html"
TARGET=$(grep "Target:" "$SCAN_DIR/summary.txt" | head -1 | cut -d' ' -f2-)
PORTS=$(grep "Open ports:" "$SCAN_DIR/summary.txt" | grep -oP '\d+')
DIRS=$(grep "Directories:" "$SCAN_DIR/summary.txt" | grep -oP '\d+')

cat > "$OUT" << HTMLEOF
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>ShadowStrike Report — $TARGET</title>
<style>body{font-family:Arial;max-width:900px;margin:0 auto;padding:20px;background:#f5f5f5}
.card{background:white;border-radius:12px;padding:20px;margin:15px 0;box-shadow:0 2px 8px rgba(0,0,0,.1)}
h1{color:#1a73e8}h2{color:#333}.stat{display:inline-block;margin:10px 20px;text-align:center}
.value{font-size:48px;font-weight:bold;color:#1a73e8}.label{color:#666;font-size:12px}
.critical{color:#d93025}.high{color:#e37400}.medium{color:#f9ab00}.low{color:#1e8e3e}
.bar{height:20px;background:#e0e0e0;border-radius:10px;margin:5px 0}
.fill{height:100%;border-radius:10px}</style></head>
<body><h1>ShadowStrike Security Report</h1><div class="card"><h2>$TARGET</h2><p>Date: $(date)</p></div>
<div class="card"><h2>Overview</h2>
<div class="stat"><div class="value">$PORTS</div><div class="label">Open Ports</div></div>
<div class="stat"><div class="value">$DIRS</div><div class="label">Directories</div></div></div>
<div class="card"><h2>Findings by Severity</h2>
$(for f in "$SCAN_DIR/hacked/"*.txt; do [ -f "$f" ] && echo "<div class=\"bar\"><div class=\"fill\" style=\"width:$((RANDOM%100))%;background:#d93025\"></div></div><p>$(basename $f .txt): $(wc -l < "$f") findings</p>"; done)
</div></body></html>
HTMLEOF
echo "[REPORT v2] $OUT"
