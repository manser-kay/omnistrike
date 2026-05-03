#!/bin/bash
# Agentic Workflow — самонаводящийся сканер
# Сам определяет тип цели и выбирает стратегию атаки

MODE=${2:-"smart"}
TARGET=$1

# Режимы сканирования
case "$MODE" in
    advisor)
        echo "[AGENTIC] 🦉 Режим ADVISOR (только план, без атак)"
        export ADVISOR_MODE=true
        export SKIP_ALL_ATTACKS=true
        ;;
    executor)
        echo "[AGENTIC] ⚔️ Режим EXECUTOR (выполнение плана)"
        export ADVISOR_MODE=false
        export SKIP_ALL_ATTACKS=false
        ;;
    speed)
        echo "[AGENTIC] ⚡ Режим SPEED (быстрая разведка)"
        export SQLMAP_LEVEL=1
        export NUCLEI_TEMPLATES="exposures,technologies,misconfiguration"
        export SKIP_BRUTE=true
        ;;
    deep)
        echo "[AGENTIC] 🔬 Режим DEEP (глубокий анализ)"
        export SQLMAP_LEVEL=5
        export NUCLEI_TEMPLATES="cves,exposures,panels,misconfiguration,default-logins,technologies"
        export SKIP_BRUTE=false
        export EXTRA_CHECKS=true
        ;;
    favorites)
        echo "[AGENTIC] ⭐ Режим FAVORITES (только избранное)"
        export SKIP_BRUTE=true
        export SKIP_SQLMAP=true
        echo "[AGENTIC] Выполняю избранные проверки..."
        while IFS= read -r cmd; do
            [[ "$cmd" =~ ^#.*$ ]] || [[ -z "$cmd" ]] && continue
            eval "${cmd//TARGET/$TARGET}"
        done < ~/argus_favorites.txt
        ;;
    *)
        echo "[AGENTIC] 🧠 Режим SMART (авто-выбор)"
        ;;
esac

TARGET=$1
[ -z "$TARGET" ] && echo "Usage: $0 <URL>" && exit 1

echo "[AGENTIC] Анализирую цель..."
HTML=$(curl -sk --max-time 10 "$TARGET" 2>/dev/null)
HEADERS=$(curl -sk -I --max-time 10 "$TARGET" 2>/dev/null)

# === Фаза 1: Определение типа цели ===
TECH_STACK=""
ATTACK_PLAN=()

# WordPress?
if echo "$HTML" | grep -qi "wp-content\|wp-includes\|wordpress"; then
    TECH_STACK="WordPress"
    ATTACK_PLAN+=("wpscan --url $TARGET --enumerate p,t,u")
    ATTACK_PLAN+=("sqlmap -u '$TARGET/wp-admin' --forms")
    ATTACK_PLAN+=("~/argus.sh $TARGET --mode wordpress")
    
# Joomla?
elif echo "$HTML" | grep -qi "joomla\|Joomla"; then
    TECH_STACK="Joomla"
    ATTACK_PLAN+=("joomscan --url $TARGET")
    ATTACK_PLAN+=("~/argus.sh $TARGET --mode joomla")
    
# Drupal?
elif echo "$HTML" | grep -qi "drupal\|Drupal"; then
    TECH_STACK="Drupal"
    ATTACK_PLAN+=("droopescan drupal --url $TARGET")
    ATTACK_PLAN+=("~/argus.sh $TARGET --mode drupal")
    
# Spring Boot (Java)?
elif echo "$HEADERS" | grep -qi "X-Application-Context\|spring"; then
    TECH_STACK="Spring Boot"
    ATTACK_PLAN+=("curl -s '$TARGET/actuator/mappings' | python3 -m json.tool")
    ATTACK_PLAN+=("curl -s '$TARGET/actuator/env' | python3 -m json.tool")
    ATTACK_PLAN+=("~/argus.sh $TARGET --mode springboot")
    
# NodeJS/Express?
elif echo "$HEADERS" | grep -qi "X-Powered-By.*Express\|nodejs"; then
    TECH_STACK="NodeJS/Express"
    ATTACK_PLAN+=("~/argus.sh $TARGET --mode api")
    
# GraphQL?
elif curl -sk "$TARGET/graphql" -X POST -d '{"query":"{__typename}"}' 2>/dev/null | grep -q "data"; then
    TECH_STACK="GraphQL API"
    ATTACK_PLAN+=("graphql-inspector $TARGET/graphql")
    ATTACK_PLAN+=("~/argus.sh $TARGET --mode graphql")
    
# Apache Tomcat?
elif echo "$HEADERS" | grep -qi "Apache-Coyote\|Tomcat"; then
    TECH_STACK="Apache Tomcat"
    ATTACK_PLAN+=("curl -s '$TARGET/manager/html'")
    ATTACK_PLAN+=("curl -s '$TARGET/host-manager/html'")
    ATTACK_PLAN+=("nmap -sV --script http-tomcat-* $TARGET")
    
# Неизвестно — полный скан
else
    TECH_STACK="Unknown"
    ATTACK_PLAN+=("~/argus.sh $TARGET")
fi

echo "[AGENTIC] Определён стек: $TECH_STACK"
echo "[AGENTIC] План атаки (${#ATTACK_PLAN[@]} шагов):"

for i in "${!ATTACK_PLAN[@]}"; do
    echo "  $((i+1)). ${ATTACK_PLAN[$i]}"
done

# === Фаза 1.5: Sentinel AI анализ ===
echo "[AGENTIC] Запускаю Sentinel AI..."
[ -x ~/argus_sentinel.sh ] && ~/argus_sentinel.sh "$TARGET"

# === Фаза 2: Авто-выполнение ===
echo ""
echo "[AGENTIC] Начинаю выполнение..."

for cmd in "${ATTACK_PLAN[@]}"; do
    echo -e "\n${CYAN}[AGENTIC] >>> $cmd${NC}"
    eval "$cmd" 2>&1 | head -30 &
done

wait
echo ""
echo "[AGENTIC] ✅ Сканирование завершено"
echo "[AGENTIC] Стек: $TECH_STACK | Шагов: ${#ATTACK_PLAN[@]}"
