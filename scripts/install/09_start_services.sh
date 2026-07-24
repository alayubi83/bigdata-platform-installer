#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Start Services Module
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
# Wait Process
###############################################################################

wait_process(){

    local PROCESS="$1"
    local RETRY=30

    while [ ${RETRY} -gt 0 ]
    do

        if jps | grep -q "${PROCESS}"; then

            log_info "${PROCESS} started."

            return 0

        fi

        sleep 2

        RETRY=$((RETRY-1))

    done

    log_error "${PROCESS} failed to start."

    exit 1

}


###############################################################################
# Start HDFS
###############################################################################

start_hdfs(){


log_info "Starting HDFS"



sudo -u "${INSTALL_USER}" \
"${HADOOP_HOME}/sbin/start-dfs.sh"



}



###############################################################################
# Start YARN
###############################################################################

start_yarn(){


log_info "Starting YARN"



sudo -u "${INSTALL_USER}" \
"${HADOOP_HOME}/sbin/start-yarn.sh"



}



###############################################################################
# Start History Server
###############################################################################

start_history_server(){


log_info "Starting MapReduce History Server"



sudo -u ${INSTALL_USER} \
${HADOOP_HOME}/bin/mapred \
--daemon start historyserver



}



###############################################################################
# Start Hive Metastore
###############################################################################

start_hive_metastore(){


log_info "Starting Hive Metastore"



mkdir -p "${LOG_DIR}"



nohup sudo -u "${INSTALL_USER}" \
"${HIVE_HOME}/bin/hive "\
--service metastore \
> ${LOG_DIR}/hive-metastore.log 2>&1 &



}



###############################################################################
# Start Spark History Server
###############################################################################

start_spark_history(){


log_info "Starting Spark History Server"



mkdir -p ${LOG_DIR}



nohup sudo -u "${INSTALL_USER}" \
"${SPARK_HOME}/sbin/start-history-server.sh" \
> ${LOG_DIR}/spark-history.log 2>&1 || true



}



###############################################################################
# Save Status
###############################################################################

save_status(){


log_info "Saving service status"

{

echo "======================================"
date
echo "======================================"

jps -l

} > "${LOG_DIR}/jps.log"

}

###############################################################################
# Initialize HDFS
###############################################################################

initialize_hdfs(){

    log_info "Initializing HDFS"

    ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /tmp

    ${HADOOP_HOME}/bin/hdfs dfs -chmod 1777 /tmp

    ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user

    ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/hive

    ${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/hive/warehouse

    ${HADOOP_HOME}/bin/hdfs dfs -chmod 777 /user/hive/warehouse

}

###############################################################################
# verify_ssh
###############################################################################

verify_ssh() {

    log_info "Checking passwordless SSH"

    sudo -u "${INSTALL_USER}" \
    ssh -o BatchMode=yes localhost "echo SSH OK" >/dev/null

}

###############################################################################
# wait_namenode
###############################################################################

wait_namenode() {

    log_info "Waiting NameNode"

    for i in {1..30}
    do

        jps | grep -q NameNode && return

        sleep 2

    done

    log_error "NameNode failed to start"

    exit 1

}

###############################################################################
# wait_yarn
###############################################################################

wait_yarn() {

    log_info "Waiting ResourceManager"

    for i in {1..30}
    do

        jps | grep -q ResourceManager && return

        sleep 2

    done

    log_error "ResourceManager failed"

    exit 1

}

###############################################################################
# start_hive_metastore
###############################################################################

start_hive_metastore() {

    log_info "Starting Hive Metastore"

    pgrep -f HiveMetaStore >/dev/null && return

    mkdir -p "${LOG_DIR}"

    nohup sudo -u "${INSTALL_USER}" \
        "${HIVE_HOME}/bin/hive" \
        --service metastore \
        > "${LOG_DIR}/hive-metastore.log" 2>&1 &

}

###############################################################################
# start_spark_history
###############################################################################

start_spark_history() {

    log_info "Starting Spark History Server"

    mkdir -p "${LOG_DIR}"

    nohup sudo -u "${INSTALL_USER}" \
        "${SPARK_HOME}/sbin/start-history-server.sh" \
        > "${LOG_DIR}/spark-history.log" 2>&1 || true

}

###############################################################################
# save_status
###############################################################################

save_status() {

    log_info "Saving service status"

    jps -l > "${LOG_DIR}/jps.log"

}

###############################################################################
# Main
###############################################################################

main() {

    log_info "Starting Big Data services"

    load_environment

    verify_ssh

    start_hdfs

    wait_namenode

    start_yarn

    wait_yarn

    start_history_server

    start_hive_metastore

    start_spark_history

    save_status

    log_info "All services started"

}



main "$@"
