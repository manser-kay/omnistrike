#!/bin/bash
TARGET=$1
echo "[LOOT] Quick scan..."
for f in /.git/HEAD /.env /wp-config.php /dump.sql /backup.zip; do
    code=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$f" 2>/dev/null)
    [ "$code" = "200" ] && echo "💰 $f [HTTP $code]"
done
