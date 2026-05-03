# ShadowStrike — Hacker's Swiss Army Knife

**30+ базовых модулей + архив v1 | Android/Linux/macOS | Бесплатно**

Персональный Red Team фреймворк. Всё что нужно для пентеста в одном месте.

## 🚀 Быстрый старт

git clone https://github.com/manser-kay/shadowstrike
cd shadowstrike
chmod +x shadow.sh
./shadow check
./shadow scan http://testphp.vulnweb.com

## ⚡ Основные команды

./shadow scan <url>         Полный скан
./shadow quick <url>        Быстрый скан (5 минут)
./shadow passive            Пассивный сбор (прокси 127.0.0.1:9990)
./shadow c2 <port>          C2 сервер
./shadow console            Боевая консоль

## 📁 Состав

**Ядро:**
shadow.sh               Основной фреймворк
shadow_passive.py        Пассивный сканер
shadow_c2_server.py      C2 сервер
shadow_c2_agent.sh       C2 агент

**Утилиты:**
smart_brute.sh           Умный брутфорс
waf_detect.sh            Детектор WAF
quick_loot.sh            Поиск сокровищ (.env, .git)
subfinder.sh             Поиск поддоменов
portscan.sh              Скан портов
header_audit.sh          Аудит заголовков безопасности
stealer.sh               Аудитор утечек данных
api_discovery.sh         Поиск скрытых API
cookie_audit.sh          Аудит cookie
tls_check.sh             Проверка SSL/TLS

## 📦 Архив v1 (archive/)

| Модуль | Что делал в v1 |
|--------|---------------|
| **Echo** | Слепой детект WAF через задержку ответа |
| **SQLMap Evasion** | Авто-подбор тамперов для обхода WAF |
| **Hydra Beacon** | Самоисцеляющийся C2: HTTPS→DNS→TCP→Tor |
| **Spider** | Расползание по внутренней сети |
| **Jammer** | Дымовая завеса для SOC |
| **Reverse Psychology** | Усыпление WAF перед атакой |
| **Reflective WAF** | Зеркальная атака — заставляем WAF блокировать свои IP |
| **Crypto Hunter** | Поиск крипто-кошельков |

Это публичные v1. В приватной версии доступны v2+ с глубокими улучшениями.

## ⚠️ Ответственность

Автор не несёт ответственности. Ты сам решаешь что делать.

## 📜 Лицензия

MIT
