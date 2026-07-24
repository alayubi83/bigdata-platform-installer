#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Hadoop Installer
#
# Hadoop 3.2.4
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

    log_info "Preparing Hadoop directory"


    mkdir -p ${INSTALL_ROOT}


    mkdir -p ${HDFS_NAME_DIR}
    mkdir -p ${HDFS_DATA_DIR}


    chown -R ${INSTALL_USER}:${INSTALL_GROUP} \
        ${INSTALL_ROOT}


    chown -R ${INSTALL_USER}:${INSTALL_GROUP} \
        /data/hdfs

}



###############################################################################
# Download Hadoop
###############################################################################

download_hadoop(){

    FILE_NAME=$(basename ${HADOOP_URL})


    if [ -f "${BASE_DIR}/${DOWNLOAD_DIR}/${FILE_NAME}" ]
    then

        log_info "Hadoop package already exists"

    else

        log_info "Downloading Hadoop ${HADOOP_VERSION}"


        mkdir -p ${BASE_DIR}/${DOWNLOAD_DIR}

        wget \
        -c \
        --tries=20 \
        --timeout=60 \
        -O "${BASE_DIR}/${DOWNLOAD_DIR}/${FILE_NAME}" \
        "${HADOOP_URL}"

    fi

}



###############################################################################
# Install Hadoop
###############################################################################

install_hadoop(){


    if [ -d "${HADOOP_HOME}" ]
    then

        log_warn "Hadoop already installed"

        return

    fi



    log_info "Extract Hadoop"


    tar -xzf \
    ${BASE_DIR}/${DOWNLOAD_DIR}/$(basename ${HADOOP_URL}) \
    -C ${INSTALL_ROOT}



    mv \
    ${INSTALL_ROOT}/hadoop-${HADOOP_VERSION} \
    ${HADOOP_HOME}



    chown -R \
    ${INSTALL_USER}:${INSTALL_GROUP} \
    ${HADOOP_HOME}


}



###############################################################################
# Configure Hadoop
###############################################################################

configure_hadoop(){


log_info "Configuring Hadoop"


cat > ${HADOOP_CONF_DIR}/core-site.xml <<EOF
<?xml version="1.0"?>

<configuration>

<property>
<name>fs.defaultFS</name>
<value>hdfs://localhost:${NAMENODE_RPC_PORT}</value>
</property>

</configuration>
EOF



cat > ${HADOOP_CONF_DIR}/hdfs-site.xml <<EOF
<?xml version="1.0"?>

<configuration>


<property>
<name>dfs.replication</name>
<value>1</value>
</property>


<property>
<name>dfs.namenode.name.dir</name>
<value>file:${HDFS_NAME_DIR}</value>
</property>


<property>
<name>dfs.datanode.data.dir</name>
<value>file:${HDFS_DATA_DIR}</value>
</property>


</configuration>
EOF



cat > ${HADOOP_CONF_DIR}/mapred-site.xml <<EOF
<?xml version="1.0"?>

<configuration>

<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>

</configuration>
EOF



cat > ${HADOOP_CONF_DIR}/yarn-site.xml <<EOF
<?xml version="1.0"?>

<configuration>


<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>


</configuration>
EOF



}



###############################################################################
# Environment
###############################################################################

configure_environment(){


log_info "Configuring Hadoop environment"



cat >> ${HADOOP_CONF_DIR}/hadoop-env.sh <<EOF

export JAVA_HOME=${JAVA_HOME}

EOF


}



###############################################################################
# Format NameNode
###############################################################################

format_namenode(){


if [ -d "${HDFS_NAME_DIR}/current" ]
then

    log_info "NameNode already formatted"

else

    log_info "Formatting NameNode"


    sudo -u ${INSTALL_USER} \
    ${HADOOP_HOME}/bin/hdfs namenode -format -force

fi


}



###############################################################################
# Main
###############################################################################

main(){


log_info "Installing Hadoop ${HADOOP_VERSION}"


prepare_directory

download_hadoop

install_hadoop

configure_hadoop

configure_environment

format_namenode


log_info "Hadoop installation completed"


}


main "$@"
