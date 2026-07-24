#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Service Library
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${BASE_DIR}/scripts/common.sh"

###############################################################################
# PostgreSQL
###############################################################################

start_postgresql() {

    section "Start PostgreSQL"

    systemctl start postgresql

    wait_port_open localhost 5432

}

stop_postgresql() {

    section "Stop PostgreSQL"

    systemctl stop postgresql

}

restart_postgresql() {

    stop_postgresql

    start_postgresql

}

status_postgresql() {

    systemctl status postgresql --no-pager

}

###############################################################################
# Hadoop HDFS
###############################################################################

start_hdfs() {

    section "Start HDFS"

    start-dfs.sh

    wait_java_process NameNode

    wait_java_process DataNode

}

stop_hdfs() {

    section "Stop HDFS"

    stop-dfs.sh

}

status_hdfs() {

    jps

}

###############################################################################
# Hadoop YARN
###############################################################################

start_yarn() {

    section "Start YARN"

    start-yarn.sh

    wait_java_process ResourceManager

    wait_java_process NodeManager

}

stop_yarn() {

    section "Stop YARN"

    stop-yarn.sh

}

status_yarn() {

    jps

}

###############################################################################
# MapReduce History Server
###############################################################################

start_historyserver() {

    section "Start HistoryServer"

    mapred --daemon start historyserver

    wait_java_process JobHistoryServer

}

stop_historyserver() {

    section "Stop HistoryServer"

    mapred --daemon stop historyserver

}

###############################################################################
# Hive Metastore
###############################################################################

start_metastore() {

    section "Start Hive Metastore"

    nohup hive --service metastore \
        > /var/log/hive/metastore.log 2>&1 &

    wait_port_open localhost 9083

}

stop_metastore() {

    pkill -f HiveMetaStore || true

}

###############################################################################
# HiveServer2
###############################################################################

start_hiveserver2() {

    section "Start HiveServer2"

    nohup hiveserver2 \
        > /var/log/hive/hiveserver2.log 2>&1 &

    wait_port_open localhost 10000

}

stop_hiveserver2() {

    pkill -f HiveServer2 || true

}

###############################################################################
# Spark History Server
###############################################################################

start_spark_history() {

    section "Start Spark History"

    start-history-server.sh

    wait_port_open localhost 18080

}

stop_spark_history() {

    stop-history-server.sh

}

###############################################################################
# Start All
###############################################################################

start_all() {

    start_postgresql

    start_hdfs

    start_yarn

    start_historyserver

    start_metastore

    start_hiveserver2

    start_spark_history

}

###############################################################################
# Stop All
###############################################################################

stop_all() {

    stop_spark_history

    stop_hiveserver2

    stop_metastore

    stop_historyserver

    stop_yarn

    stop_hdfs

    stop_postgresql

}

###############################################################################
# Restart All
###############################################################################

restart_all() {

    stop_all

    start_all

}

###############################################################################
# Status
###############################################################################

status_all() {

    section "Java Process"

    jps

    echo

    section "Listening Port"

    ss -tln

}
