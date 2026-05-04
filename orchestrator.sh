#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║   ORCHESTRATOR v5.0 — GUI ПО КАТЕГОРИЯМ                     ║
# ╚══════════════════════════════════════════════════════════════╝

ORCH_DIR="$HOME/.shadow_orchestrator_v5"
mkdir -p "$ORCH_DIR"

RED='\033[0;31m'; GR='\033[0;32m'; YL='\033[1;33m'; CY='\033[0;36m'
PR='\033[0;35m'; WH='\033[1;37m'; BL='\033[0;34m'; NC='\033[0m'

show_menu() {
    clear
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║   🗡️  SHADOWSTRIKE ORCHESTRATOR v5.0                         ║"
    echo "║   236 модулей • 11 измерений • 7 XXX • PARADOX              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""

    # СТАТИСТИКА
    echo -e "${WH}═══ 📊 ЖИВАЯ СТАТИСТИКА ═══${NC}"
    echo -e "  🧬 Агентов: $(find ~/.shadow_genesis/births -name '*.txt' 2>/dev/null | wc -l)"
    echo -e "  💀 Могил:   $(find ~/.shadow_death/graveyard -name '*.txt' 2>/dev/null | wc -l)"
    echo -e "  💕 Пар:     $(find ~/.shadow_love/couples -name '*.txt' 2>/dev/null | wc -l)"
    echo -e "  📁 Модулей: $(ls ~/.shadow_*.sh 2>/dev/null | wc -l)"
    echo ""

    # МЕНЮ
    echo -e "${WH}═══ 🎮 КАТЕГОРИИ ═══${NC}"
    echo ""
    echo -e "${GR}[1]  🌌 ЭКОСИСТЕМА       (11 измерений)${NC}"
    echo -e "    Genesis • Chronos • Nexus • Memory • Emotion"
    echo -e "    Death • Love • Fate • Chaos • Portal • Omniverse"
    echo ""
    echo -e "${CY}[2]  ⚔️  БОЕВЫЕ МОДУЛИ    (53 шт.)${NC}"
    echo -e "    Apocalypse • Autopwn • Hivemind • Swarm • C2"
    echo ""
    echo -e "${PR}[3]  🌀 XXX СЕРИЯ         (v2–v7)${NC}"
    echo -e "    Quantum • Reality Collapse • Plague • Hive Mind • Eclipse"
    echo ""
    echo -e "${YL}[4]  ⚛️  PARADOX          (суперпозиция)${NC}"
    echo -e "    Разведка + Атака + Заметание — одновременно"
    echo ""
    echo -e "${BL}[5]  🧬 ГЕНЕРАТОРЫ       (Codex • Prophet • Singularity)${NC}"
    echo -e "    Самообучение • Генерация • Предсказание"
    echo ""
    echo -e "${RED}[6]  🏆 ДОБЫЧА           (War Chest • Extractor)${NC}"
    echo -e "    Кошельки • Ключи • Базы • Личные данные"
    echo ""
    echo -e "${WH}[0]  🚪 ВЫХОД${NC}"
    echo ""
    echo -ne "${GR}[ORCH] Выбери категорию: ${NC}"
}

