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



REPORT_FILE="${BASE_DIR}/logs/install-report.txt"



###############################################################################
# Generate Report
###############################################################################

generate_report(){


log_info "Generating installation report"



cat > ${REPORT_FILE} <<EOF

============================================================
BIG DATA PLATFORM INSTALLATION REPORT
============================================================


Project
-------
${PROJECT_NAME}


Installation Directory
----------------------
${INSTALL_ROOT}


Versions
--------

Java
----
${JAVA_VERSION}


Hadoop
------
${HADOOP_VERSION}


Hive
----
${HIVE_VERSION}


Spark
-----
${SPARK_VERSION}


Scala
-----
${SCALA_VERSION}


PostgreSQL
----------
${POSTGRES_VERSION}



Configuration
-------------

Install User
------------
${INSTALL_USER}


Timezone
--------
${TIMEZONE}



Hadoop Web UI
-------------

NameNode
http://localhost:${NAMENODE_HTTP_PORT}


ResourceManager
http://localhost:${RM_WEB_PORT}


NodeManager
http://localhost:${NM_WEB_PORT}



MapReduce History Server
------------------------

http://localhost:${JOBHISTORY_WEB_PORT}



Spark History Server
--------------------

http://localhost:${SPARK_HISTORY_PORT}



Directories
-----------

Hadoop
${HADOOP_HOME}


Hive
${HIVE_HOME}


Spark
${SPARK_HOME}



============================================================
INSTALLATION FINISHED
============================================================


EOF



}



###############################################################################
# Display Summary
###############################################################################

display_summary(){


echo

echo "============================================================"

echo " BIG DATA PLATFORM INSTALLATION COMPLETED "

echo "============================================================"


echo

echo "Components:"

echo " Java        : ${JAVA_VERSION}"

echo " Hadoop      : ${HADOOP_VERSION}"

echo " Hive        : ${HIVE_VERSION}"

echo " Spark       : ${SPARK_VERSION}"

echo " PostgreSQL  : ${POSTGRES_VERSION}"


echo

echo "Installation:"

echo "${INSTALL_ROOT}"


echo

echo "Web Interface:"

echo "NameNode             : http://localhost:${NAMENODE_HTTP_PORT}"

echo "ResourceManager      : http://localhost:${RM_WEB_PORT}"

echo "NodeManager          : http://localhost:${NM_WEB_PORT}"

echo "HistoryServer        : http://localhost:${JOBHISTORY_WEB_PORT}"

echo "Spark History        : http://localhost:${SPARK_HISTORY_PORT}"


echo

echo "Report:"

echo "${REPORT_FILE}"


echo

echo "============================================================"


}



###############################################################################
# Main
###############################################################################

main(){


log_info "Finishing installation"


generate_report


display_summary


log_info "Big Data Platform Ready"



}



main "$@"
