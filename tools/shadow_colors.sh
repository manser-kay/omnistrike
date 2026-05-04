#!/bin/bash
# Цветовая система ShadowStrike
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[1;37m'
export NC='\033[0m'

# Функции умной подсветки
crit()  { echo -e "${RED}[💀 КРИТ]${NC} $*"; }
high()  { echo -e "${RED}[🔴 HIGH]${NC} $*"; }
warn()  { echo -e "${YELLOW}[🟡 WARN]${NC} $*"; }
info()  { echo -e "${BLUE}[🔵 INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[🟢 OK]${NC} $*"; }

# Авто-определение критичности
color_by_severity() {
    case "$1" in
        critical|crit) crit "${@:2}" ;;
        high) high "${@:2}" ;;
        medium|med) warn "${@:2}" ;;
        low|info) info "${@:2}" ;;
        *) ok "${@:2}" ;;
    esac
}
