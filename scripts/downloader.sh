#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Downloader Library
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${BASE_DIR}/version.conf"
source "${BASE_DIR}/scripts/common.sh"

###############################################################################
# Download URL
###############################################################################

HADOOP_URL="https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"

HIVE_URL="https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz"

SPARK_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz"

###############################################################################
# Download Directory
###############################################################################

DOWNLOAD_DIR="${BASE_DIR}/downloads"

mkdir -p "${DOWNLOAD_DIR}"

###############################################################################
# Java
###############################################################################

download_java() {

    log_info "Java package must be copied manually."

}

###############################################################################
# Hadoop
###############################################################################

download_hadoop() {

    section "Download Hadoop"

    download_with_retry \
        "${HADOOP_URL}" \
        "${DOWNLOAD_DIR}/hadoop-${HADOOP_VERSION}.tar.gz"

}

###############################################################################
# Hive
###############################################################################

download_hive() {

    section "Download Hive"

    download_with_retry \
        "${HIVE_URL}" \
        "${DOWNLOAD_DIR}/apache-hive-${HIVE_VERSION}-bin.tar.gz"

}

###############################################################################
# Spark
###############################################################################

download_spark() {

    section "Download Spark"

    download_with_retry \
        "${SPARK_URL}" \
        "${DOWNLOAD_DIR}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz"

}

###############################################################################
# Download All
###############################################################################

download_all() {

    download_hadoop

    download_hive

    download_spark

    success "All packages downloaded."

}

###############################################################################

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    download_all

fi
