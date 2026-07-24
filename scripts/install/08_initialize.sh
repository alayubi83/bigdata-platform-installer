#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Initialize Module
#
###############################################################################

set -e
set -o pipefail


BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"


source "${BASE_DIR}/scripts/common.sh"
source "${BASE_DIR}/scripts/config.sh"



###############################################################################
# Hadoop Initialize
###############################################################################

initialize_hadoop(){


log_info "Initializing Hadoop"



if [ ! -d "${HDFS_NAME_DIR}/current" ]
then


    log_info "Formatting NameNode"


    sudo -u ${INSTALL_USER} \
    ${HADOOP_HOME}/bin/hdfs namenode -format -force


else

    log_info "NameNode already initialized"


fi



}



###############################################################################
# HDFS Directory
###############################################################################

initialize_hdfs(){


log_info "Creating HDFS directories"



sudo -u ${INSTALL_USER} \
${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /tmp



sudo -u ${INSTALL_USER} \
${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/${INSTALL_USER}



sudo -u ${INSTALL_USER} \
${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/hive/warehouse



sudo -u ${INSTALL_USER} \
${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /spark-history



}



###############################################################################
# Hive Metastore
###############################################################################

initialize_hive(){


log_info "Initializing Hive Metastore"



SCHEMA_CHECK=$(
sudo -u postgres psql \
-d ${POSTGRES_DATABASE} \
-tAc "select count(*) from pg_tables where tablename='VERSION';" \
2>/dev/null || true
)



if [ "${SCHEMA_CHECK}" = "1" ]
then

    log_info "Hive schema already initialized"


else


    log_info "Initializing Hive schema"


    ${HIVE_HOME}/bin/schematool \
    -dbType postgres \
    -initSchema


fi



}



###############################################################################
# Spark History Directory
###############################################################################

initialize_spark(){


log_info "Preparing Spark history directory"



sudo -u ${INSTALL_USER} \
${HADOOP_HOME}/bin/hdfs dfs \
-mkdir -p /spark-history



sudo -u ${INSTALL_USER} \
${HADOOP_HOME}/bin/hdfs dfs \
-chmod 777 /spark-history



}



###############################################################################
# Permission
###############################################################################

fix_permission(){


log_info "Fixing permission"



chown -R \
${INSTALL_USER}:${INSTALL_GROUP} \
${INSTALL_ROOT}



chown -R \
${INSTALL_USER}:${INSTALL_GROUP} \
/data/hdfs



}

###############################################################################
# setup_passwordless_ssh
###############################################################################

setup_passwordless_ssh() {

log_info "Configuring passwordless SSH"

mkdir -p "${HOME}/.ssh"

chmod 700 "${HOME}/.ssh"

if [ ! -f "${HOME}/.ssh/id_rsa" ]; then

ssh-keygen -q \
-t rsa \
-b 4096 \
-N "" \
-f "${HOME}/.ssh/id_rsa"

fi

touch "${HOME}/.ssh/authorized_keys"

grep -qxF "$(cat ${HOME}/.ssh/id_rsa.pub)" \
"${HOME}/.ssh/authorized_keys" \
|| cat "${HOME}/.ssh/id_rsa.pub" >> "${HOME}/.ssh/authorized_keys"

chmod 600 "${HOME}/.ssh/authorized_keys"

ssh-keyscan -H localhost >> "${HOME}/.ssh/known_hosts" 2>/dev/null || true

ssh-keyscan -H "$(hostname)" >> "${HOME}/.ssh/known_hosts" 2>/dev/null || true

ssh -o BatchMode=yes localhost true

}



###############################################################################
# Main
###############################################################################

main(){


log_info "Starting initialization"

setup_passwordless_ssh

initialize_hadoop


initialize_hdfs


initialize_hive


initialize_spark


fix_permission



log_info "Initialization completed"


}



main "$@"
