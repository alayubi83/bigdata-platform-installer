#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Environment Library
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${BASE_DIR}/config/version.conf"
source "${BASE_DIR}/config/installer.conf"
source "${BASE_DIR}/config/cluster.conf"

###############################################################################
# Environment File
###############################################################################

PROFILE_FILE="/etc/profile.d/bigdata.sh"

###############################################################################
# Header
###############################################################################

initialize_environment() {

cat > "${PROFILE_FILE}" <<'EOF'
#!/bin/bash

# ==========================================================
# Big Data Platform Environment
# Generated Automatically
# ==========================================================

EOF

chmod 755 "${PROFILE_FILE}"

}

###############################################################################
# Helper
###############################################################################

append_env() {

    local KEY="$1"
    local VALUE="$2"

    grep -q "^export ${KEY}=" "${PROFILE_FILE}" 2>/dev/null && return

    echo "export ${KEY}=${VALUE}" >> "${PROFILE_FILE}"

}

append_path() {

    local VALUE="$1"

    grep -q "${VALUE}" "${PROFILE_FILE}" 2>/dev/null && return

    echo "export PATH=${VALUE}:\$PATH" >> "${PROFILE_FILE}"

}

###############################################################################
# Java
###############################################################################

set_java_env() {

    append_env JAVA_HOME "/opt/bigdata/java"

    append_path "\$JAVA_HOME/bin"

}

###############################################################################
# Hadoop
###############################################################################

set_hadoop_env() {

    append_env HADOOP_HOME "/opt/bigdata/hadoop"

    append_env HADOOP_CONF_DIR "\$HADOOP_HOME/etc/hadoop"

    append_env HADOOP_COMMON_HOME "\$HADOOP_HOME"

    append_env HADOOP_HDFS_HOME "\$HADOOP_HOME"

    append_env HADOOP_MAPRED_HOME "\$HADOOP_HOME"

    append_env HADOOP_YARN_HOME "\$HADOOP_HOME"

    append_path "\$HADOOP_HOME/bin"

    append_path "\$HADOOP_HOME/sbin"

}

###############################################################################
# Hive
###############################################################################

set_hive_env() {

    append_env HIVE_HOME "/opt/bigdata/hive"

    append_path "\$HIVE_HOME/bin"

}

###############################################################################
# Spark
###############################################################################

set_spark_env() {

    append_env SPARK_HOME "/opt/bigdata/spark"

    append_env SPARK_CONF_DIR "\$SPARK_HOME/conf"

    append_path "\$SPARK_HOME/bin"

    append_path "\$SPARK_HOME/sbin"

}

###############################################################################
# Scala
###############################################################################

set_scala_env() {

    append_env SCALA_HOME "/opt/bigdata/scala"

    append_path "\$SCALA_HOME/bin"

}

###############################################################################
# Build
###############################################################################

build_environment() {

    initialize_environment

    set_java_env

    set_hadoop_env

    set_hive_env

    set_spark_env

    set_scala_env

}

###############################################################################
# Reload
###############################################################################

reload_environment() {

    source "${PROFILE_FILE}"

}

###############################################################################
# Validation
###############################################################################

validate_environment() {

    echo

    echo "============= ENVIRONMENT ============="

    echo

    env | grep HOME

    env | grep JAVA

    env | grep HADOOP

    env | grep HIVE

    env | grep SPARK

    env | grep SCALA

    echo

}

###############################################################################
# Main
###############################################################################

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    build_environment

    reload_environment

    validate_environment

fi
