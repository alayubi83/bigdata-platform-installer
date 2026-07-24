#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Hive Installer
#
# Hive 2.3.9
#
###############################################################################

set -e
set -o pipefail


BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"


source "${BASE_DIR}/scripts/common.sh"
source "${BASE_DIR}/scripts/config.sh"



###############################################################################
# Prepare Directory
###############################################################################

prepare_directory(){

    log_info "Preparing Hive directory"


    mkdir -p ${INSTALL_ROOT}


    chown -R ${INSTALL_USER}:${INSTALL_GROUP} \
    ${INSTALL_ROOT}

}



###############################################################################
# Download Hive
###############################################################################

download_hive(){


FILE_NAME=$(basename ${HIVE_URL})


mkdir -p ${BASE_DIR}/${DOWNLOAD_DIR}



if [ -f "${BASE_DIR}/${DOWNLOAD_DIR}/${FILE_NAME}" ]
then

    log_info "Hive package already exists"

else

    log_info "Downloading Hive ${HIVE_VERSION}"


    wget \
        -c \
        --tries=20 \
        --timeout=60 \
    -O ${BASE_DIR}/${DOWNLOAD_DIR}/${FILE_NAME} \
    ${HIVE_URL}


fi


}



###############################################################################
# Install Hive
###############################################################################

install_hive(){


if [ -d "${HIVE_HOME}" ]
then

    log_warn "Hive already installed"

    return

fi



log_info "Extract Hive"


tar -xzf \
${BASE_DIR}/${DOWNLOAD_DIR}/$(basename ${HIVE_URL}) \
-C ${INSTALL_ROOT}



mv \
${INSTALL_ROOT}/apache-hive-${HIVE_VERSION}-bin \
${HIVE_HOME}



chown -R \
${INSTALL_USER}:${INSTALL_GROUP} \
${HIVE_HOME}


}



###############################################################################
# PostgreSQL JDBC
###############################################################################

install_postgres_driver(){


log_info "Installing PostgreSQL JDBC driver"


JDBC_VERSION=42.6.0


JDBC_FILE=postgresql-${JDBC_VERSION}.jar


JDBC_URL=https://jdbc.postgresql.org/download/${JDBC_FILE}



mkdir -p ${HIVE_HOME}/lib



if [ ! -f "${HIVE_HOME}/lib/${JDBC_FILE}" ]
then


wget \
-O ${HIVE_HOME}/lib/${JDBC_FILE} \
${JDBC_URL}


fi



chown ${INSTALL_USER}:${INSTALL_GROUP} \
${HIVE_HOME}/lib/${JDBC_FILE}


}



###############################################################################
# Hive Environment
###############################################################################

configure_environment(){


log_info "Configuring Hive environment"



cat > ${HIVE_HOME}/conf/hive-env.sh <<EOF

export JAVA_HOME=${JAVA_HOME}

export HADOOP_HOME=${HADOOP_HOME}

export HIVE_HOME=${HIVE_HOME}

EOF



}



###############################################################################
# Hive Site Configuration
###############################################################################

configure_hive(){


log_info "Creating hive-site.xml"



cat > ${HIVE_HOME}/conf/hive-site.xml <<EOF

<?xml version="1.0"?>

<configuration>


<property>

<name>javax.jdo.option.ConnectionURL</name>

<value>jdbc:postgresql://${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DATABASE}</value>

</property>



<property>

<name>javax.jdo.option.ConnectionDriverName</name>

<value>org.postgresql.Driver</value>

</property>



<property>

<name>javax.jdo.option.ConnectionUserName</name>

<value>${POSTGRES_USER}</value>

</property>



<property>

<name>javax.jdo.option.ConnectionPassword</name>

<value>${POSTGRES_PASSWORD}</value>

</property>



<property>

<name>hive.metastore.warehouse.dir</name>

<value>/user/hive/warehouse</value>

</property>



<property>

<name>hive.execution.engine</name>

<value>mr</value>

</property>



<property>

<name>hive.server2.enable.doAs</name>

<value>false</value>

</property>



</configuration>

EOF



}



###############################################################################
# Environment Link
###############################################################################

configure_profile(){


cat > /etc/profile.d/hive.sh <<EOF

export HIVE_HOME=${HIVE_HOME}

export PATH=\$PATH:\${HIVE_HOME}/bin


EOF



}



###############################################################################
# Main
###############################################################################

main(){


log_info "Installing Hive ${HIVE_VERSION}"


prepare_directory

download_hive

install_hive

install_postgres_driver

configure_environment

configure_hive

configure_profile



log_info "Hive installation completed"



}



main "$@"
