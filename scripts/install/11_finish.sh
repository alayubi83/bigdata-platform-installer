#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Finish Module
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${BASE_DIR}/scripts/common.sh"
source "${BASE_DIR}/scripts/config.sh"

###############################################################################
# Environment
###############################################################################

load_environment() {

    export JAVA_HOME="${JAVA_HOME}"
    export HADOOP_HOME="${HADOOP_HOME}"
    export HADOOP_CONF_DIR="${HADOOP_CONF_DIR}"
    export HIVE_HOME="${HIVE_HOME}"
    export SPARK_HOME="${SPARK_HOME}"

    export PATH="${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${HIVE_HOME}/bin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"

}

###############################################################################
# Host Information
###############################################################################

print_system_information() {

    echo
    echo "============================================================"
    echo "System Information"
    echo "============================================================"

    echo "Hostname       : $(hostname)"
    echo "IP Address     : $(hostname -I | awk '{print $1}')"
    echo "Install Root   : ${INSTALL_ROOT}"
    echo "Java Home      : ${JAVA_HOME}"
    echo "Hadoop Home    : ${HADOOP_HOME}"
    echo "Hive Home      : ${HIVE_HOME}"
    echo "Spark Home     : ${SPARK_HOME}"

}

###############################################################################
# Web UI
###############################################################################

print_web_ui() {

    IP=$(hostname -I | awk '{print $1}')

    echo
    echo "============================================================"
    echo "Web UI"
    echo "============================================================"

    echo "NameNode            http://${IP}:${NAMENODE_HTTP_PORT}"
    echo "ResourceManager     http://${IP}:${RM_WEB_PORT}"
    echo "JobHistory          http://${IP}:${JOBHISTORY_WEB_PORT}"
    echo "Spark History       http://${IP}:${SPARK_HISTORY_PORT}"

}

###############################################################################
# Java Process
###############################################################################

print_process() {

    echo
    echo "============================================================"
    echo "Java Process"
    echo "============================================================"

    jps -l || true

}

###############################################################################
# Installed Version
###############################################################################

print_versions() {

    echo
    echo "============================================================"
    echo "Installed Version"
    echo "============================================================"

    echo "Java       : ${JAVA_VERSION}"
    echo "Hadoop     : ${HADOOP_VERSION}"
    echo "Hive       : ${HIVE_VERSION}"
    echo "Spark      : ${SPARK_VERSION}"
    echo "PostgreSQL : ${POSTGRES_VERSION}"

}

###############################################################################
# Log Files
###############################################################################

print_logs() {

    echo
    echo "============================================================"
    echo "Log Files"
    echo "============================================================"

    echo "Installer Log : ${BASE_DIR}/logs/install.log"

    [ -f "${LOG_DIR}/jps.log" ] &&
        echo "JPS Log       : ${LOG_DIR}/jps.log"

    [ -f "${LOG_DIR}/hive-metastore.log" ] &&
        echo "Hive Log      : ${LOG_DIR}/hive-metastore.log"

    [ -f "${LOG_DIR}/spark-history.log" ] &&
        echo "Spark Log     : ${LOG_DIR}/spark-history.log"

}

###############################################################################
# Finish
###############################################################################

finish_message() {

    echo
    echo "============================================================"
    echo "INSTALLATION SUCCESSFULLY COMPLETED"
    echo "============================================================"
    echo

}

###############################################################################
# Main
###############################################################################

main() {

    load_environment

    print_system_information

    print_versions

    print_web_ui

    print_process

    print_logs

    finish_message

}

main "$@"