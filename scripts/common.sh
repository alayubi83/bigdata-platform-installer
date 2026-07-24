#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Common Library
#
###############################################################################

set -e
set -o pipefail

###############################################################################
# Color
###############################################################################

export RED="\033[0;31m"
export GREEN="\033[0;32m"
export YELLOW="\033[1;33m"
export BLUE="\033[0;34m"
export CYAN="\033[0;36m"
export MAGENTA="\033[0;35m"
export WHITE="\033[1;37m"
export NC="\033[0m"

###############################################################################
# Directory
###############################################################################

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LOG_DIR="${BASE_DIR}/logs"

mkdir -p "${LOG_DIR}"

LOG_FILE="${LOG_DIR}/install.log"

touch "${LOG_FILE}"

###############################################################################
# Banner
###############################################################################

banner(){

clear

echo -e "${CYAN}"

cat <<EOF

====================================================================

                 BIG DATA PLATFORM INSTALLER

====================================================================

EOF

echo -e "${NC}"

}

###############################################################################
# Logging
###############################################################################

timestamp(){

date +"%Y-%m-%d %H:%M:%S"

}

log(){

LEVEL="$1"

MESSAGE="$2"

printf "[%s] %-5s %s\n" \
"$(timestamp)" \
"${LEVEL}" \
"${MESSAGE}" | tee -a "${LOG_FILE}"

}

log_info(){

log INFO "$1"

}

log_warn(){

log WARN "$1"

}

log_error(){

log ERROR "$1"

}

log_success(){

log OK "$1"

}

###############################################################################
# Output
###############################################################################

info(){

echo -e "${BLUE}[INFO]${NC} $1"

}

warn(){

echo -e "${YELLOW}[WARN]${NC} $1"

}

error(){

echo -e "${RED}[ERROR]${NC} $1"

exit 1

}

success(){

echo -e "${GREEN}[ OK ]${NC} $1"

}

section(){

echo

echo -e "${MAGENTA}============================================================${NC}"

echo -e "${WHITE}$1${NC}"

echo -e "${MAGENTA}============================================================${NC}"

echo

}

###############################################################################
# Execute
###############################################################################

run(){

CMD="$*"

log_info "${CMD}"

eval "${CMD}"

RET=$?

if [ ${RET} -ne 0 ]; then

log_error "${CMD}"

exit ${RET}

fi

}

###############################################################################
# Retry
###############################################################################

retry(){

COUNT=0

MAX=5

CMD="$*"

until ${CMD}
do

COUNT=$((COUNT+1))

warn "Retry ${COUNT}/${MAX}"

sleep 3

if [ ${COUNT} -ge ${MAX} ]; then

error "Command failed."

fi

done

}

###############################################################################
# Check Command
###############################################################################

command_exists(){

command -v "$1" >/dev/null 2>&1

}

###############################################################################
# Check Root
###############################################################################

check_root(){

if [ "$EUID" -ne 0 ]; then

error "Run installer using sudo."

fi

}

###############################################################################
# Check Ubuntu
###############################################################################

check_ubuntu(){

if [ ! -f /etc/os-release ]; then

error "Unsupported Linux."

fi

. /etc/os-release

if [ "$ID" != "ubuntu" ]; then

error "Only Ubuntu supported."

fi

}

###############################################################################
# Spinner
###############################################################################

spinner() {

    local pid=$1
    local delay=0.10
    local spin='|/-\'

    while ps -p "${pid}" >/dev/null 2>&1; do
        for i in $(seq 0 3); do
            printf "\r[%c] Working..." "${spin:$i:1}"
            sleep "${delay}"
        done
    done

    printf "\r"
}

###############################################################################
# Progress
###############################################################################

progress() {

    local current=$1
    local total=$2

    local percent=$((current*100/total))
    local done=$((percent/2))
    local left=$((50-done))

    printf "\r["

    for ((i=0;i<done;i++)); do
        printf "="
    done

    for ((i=0;i<left;i++)); do
        printf " "
    done

    printf "] %3d%%" "${percent}"

}

###############################################################################
# System Information
###############################################################################

cpu_count() {

    nproc

}

memory_total_mb() {

    free -m | awk '/^Mem:/ {print $2}'

}

disk_available_gb() {

    df -BG / | awk 'NR==2 {gsub("G","",$4);print $4}'

}

###############################################################################
# Validation
###############################################################################

check_cpu() {

    CPU=$(cpu_count)

    if [ "${CPU}" -lt 2 ]; then

        warn "Minimum CPU recommended: 2"

    else

        success "CPU : ${CPU}"

    fi

}

check_memory() {

    MEM=$(memory_total_mb)

    if [ "${MEM}" -lt 4096 ]; then

        warn "Minimum RAM recommended: 4 GB"

    else

        success "Memory : ${MEM} MB"

    fi

}

check_disk() {

    DISK=$(disk_available_gb)

    if [ "${DISK}" -lt 30 ]; then

        warn "Minimum disk recommended: 30 GB"

    else

        success "Disk : ${DISK} GB"

    fi

}

###############################################################################
# Internet
###############################################################################

check_internet() {

    if ping -c1 github.com >/dev/null 2>&1; then

        success "Internet connection available."

    else

        error "Internet connection unavailable."

    fi

}

###############################################################################
# Port
###############################################################################

port_used() {

    local PORT=$1

    ss -tln | awk '{print $4}' | grep -q ":${PORT}$"

}

wait_port() {

    local PORT=$1

    local RETRY=60

    while [ ${RETRY} -gt 0 ]
    do

        if port_used "${PORT}"; then

            success "Port ${PORT} ready."

            return

        fi

        sleep 2

        RETRY=$((RETRY-1))

    done

    error "Port ${PORT} timeout."

}

###############################################################################
# Package
###############################################################################

package_installed() {

    dpkg -s "$1" >/dev/null 2>&1

}

install_package() {

    PKG="$1"

    if package_installed "${PKG}"; then

        log_info "${PKG} already installed."

        return

    fi

    log_info "Installing ${PKG}"

    DEBIAN_FRONTEND=noninteractive apt-get install -y "${PKG}"

}

install_packages() {

    for PKG in "$@"
    do
        install_package "${PKG}"
    done

}
