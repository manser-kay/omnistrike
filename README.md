# ShadowStrike — Hacker's Swiss Army Knife

**82 модуля | Android/Linux/macOS | Бесплатно**

## 🚀 Быстрый старт

git clone https://github.com/manser-kay/shadowstrike
cd shadowstrike
chmod +x shadow.sh
./shadow check
./shadow scan http://testphp.vulnweb.com

## ⚡ Основные команды

./shadow scan <url>         Полный скан (порты + SQLi + XSS + Nuclei)
./shadow quick <url>        Быстрый скан (5 минут)
./shadow passive            Пассивный сбор (прокси 127.0.0.1:9990)
./shadow c2 <port>          Поднять C2 сервер
./shadow console            Боевая консоль

## 📁 Что в папке

shadow.sh               Ядро
shadow_passive.py        Пассивный сканер
shadow_c2_server.py      C2 сервер
shadow_c2_agent.sh       C2 агент
smart_brute.sh           Умный брутфорс
waf_detect.sh            Детектор WAF
quick_loot.sh            Поиск сокровищ
subfinder.sh             Поиск поддоменов
portscan.sh              Скан портов
header_audit.sh          Аудит заголовков
stealer.sh               Аудитор утечек данных

## 💡 Примеры

./smart_brute.sh http://target.com          Сгенерировать пароли
./waf_detect.sh http://target.com           Проверить WAF
./quick_loot.sh http://target.com           Быстрый поиск .env/.git
./subfinder.sh target.com                   Найти поддомены
./portscan.sh target.com                    Скан топ-20 портов
./header_audit.sh http://target.com         Аудит заголовков безопасности
./stealer.sh                                Аудит утечек данных

## ⚠️ Ответственность

Автор не несёт ответственности. Ты сам решаешь что делать.

## 📜 Лицензия

MIT
