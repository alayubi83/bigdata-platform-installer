#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Module : 02 Java
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${BASE_DIR}/version.conf"
source "${BASE_DIR}/scripts/common.sh"

###############################################################################
# Variables
###############################################################################

JAVA_PACKAGE="temurin-8-jdk"

###############################################################################
# Check Java
###############################################################################

java_installed() {

    command -v java >/dev/null 2>&1

}

###############################################################################
# Check Temurin Repository
###############################################################################
install_temurin_repository() {

    section "Install Temurin Repository"

    if [ -f /etc/apt/sources.list.d/adoptium.list ]; then

        log_info "Temurin repository already exists."

        return

    fi

    mkdir -p /etc/apt/keyrings

    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public \
        | gpg --dearmor \
        -o /etc/apt/keyrings/adoptium.gpg

    echo \
"deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb jammy main" \
> /etc/apt/sources.list.d/adoptium.list

    apt-get update

}

###############################################################################
# Install Java
###############################################################################

install_java() {

    section "Install OpenJDK"

    if java_installed; then

        log_info "Java already installed."

        return

    fi

    apt-get install -y "${JAVA_PACKAGE}"

}

###############################################################################
# Detect JAVA_HOME
###############################################################################

detect_java_home() {

    JAVA_BIN=$(readlink -f "$(which java)")

    JAVA_HOME_DETECTED=$(dirname "$(dirname "${JAVA_BIN}")")

}

###############################################################################
# Configure Environment
###############################################################################

configure_java_environment() {

    section "Configure JAVA_HOME"

    remove_env JAVA_HOME

    remove_env PATH

    export_env JAVA_HOME "${JAVA_HOME_DETECTED}"

    append_if_missing ~/.bashrc \
'export PATH=$JAVA_HOME/bin:$PATH'

}

###############################################################################
# Symlink
###############################################################################

create_symlink() {

    section "Create Symlink"

    rm -rf /opt/bigdata/java

    ln -s "${JAVA_HOME_DETECTED}" /opt/bigdata/java

}

###############################################################################
# Validation
###############################################################################

validate_java() {

    section "Validate Java"

    source ~/.bashrc

    java -version

    javac -version

    success "Java installed."

}

###############################################################################
# Summary
###############################################################################

finish_java() {

    section "Java Installation Complete"

    echo

    echo "JAVA_HOME=${JAVA_HOME_DETECTED}"

    echo

    success "OpenJDK installed successfully."

}

###############################################################################
# Main
###############################################################################

main() {

    install_temurin_repository

    install_java

    detect_java_home

    configure_java_environment

    create_symlink

    validate_java

    finish_java

}

###############################################################################

main "$@"
