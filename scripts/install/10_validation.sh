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



RESULT=0


###############################################################################
# Check Command
###############################################################################

check_command(){

CMD=$1


if command -v ${CMD} >/dev/null 2>&1
then

    log_info "${CMD} OK"

else

    log_error "${CMD} not found"

    RESULT=1

fi


}



###############################################################################
# Java Validation
###############################################################################

validate_java(){


log_info "Checking Java"


if java -version >/dev/null 2>&1
then

    java -version

else

    log_error "Java failed"

    RESULT=1

fi


}



###############################################################################
# Hadoop Validation
###############################################################################

validate_hadoop(){


log_info "Checking Hadoop"



${HADOOP_HOME}/bin/hadoop version



if ${HADOOP_HOME}/bin/hdfs dfs -ls /
then

    log_info "HDFS OK"

else

    log_error "HDFS failed"

    RESULT=1

fi



}



###############################################################################
# YARN Validation
###############################################################################

validate_yarn(){


log_info "Checking YARN"



${HADOOP_HOME}/bin/yarn node -list



}



###############################################################################
# Hive Validation
###############################################################################

validate_hive(){


log_info "Checking Hive"



${HIVE_HOME}/bin/hive --version



}



###############################################################################
# Spark Validation
###############################################################################

validate_spark(){


log_info "Checking Spark"



${SPARK_HOME}/bin/spark-submit \
--version



}



###############################################################################
# PostgreSQL Validation
###############################################################################

validate_postgres(){


log_info "Checking PostgreSQL"



if systemctl is-active --quiet postgresql
then

    log_info "PostgreSQL running"

else

    log_error "PostgreSQL not running"

    RESULT=1

fi



}



###############################################################################
# Port Validation
###############################################################################

validate_ports(){


log_info "Checking ports"



PORTS=(

9870
8088
8042
19888
18080
9083

)



for PORT in "${PORTS[@]}"
do


if ss -lnt | grep -q ":${PORT}"
then

    log_info "Port ${PORT} OPEN"

else

    log_warn "Port ${PORT} CLOSED"

fi


done



}



###############################################################################
# Process Validation
###############################################################################

validate_process(){


log_info "Checking Java processes"



jps



}



###############################################################################
# Main
###############################################################################

main(){


log_info "Starting platform validation"



validate_java

validate_hadoop

validate_yarn

validate_hive

validate_spark

validate_postgres

validate_ports

validate_process



if [ ${RESULT} -eq 0 ]
then

    log_info "VALIDATION SUCCESS"

else

    log_error "VALIDATION FAILED"

fi



exit ${RESULT}



}



main "$@"
