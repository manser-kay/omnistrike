#!/bin/bash
DOMAIN=$1
echo "[SUB] Finding subdomains for $DOMAIN..."
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>/dev/null | grep -oP '"name_value":"\K[^"]+' | sort -u | head -20
