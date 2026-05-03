import http.server, socketserver, re, os, ssl, threading, json, time, urllib.request, urllib.parse
from datetime import datetime
from urllib.parse import urlparse, parse_qs, urlencode, urlunparse

PASSIVE_LOG = os.path.expanduser('~/passive_scan.txt')
REPEATER_LOG = os.path.expanduser('~/repeater_log.txt')
WS_LOG = os.path.expanduser('~/websocket_log.txt')
COOKIE_JAR_FILE = os.path.expanduser('~/.cookie_jar.json')
INTERCEPT_MODE = False
HISTORY = []
MAX_HISTORY = 50

HONEYPOT_SIGNATURES = [
    r'<input[^>]*name=[\"\']email[\"\']',
    r'<input[^>]*name=[\"\']password[\"\']',
    r'<input[^>]*type=[\"\']hidden[\"\'].*name=[\"\']token[\"\']',
    r'<a[^>]*href=[\"\']javascript:void\(0\)[\"\']',
    r'<a[^>]*style=[\"\']display:\s*none[\"\']',
    r'<form[^>]*action=[\"\'][^\"\']*\.php[\"\']',
]

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
    'API_Keys': [r'AIza[0-9A-Za-z\-_]{35}', r'sk_live_[0-9a-zA-Z]{24}'],
    'Stripe_Key': [r'sk_live_[0-9a-zA-Z]{24,}'],
    'IDOR_Params': [r'(id|user_id|uid|userId)=\d+'],
    'RCE_Params': [r'(cmd|exec|command|execute|run)\s*='],
    'Cache_Poison': [r'X-Forwarded-Host:', r'X-Original-URL:'],
    'AWS_Keys': [r'AKIA[0-9A-Z]{16}', r'aws_access_key_id'],
    'GCP_Keys': [r'AIza[0-9A-Za-z\-_]{35}'],
    'Heroku_Keys': [r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'],
    'Mailgun_Keys': [r'key-[0-9a-zA-Z]{32}'],
    'Twilio_Keys': [r'SK[0-9a-fA-F]{32}'],
    'Github_Token': [r'ghp_[0-9a-zA-Z]{36}', r'gho_[0-9a-zA-Z]{36}'],
    'JWT_Leak': [r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'],
    'Password_In_URL': [r'password=[^&]+', r'passwd=[^&]+', r'pwd=[^&]+'],
    'SQL_Errors': [r'SQL syntax.*MySQL', r'Warning.*mysql_', r'PostgreSQL.*ERROR'],
    'PHP_Errors': [r'PHP (Parse|Fatal|Warning) error'],
    'ASP_Errors': [r'Server Error in .\/. Application'],
    'Debug_Print': [r'print_r\(', r'var_dump\(', r'console\.log\('],
    'Backup_Files': [r'\.bak$', r'\.old$', r'\.save$', r'\.swp$', r'~$'],
    'Config_Files': [r'\.config$', r'\.conf$', r'\.ini$', r'\.yml$', r'\.yaml$'],
    'Log_Files': [r'\.log$', r'debug\.log', r'error\.log'],
    'Docker_Files': [r'Dockerfile', r'docker-compose\.yml'],
    'Git_Leak': [r'\.git/HEAD', r'\.git/config', r'\.gitignore'],
    'SSRF_Blind': [r'(url|uri|path|dest|redirect|return|out|view|dir|show|load|file|document)=https?://'],
    'SQL_Blind': [r'(id|page|pid|cat|action|article|product|item|user)=\d+[\'\"\\s]'],
    'XSS_Extended': [r'on\w+\s*=\s*[\"\']?\s*javascript:', r'data:text/html'],
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
        host = headers.get('Host', '')
        # ===== JWT ANALYZER =====
        for hv in headers.values():
            jwt_match = re.search(r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}', hv)
            if jwt_match:
                jwt = jwt_match.group()
                parts = jwt.split('.')
                if len(parts) == 3:
                    try:
                        import base64, time as ttime
                        hb64 = parts[0] + '=' * (4 - len(parts[0]) % 4)
                        pb64 = parts[1] + '=' * (4 - len(parts[1]) % 4)
                        header_j = base64.urlsafe_b64decode(hb64).decode()
                        payload_j = base64.urlsafe_b64decode(pb64).decode()
                        print(f"\033[96m[JWT] Header: {header_j}\033[0m")
                        print(f"\033[96m[JWT] Payload: {payload_j[:200]}\033[0m")
                        if '"alg":"none"' in header_j.lower():
                            print(f"\033[91m[JWT] ALERT: alg=none!\033[0m")
                        exp_match = re.search(r'"exp":(\d+)', payload_j)
                        if exp_match:
                            exp_t = int(exp_match.group(1))
                            now_t = ttime.time()
                            if exp_t < now_t:
                                print(f"\033[93m[JWT] EXPIRED\033[0m")
                            else:
                                print(f"\033[92m[JWT] Valid\033[0m")
                    except:
                        print(f"\033[93m[JWT] Decode failed\033[0m")
                break

        # ===== CMS PLUGIN DETECT =====
        cms_plugins_file = os.path.expanduser('~/cms_plugins.txt')
        if os.path.exists(cms_plugins_file):
            with open(cms_plugins_file) as pf:
                for line in pf:
                    if ':' in line and not line.startswith('#'):
                        plugin, endpoint = line.strip().split(':', 1)
                        if endpoint in path or plugin.replace('-', '') in body.lower().replace('-', ''):
                            print(f"\033[96m[CMS-PLUGIN] Found: {plugin}\033[0m")
                            break

        # ===== WAF BYPASS DETECT =====
        waf_headers = (headers.get('Server', '') + headers.get('X-CDN', '') + headers.get('X-Served-By', '')).lower()
        if 'cloudflare' in waf_headers:
            print("\033[93m[WAF] Cloudflare detected | Try: X-Forwarded-For: 127.0.0.1\033[0m")
        elif 'akamai' in waf_headers:
            print("\033[93m[WAF] Akamai detected | Try: True-Client-IP: 127.0.0.1\033[0m")
        elif 'cloudfront' in waf_headers or 'aws' in waf_headers:
            print("\033[93m[WAF] AWS/CloudFront detected | Try: X-Forwarded-For: 169.254.169.254\033[0m")
        scope = os.environ.get('SCOPE', '')
        if scope and host and not any(s.strip() in host for s in scope.split(',')):
            self.send_response(200)
            self.end_headers()
            return
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
        
        # ===== WebSocket MitM =====
        if headers.get('Upgrade', '').lower() == 'websocket':
            print(f"\033[96m[WS-MitM] {method} {path}\033[0m")
            if body: print(f"\033[96m[WS-MitM] Body: {body[:300]}\033[0m")
            with open(WS_LOG, 'a') as f:
                f.write(f"[{datetime.now().strftime('%H:%M:%S')}] WS-MitM {method} {path}\n")
                f.write(f"Headers: {json.dumps(headers)}\n")
                if body: f.write(f"Body: {body}\n")
                f.write('---\n')
        
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
                    # ===== ACTIVE SCAN ON THE FLY =====
                    if cat in ['SQLi', 'XSS', 'LFI', 'RCE_Params', 'SSTI_Extended', 'XXE_Extended']:
                        active_payloads = {
                            'SQLi': ["'", "1' OR '1'='1", "1; SELECT SLEEP(1)--"],
                            'XSS': ["<script>alert(1)</script>", '"><img src=x onerror=alert(1)>'],
                            'LFI': ["../../etc/passwd", "....//....//etc/passwd"],
                            'RCE_Params': [";id", "|id", "`id`"],
                            'SSTI_Extended': ["{{7*7}}", "${7*7}"],
                            'XXE_Extended': ['<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>'],
                        }
                        if cat in active_payloads:
                            import urllib.request
                            for ap in active_payloads[cat][:1]:
                                try:
                                    test_url = f"http://{host}{path}"
                                    if '?' in test_url:
                                        test_url += f"&test={urllib.parse.quote(ap)}"
                                    else:
                                        test_url += f"?test={urllib.parse.quote(ap)}"
                                    req = urllib.request.Request(test_url)
                                    req.add_header('User-Agent', headers.get('User-Agent', 'Mozilla/5.0'))
                                    start = __import__('time').time()
                                    resp = urllib.request.urlopen(req, timeout=5)
                                    elapsed = __import__('time').time() - start
                                    rbody = resp.read().decode('utf-8', errors='ignore')
                                    if ('root:' in rbody and cat == 'LFI') or \
                                       (elapsed > 2 and cat == 'SQLi') or \
                                       ('49' in rbody and cat == 'SSTI_Extended') or \
                                       ('uid=' in rbody and cat == 'RCE_Params'):
                                        print(f"\033[91m[ACTIVE] CONFIRMED: {cat} at {path} with payload: {ap}\033[0m")
                                except:
                                    pass
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
    print(f"\033[92m[+] Passive Scanner + Repeater + Intruder + Cookie Jar ({protocol}) on port {port} [{mode}]\033[0m")
    print(f"\033[93m[*] Proxy: 127.0.0.1:{port}\033[0m")
    print(f"\033[93m[*] Logs: ~/passive_scan.txt | ~/repeater_log.txt | ~/websocket_log.txt\033[0m")
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
