#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Configuration Loader
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_DIR="${BASE_DIR}/config"

###############################################################################
# Check Configuration
###############################################################################

require_config() {

    local FILE="$1"

    if [ ! -f "${CONFIG_DIR}/${FILE}" ]; then

        echo "Configuration file not found: ${CONFIG_DIR}/${FILE}"

        exit 1

    fi

}

###############################################################################
# Load Configuration
###############################################################################

load_configuration() {

    require_config version.conf
    require_config installer.conf
    require_config cluster.conf
    require_config download.conf
    require_config environment.conf

    source "${CONFIG_DIR}/version.conf"
    source "${CONFIG_DIR}/installer.conf"
    source "${CONFIG_DIR}/cluster.conf"
    source "${CONFIG_DIR}/download.conf"
    source "${CONFIG_DIR}/environment.conf"

}

###############################################################################
# Validation
###############################################################################

validate_configuration() {

    REQUIRED=(
        HADOOP_VERSION
        HIVE_VERSION
        SPARK_VERSION
        JAVA_PACKAGE

        INSTALL_USER
        INSTALL_GROUP

        POSTGRES_HOST
        POSTGRES_PORT
        POSTGRES_DATABASE
        POSTGRES_USER
        POSTGRES_PASSWORD
    )

    for VAR in "${REQUIRED[@]}"
    do

        VALUE="${!VAR}"

        if [ -z "${VALUE}" ]; then

            echo "Configuration ${VAR} is empty."

            exit 1

        fi

    done

}

###############################################################################
# Initialize
###############################################################################

load_configuration

validate_configuration