# Подменю для боевых модулей
battle_menu() {
    echo ""
    echo -e "${CY}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CY}║   ⚔️  БОЕВЫЕ МОДУЛИ                                          ║${NC}"
    echo -e "${CY}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GR}[a] Apocalypse    — Тотальная атака${NC}"
    echo -e "${GR}[b] Autopwn       — Авто-взлом${NC}"
    echo -e "${GR}[c] Hivemind      — Коллективный разум${NC}"
    echo -e "${GR}[d] Quantum Swarm — Квантовый рой${NC}"
    echo -e "${GR}[e] Deep Recon    — Глубокая разведка${NC}"
    echo -e "${GR}[f] SQLMap Evasion v2 — Обход WAF${NC}"
    echo -e "${GR}[g] Backdoor Gen  — Генератор бэкдоров${NC}"
    echo -e "${GR}[h] C2 God        — Командный центр${NC}"
    echo -e "${GR}[0] Назад${NC}"
    echo ""
    echo -ne "${GR}[ORCH] Выбери модуль: ${NC}"
    read -r mod

    case $mod in
        a) bash ~/.shadow_apocalypse.sh "$TARGET" 2>/dev/null || echo "Запусти через: bash ~/.shadow_apocalypse.sh URL" ;;
        b) bash ~/.shadow_autopwn.sh "$TARGET" 2>/dev/null ;;
        c) bash ~/.shadow_hivemind.sh "$TARGET" 2>/dev/null ;;
        d) bash ~/.shadow_quantum_swarm.sh "$TARGET" 2>/dev/null ;;
        e) bash ~/.shadow_deep_recon.sh "$TARGET" 2>/dev/null ;;
        f) bash ~/.shadow_sqlmap_evasion_v2.sh "$TARGET" 2>/dev/null ;;
        g) bash ~/.shadow_backdoor_gen.sh "$TARGET" 2>/dev/null ;;
        h) bash ~/.shadow_c2_god.sh "$TARGET" 2>/dev/null ;;
        0) return ;;
    esac
}

# Главный цикл
while true; do
    show_menu
    read -r choice

    case $choice in
        1)
            echo -e "${GR}[ORCH] Запускаю экосистему...${NC}"
            bash ~/.shadow_orchestrator.sh 2>/dev/null || echo "bash ~/.shadow_orchestrator.sh"
            ;;
        2)
            echo -ne "${GR}[ORCH] Цель: ${NC}"; read -r TARGET
            battle_menu
            ;;
        3)
            echo -ne "${GR}[ORCH] Цель: ${NC}"; read -r TARGET
            echo ""
            echo -e "${PR}XXX Серия:${NC}"
            echo "  v2) Quantum Entanglement"
            echo "  v3) Identity Crisis"
            echo "  v4) Total Reality Collapse"
            echo "  v5) The Plague"
            echo "  v6) Hive Mind"
            echo "  v7) Eclipse"
            echo -ne "Выбери версию (2-7): "
            read -r xxx
            [ -f "$HOME/.shadow_xxx_v${xxx}.sh" ] && bash "$HOME/.shadow_xxx_v${xxx}.sh" "$TARGET" || echo "Не найдена"
            ;;
        4)
            echo -ne "${GR}[ORCH] Цель: ${NC}"; read -r TARGET
            bash ~/.shadow_paradox_dimension.sh "$TARGET" 2>/dev/null
            ;;
        5)
            echo -e "${YL}[ORCH] Генераторы:${NC}"
            echo "  1) Codex — скрестить модули"
            echo "  2) Prophet — предсказать"
            echo "  3) Singularity — эволюция"
            echo -ne "Выбери: "; read -r gen
            case $gen in
                1) source ~/.shadow_codex.sh 2>/dev/null && mass_generate 5 ;;
                2) source ~/.shadow_prophet.sh 2>/dev/null && echo -ne "Цель: "; read -r t; prophet_scan "$t" ;;
                3) source ~/.shadow_singularity.sh 2>/dev/null && echo -ne "Цель: "; read -r t; evolve "$t" 3 ;;
            esac
            ;;
        6)
            echo -ne "${GR}[ORCH] Цель: ${NC}"; read -r TARGET
            echo "  1) War Chest (кошельки/ключи)"
            echo "  2) Extractor (все данные)"
            echo -ne "Выбери: "; read -r loot
            case $loot in
                1) bash ~/.shadow_war_chest.sh "$TARGET" 2>/dev/null ;;
                2) bash ~/.shadow_extractor.sh "$TARGET" 2>/dev/null ;;
            esac
            ;;
        0) echo -e "${RED}[ORCH] Выход...${NC}"; exit 0 ;;
        *) echo -e "${RED}Неверный выбор${NC}" ;;
    esac

    echo ""
    echo -e "${YL}[Нажми Enter]${NC}"
    read -r
done
