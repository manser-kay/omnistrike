# OmniStrike — Red Team Framework

**110+ модулей для пентеста | Android/Linux/macOS | Бесплатно**

Персональный Red Team фреймворк. Прошёл путь от простого сканера до экосистемы атак.

## Что внутри

| Категория | Модулей | Описание |
|-----------|:---:|----------|
| Разведка | 25 | DNS, поддомены, параметры, GraphQL, favicon, sitemap |
| Обход WAF | 15 | Smuggling, фрагментация, кэш-отравление, обход rate-limit |
| Анализ | 10 | JWT, APK, куки, CSP, SRI, ETag, метаданные |
| Неочевидные векторы | 20 | 404-атаки, favicon-сниффер, Brotli-бомба, WebP-ловушка |
| Пассивный сбор | 10 | Wayback Machine, Google Dorks, Silent Echo |
| Архив | 30+ | Старые версии, эксперименты, дубликаты |

## Быстрый старт
git clone https://github.com/manser-kay/omnistrike.git
cd omnistrike
bash shadow_silent_echo.sh http://target.com
bash shadow_google_dork_login.sh target.com

## Установка
bash shadow_install.sh

## Дисклеймер
Только для образовательных целей и пентестов с письменным разрешением.

## Лицензия
MIT
