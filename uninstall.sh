#!/bin/bash

###############################################################################
#
# Big Data Platform Uninstaller
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${BASE_DIR}/version.conf"

GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

banner(){

clear

echo -e "${CYAN}"

cat <<EOF

============================================================

            BIG DATA PLATFORM UNINSTALLER

============================================================

EOF

echo -e "${RESET}"

}

confirm(){

echo

read -rp "Continue uninstall? (yes/no): " ANSWER

case "$ANSWER" in
    yes|YES|y|Y)
        ;;
    *)
        echo "Cancelled."
        exit 0
        ;;
esac

}

stop_service(){

SERVICE="$1"

if systemctl list-unit-files | grep -q "^${SERVICE}"; then

    echo "Stopping ${SERVICE}"

    sudo systemctl stop "${SERVICE}" || true

    sudo systemctl disable "${SERVICE}" || true

fi

}

remove_directory(){

DIR="$1"

if [ -d "$DIR" ]; then

    echo "Removing ${DIR}"

    sudo rm -rf "$DIR"

fi

}

remove_env(){

FILE="$HOME/.bashrc"

TMP=$(mktemp)

grep -v "/opt/bigdata" "$FILE" > "$TMP" || true

mv "$TMP" "$FILE"

}

summary(){

echo

echo "============================================================"

echo -e "${GREEN}Uninstallation completed.${RESET}"

echo

echo "Please reopen your terminal."

echo

echo "============================================================"

}

###############################################################################

main(){

banner

confirm

echo

echo "Stopping PostgreSQL..."

stop_service postgresql

echo

echo "Removing installation..."

remove_directory /opt/bigdata

remove_directory /data/hdfs

remove_directory /var/log/hadoop

remove_directory /var/log/hive

remove_directory /var/log/spark

remove_env

summary

}

main
