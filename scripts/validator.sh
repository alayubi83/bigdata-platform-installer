#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Validator Library
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${BASE_DIR}/version.conf"
source "${BASE_DIR}/scripts/common.sh"

###############################################################################
# Operating System
###############################################################################

validate_os() {

    section "Operating System"

    if [ ! -f /etc/os-release ]; then
        error "Unsupported operating system."
    fi

    . /etc/os-release

    if [ "${ID}" != "ubuntu" ]; then
        error "Only Ubuntu is supported."
    fi

    if [ "${VERSION_ID}" != "22.04" ]; then
        warn "Expected Ubuntu 22.04, found ${VERSION_ID}"
    fi

    success "Operating system validated."

}

###############################################################################
# CPU
###############################################################################

validate_cpu() {

    section "CPU"

    check_cpu

}

###############################################################################
# Memory
###############################################################################

validate_memory() {

    section "Memory"

    check_memory

}

###############################################################################
# Disk
###############################################################################

validate_disk() {

    section "Disk"

    check_disk

}

###############################################################################
# Internet
###############################################################################

validate_network() {

    section "Internet"

    check_internet

}

###############################################################################
# Required Commands
###############################################################################

validate_required_commands() {

    section "Required Commands"

    REQUIRED=(
        bash
        curl
        wget
        tar
        gzip
        awk
        sed
        grep
        ssh
        systemctl
    )

    for CMD in "${REQUIRED[@]}"
    do

        if command_exists "${CMD}"
        then
            success "${CMD}"
        else
            error "${CMD} not found."
        fi

    done

}

###############################################################################
# Hostname
###############################################################################

validate_hostname() {

    section "Hostname"

    HOST=$(hostname)

    success "${HOST}"

}

###############################################################################
# PATH
###############################################################################

validate_path() {

    section "PATH"

    echo "${PATH}"

}

###############################################################################
# Summary
###############################################################################

run_validation() {

    banner

    validate_os

    validate_cpu

    validate_memory

    validate_disk

    validate_network

    validate_required_commands

    validate_hostname

    validate_path

    section "Validation Completed"

    success "Environment ready."

}

###############################################################################

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    run_validation

fi
