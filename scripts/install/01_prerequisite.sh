#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Module : 01 Prerequisite
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${BASE_DIR}/version.conf"
source "${BASE_DIR}/scripts/common.sh"
source "${BASE_DIR}/scripts/validator.sh"

###############################################################################
# Update Repository
###############################################################################

update_repository() {

    section "APT Repository"

    export DEBIAN_FRONTEND=noninteractive

    apt-get update

}

###############################################################################
# Upgrade System
###############################################################################

upgrade_system() {

    if [ "${INSTALL_UPGRADE_SYSTEM}" != "true" ]; then

        log_info "Skip system upgrade."

        return

    fi

    section "System Upgrade"

    export DEBIAN_FRONTEND=noninteractive

    apt-get upgrade -y

}

###############################################################################
# Install Package
###############################################################################

install_required_packages() {

    section "Installing Required Packages"

    PACKAGES=(

    curl
    wget
    unzip
    zip
    tar
    gzip
    bzip2
    xz-utils

    openssh-server
    openssh-client

    rsync

    net-tools

    iproute2

    dnsutils

    lsof

    psmisc

    procps

    tree

    vim

    nano

    jq

    git

    sudo

    gnupg

    software-properties-common

    apt-transport-https

    ca-certificates

    build-essential

    python3

    python3-pip

    )

    install_packages "${PACKAGES[@]}"

}

###############################################################################
# Locale
###############################################################################

configure_locale() {

    section "Locale"

    locale-gen "${LOCALE}"

    update-locale LANG="${LOCALE}"

}

###############################################################################
# Timezone
###############################################################################

configure_timezone() {

    section "Timezone"

    timedatectl set-timezone "${TIMEZONE}"

}

###############################################################################
# Directory
###############################################################################

create_directories() {

    section "Create Directory"

    mkdir -p /opt/bigdata

    mkdir -p /data

    mkdir -p /data/hdfs

    mkdir -p /data/hdfs/name

    mkdir -p /data/hdfs/data

    mkdir -p /var/log/hadoop

    mkdir -p /var/log/hive

    mkdir -p /var/log/spark

}

###############################################################################
# Permission
###############################################################################

configure_permission() {

    section "Permission"

    chown -R "${INSTALL_USER}:${INSTALL_GROUP}" /opt/bigdata

    chown -R "${INSTALL_USER}:${INSTALL_GROUP}" /data

}

###############################################################################
# Validation
###############################################################################

validate_environment() {

    section "Environment Validation"

    run_validation

}

###############################################################################
# Summary
###############################################################################

finish_step() {

    section "Prerequisite Completed"

    success "All prerequisite packages installed."

}

###############################################################################
# Main
###############################################################################

main() {

    update_repository

    upgrade_system

    install_required_packages

    configure_locale

    configure_timezone

    create_directories

    configure_permission

    validate_environment

    finish_step

}

###############################################################################

main "$@"
