#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Spark Installer
#
# Spark 2.4.8
#
###############################################################################

set -e
set -o pipefail


BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"


source "${BASE_DIR}/scripts/common.sh"
source "${BASE_DIR}/scripts/config.sh"



###############################################################################
# Prepare
###############################################################################

prepare_directory(){

    log_info "Preparing Spark directory"


    mkdir -p ${INSTALL_ROOT}


    chown -R ${INSTALL_USER}:${INSTALL_GROUP} \
    ${INSTALL_ROOT}

}



###############################################################################
# Download Spark
###############################################################################

download_spark(){


FILE_NAME=$(basename ${SPARK_URL})


mkdir -p ${BASE_DIR}/${DOWNLOAD_DIR}



if [ -f "${BASE_DIR}/${DOWNLOAD_DIR}/${FILE_NAME}" ]
then

    log_info "Spark package already exists"

else

    log_info "Downloading Spark ${SPARK_VERSION}"


    wget \
    -O ${BASE_DIR}/${DOWNLOAD_DIR}/${FILE_NAME} \
    ${SPARK_URL}


fi


}



###############################################################################
# Install Spark
###############################################################################

install_spark(){


if [ -d "${SPARK_HOME}" ]
then

    log_warn "Spark already installed"

    return

fi



log_info "Extract Spark"



tar -xzf \
${BASE_DIR}/${DOWNLOAD_DIR}/$(basename ${SPARK_URL}) \
-C ${INSTALL_ROOT}



mv \
${INSTALL_ROOT}/spark-${SPARK_VERSION}-bin-without-hadoop \
${SPARK_HOME}



chown -R \
${INSTALL_USER}:${INSTALL_GROUP} \
${SPARK_HOME}



}



###############################################################################
# Spark Environment
###############################################################################

configure_environment(){


log_info "Creating spark-env.sh"



cat > ${SPARK_CONF_DIR}/spark-env.sh <<EOF


export JAVA_HOME=${JAVA_HOME}


export HADOOP_HOME=${HADOOP_HOME}


export HADOOP_CONF_DIR=${HADOOP_CONF_DIR}


export SPARK_HOME=${SPARK_HOME}



export SPARK_HISTORY_OPTS="
-Dspark.history.fs.logDirectory=hdfs:///spark-history
-Dspark.history.ui.port=${SPARK_HISTORY_PORT}
"


EOF



}



###############################################################################
# Spark Defaults
###############################################################################

configure_defaults(){


log_info "Creating spark-defaults.conf"



cat > ${SPARK_CONF_DIR}/spark-defaults.conf <<EOF


spark.master yarn


spark.submit.deployMode client


spark.eventLog.enabled true


spark.eventLog.dir hdfs:///spark-history


spark.history.fs.logDirectory hdfs:///spark-history



spark.sql.catalogImplementation hive



spark.hadoop.hive.metastore.uris thrift://${POSTGRES_HOST}:9083

spark.hadoop.fs.defaultFS hdfs://localhost:${NAMENODE_RPC_PORT}

spark.executor.memory 1g


spark.driver.memory 1g



EOF


}



###############################################################################
# Hive Integration
###############################################################################

configure_hive_link(){


log_info "Linking Hive configuration"



if [ -f "${HIVE_HOME}/conf/hive-site.xml" ]
then


cp \
${HIVE_HOME}/conf/hive-site.xml \
${SPARK_CONF_DIR}/



fi



}



###############################################################################
# Profile
###############################################################################

configure_profile(){


cat > /etc/profile.d/spark.sh <<EOF


export SPARK_HOME=${SPARK_HOME}


export PATH=\$PATH:\${SPARK_HOME}/bin:\${SPARK_HOME}/sbin



EOF


}



###############################################################################
# Main
###############################################################################

main(){


log_info "Installing Spark ${SPARK_VERSION}"



prepare_directory


download_spark


install_spark


configure_environment


configure_defaults


configure_hive_link


configure_profile



log_info "Spark installation completed"


}



main "$@"
