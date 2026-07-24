#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Validation Module
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
# Helper
###############################################################################

PASS_COUNT=0
FAIL_COUNT=0

check_service() {

    local PROCESS="$1"

    if jps | grep -q "${PROCESS}"
    then

        log_info "${PROCESS} : OK"

        PASS_COUNT=$((PASS_COUNT+1))

    else

        log_error "${PROCESS} : FAILED"

        FAIL_COUNT=$((FAIL_COUNT+1))

    fi

}

###############################################################################
# Java Process
###############################################################################

validate_processes() {

    log_info "Checking Java Processes"

    check_service NameNode
    check_service DataNode
    check_service SecondaryNameNode
    check_service ResourceManager
    check_service NodeManager
    check_service JobHistoryServer

}

###############################################################################
# HDFS
###############################################################################

validate_hdfs() {

    log_info "Checking HDFS"

    if "${HADOOP_HOME}/bin/hdfs" dfs -ls / >/dev/null 2>&1
    then

        log_info "HDFS : OK"

        PASS_COUNT=$((PASS_COUNT+1))

    else

        log_error "HDFS : FAILED"

        FAIL_COUNT=$((FAIL_COUNT+1))

    fi

}

###############################################################################
# YARN
###############################################################################

validate_yarn() {

    log_info "Checking YARN"

    if "${HADOOP_HOME}/bin/yarn" node -list >/dev/null 2>&1
    then

        log_info "YARN : OK"

        PASS_COUNT=$((PASS_COUNT+1))

    else

        log_error "YARN : FAILED"

        FAIL_COUNT=$((FAIL_COUNT+1))

    fi

}

###############################################################################
# Hive
###############################################################################

validate_hive() {

    log_info "Checking Hive"

    if pgrep -f HiveMetaStore >/dev/null
    then

        log_info "Hive Metastore : OK"

        PASS_COUNT=$((PASS_COUNT+1))

    else

        log_error "Hive Metastore : FAILED"

        FAIL_COUNT=$((FAIL_COUNT+1))

    fi

}

###############################################################################
# Spark
###############################################################################

validate_spark() {

    log_info "Checking Spark"

    if pgrep -f HistoryServer >/dev/null
    then

        log_info "Spark History Server : OK"

        PASS_COUNT=$((PASS_COUNT+1))

    else

        log_error "Spark History Server : FAILED"

        FAIL_COUNT=$((FAIL_COUNT+1))

    fi

}

###############################################################################
# Report
###############################################################################

validation_report() {

    echo
    echo "========================================================="
    echo "Validation Summary"
    echo "========================================================="
    echo
    echo "Passed : ${PASS_COUNT}"
    echo "Failed : ${FAIL_COUNT}"
    echo

    if [ "${FAIL_COUNT}" -gt 0 ]
    then

        log_error "Validation FAILED"

        exit 1

    fi

    log_info "Validation PASSED"

}

###############################################################################
# Main
###############################################################################

main() {

    log_info "Running validation"

    load_environment

    validate_processes

    validate_hdfs

    validate_yarn

    validate_hive

    validate_spark

    validation_report

}

main "$@"