#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "${BASE_DIR}/scripts/config.sh"

echo
echo "===== CONFIGURATION ====="
echo

echo "Hadoop     : ${HADOOP_VERSION}"
echo "Hive        : ${HIVE_VERSION}"
echo "Spark       : ${SPARK_VERSION}"
echo "Java        : ${JAVA_PACKAGE}"

echo
echo "Installer User : ${INSTALL_USER}"
echo "Group          : ${INSTALL_GROUP}"

echo
echo "PostgreSQL"

echo "Host : ${POSTGRES_HOST}"
echo "Port : ${POSTGRES_PORT}"
echo "DB   : ${POSTGRES_DATABASE}"
echo "User : ${POSTGRES_USER}"

echo
echo "Configuration loaded successfully."
