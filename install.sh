#!/bin/bash

###############################################################################
# Big Data Platform Installer
#
# Ubuntu 22.04
# Java 8
# Hadoop 3.2.4
# Hive 2.3.9
# Spark 2.4.8
# PostgreSQL 15
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SCRIPT="${BASE_DIR}/scripts/common.sh"
CONFIG_SCRIPT="${BASE_DIR}/scripts/config.sh"
ENV_SCRIPT="${BASE_DIR}/scripts/environment.sh"

source "${COMMON_SCRIPT}"

source "${CONFIG_SCRIPT}"

source "${ENV_SCRIPT}"

VERSION_FILE="${BASE_DIR}/version.conf"

if [ ! -f "${VERSION_FILE}" ]; then
    echo "version.conf not found."
    exit 1
fi

source "${VERSION_FILE}"

LOG_DIR="${BASE_DIR}/logs"

mkdir -p "${LOG_DIR}"

LOG_FILE="${LOG_DIR}/install.log"

touch "${LOG_FILE}"

exec > >(tee -a "${LOG_FILE}") 2>&1

###############################################################################

SCRIPT_DIR="${BASE_DIR}/scripts/install"

MODULES=(

01_prerequisite.sh
02_java.sh
03_postgresql.sh
04_hadoop.sh
05_hive.sh
06_spark.sh
07_configuration.sh
08_initialize.sh
09_start_services.sh
10_validation.sh
11_finish.sh

)

###############################################################################

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
RESET="\033[0m"

###############################################################################

banner() {

clear

echo -e "${CYAN}"

cat <<'EOF'

============================================================

        BIG DATA PLATFORM INSTALLER

============================================================

Hadoop      : ${HADOOP_VERSION}
Hive        : ${HIVE_VERSION}
Spark       : ${SPARK_VERSION}
PostgreSQL  : ${POSTGRES_VERSION}

============================================================

EOF

echo -e "${RESET}"

}

###############################################################################

check_root() {

if [ "$EUID" -ne 0 ]; then

echo

echo "Please run using sudo."

echo

exit 1

fi

}

###############################################################################

run_module() {

MODULE="$1"

MODULE_PATH="${SCRIPT_DIR}/${MODULE}"


if [ ! -f "${MODULE_PATH}" ]
then

    log_error "Module not found : ${MODULE}"

    exit 1

fi


log_info "Running module : ${MODULE}"


bash "${MODULE_PATH}"


if [ $? -ne 0 ]
then

    log_error "Module failed : ${MODULE}"

    exit 1

fi


log_info "Module completed : ${MODULE}"

}

###############################################################################

summary() {

echo

echo "============================================================"

echo -e "${GREEN}Installation Completed${RESET}"

echo

echo "Installed Components"

echo

echo "Java"

echo "Hadoop"

echo "Hive"

echo "Spark"

echo "PostgreSQL"

echo

echo "============================================================"

echo

}

###############################################################################

main() {

banner

check_root

log_info "Checking installer modules..."

for MODULE in "${MODULES[@]}"
do

if [ ! -f "${SCRIPT_DIR}/${MODULE}" ]
then

log_warn "Skip missing module : ${MODULE}"

fi

done

for MODULE in "${MODULES[@]}"
do

run_module "${MODULE}"

done

summary

}

###############################################################################

main "$@"
