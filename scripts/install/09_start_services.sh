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

load_environment(){


export JAVA_HOME=${JAVA_HOME}

export HADOOP_HOME=${HADOOP_HOME}

export HADOOP_CONF_DIR=${HADOOP_CONF_DIR}

export HIVE_HOME=${HIVE_HOME}

export SPARK_HOME=${SPARK_HOME}


export PATH=$PATH:${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${HIVE_HOME}/bin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin


}



###############################################################################
# Start HDFS
###############################################################################

start_hdfs(){


log_info "Starting HDFS"



sudo -u ${INSTALL_USER} \
${HADOOP_HOME}/sbin/start-dfs.sh



}



###############################################################################
# Start YARN
###############################################################################

start_yarn(){


log_info "Starting YARN"



sudo -u ${INSTALL_USER} \
${HADOOP_HOME}/sbin/start-yarn.sh



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



mkdir -p ${LOG_DIR}



nohup sudo -u ${INSTALL_USER} \
${HIVE_HOME}/bin/hive \
--service metastore \
> ${LOG_DIR}/hive-metastore.log 2>&1 &



}



###############################################################################
# Start Spark History Server
###############################################################################

start_spark_history(){


log_info "Starting Spark History Server"



mkdir -p ${LOG_DIR}



nohup sudo -u ${INSTALL_USER} \
${SPARK_HOME}/sbin/start-history-server.sh \
> ${LOG_DIR}/spark-history.log 2>&1 || true



}



###############################################################################
# Save Status
###############################################################################

save_status(){


log_info "Saving service status"



jps > ${LOG_DIR}/jps.log || true



}



###############################################################################
# Main
###############################################################################

main(){


log_info "Starting Big Data services"



load_environment


start_hdfs


start_yarn


start_history_server


start_hive_metastore


start_spark_history


save_status



log_info "All services started"


}



main "$@"
