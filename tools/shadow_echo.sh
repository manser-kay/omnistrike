#!/bin/bash
TARGET=$1
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)
echo "[ECHO v2] WAF detection..."
echo "$HEADERS" | grep -qi "cf-ray" && echo "Cloudflare" && exit 0
echo "$HEADERS" | grep -qi "x-amz-cf-id" && echo "AWS CloudFront" && exit 0
echo "$HEADERS" | grep -qi "X-FortiWeb" && echo "FortiWeb" && exit 0
echo "Unknown/None"
