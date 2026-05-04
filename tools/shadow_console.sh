#!/bin/bash
# Боевая консоль — командный центр ShadowStrike
export SHADOW_VERSION="56.1"

battle_status() {
    echo "╔══════════════════════════════════════════════╗"
    echo "║   ShadowStrike v$SHADOW_VERSION — Боевой центр      ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    echo "АКТИВНЫЕ ОПЕРАЦИИ:"
    pgrep -f "shadow.sh" >/dev/null && echo "  🟢 Сканер активен" || echo "  🔴 Сканер неактивен"
    pgrep -f "shadow_passive" >/dev/null && echo "  🟢 Пассивный сбор" || echo "  🔴 Пассивный сбор выключен"
    pgrep -f "shadow_c2" >/dev/null && echo "  🟢 C2 сервер" || echo "  🔴 C2 выключен"
    [ -f ~/shadow_scan_*/HACKER_REPORT.txt ] && echo "  📊 Есть отчёты" || echo "  📊 Отчётов нет"
    echo ""
    echo "ПОСЛЕДНЯЯ ДОБЫЧА:"
    ls -t ~/shadow_loot/ 2>/dev/null | head -3 | while read f; do
        echo "  💰 $f"
    done
}

battle_menu() {
    echo ""
    echo "КОМАНДЫ:"
    echo "  scan <url>    — Полный скан цели"
    echo "  passive       — Пассивный сбор (прокси)"
    echo "  c2 <port>     — Поднять C2 сервер"
    echo "  loot          — Посмотреть добычу"
    echo "  report        — Сгенерировать боевой отчёт"
    echo "  status        — Статус операций"
    echo "  exit          — Выход"
    echo ""
}

while true; do
    clear
    battle_status
    battle_menu
    read -p "ShadowStrike> " cmd
    
    case "$cmd" in
        scan*) target=$(echo "$cmd" | cut -d' ' -f2); ~/shadow.sh "$target" ;;
        passive) fuser -k 9990/tcp 2>/dev/null; python3 ~/shadow_passive.py 9990 & echo "Пассивный сбор на порту 9990" ;;
        c2*) port=$(echo "$cmd" | cut -d' ' -f2); python3 ~/shadow_c2_server.py "${port:-443}" & ;;
        loot) ls -la ~/shadow_loot/ 2>/dev/null || echo "Пусто" ;;
        report) ~/shadow_hacker_report.sh 2>/dev/null || echo "Нет данных для отчёта" ;;
        status) battle_status ;;
        exit) echo "Завершение..."; exit 0 ;;
        *) echo "Неизвестная команда" ;;
    esac
    sleep 1
done
