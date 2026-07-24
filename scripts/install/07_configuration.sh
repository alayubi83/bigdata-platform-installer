#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Configuration Module
#
###############################################################################

set -e
set -o pipefail


BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"


source "${BASE_DIR}/scripts/common.sh"
source "${BASE_DIR}/scripts/config.sh"



###############################################################################
# Hadoop Configuration
###############################################################################

configure_hadoop(){


log_info "Updating Hadoop configuration"



cat > ${HADOOP_CONF_DIR}/core-site.xml <<EOF
<?xml version="1.0"?>

<configuration>

<property>
<name>fs.defaultFS</name>
<value>hdfs://localhost:${NAMENODE_RPC_PORT}</value>
</property>


<property>
<name>hadoop.tmp.dir</name>
<value>/tmp/hadoop-${INSTALL_USER}</value>
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
<value>${HDFS_NAME_DIR}</value>
</property>


<property>
<name>dfs.datanode.data.dir</name>
<value>${HDFS_DATA_DIR}</value>
</property>


</configuration>
EOF



}



###############################################################################
# YARN Configuration
###############################################################################

configure_yarn(){


log_info "Updating YARN configuration"



cat > ${HADOOP_CONF_DIR}/yarn-site.xml <<EOF
<?xml version="1.0"?>

<configuration>


<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>



<property>
<name>yarn.resourcemanager.hostname</name>
<value>localhost</value>
</property>



<property>
<name>yarn.nodemanager.resource.memory-mb</name>
<value>4096</value>
</property>



</configuration>
EOF


}



###############################################################################
# MapReduce Configuration
###############################################################################

configure_mapreduce(){


log_info "Updating MapReduce configuration"



cat > ${HADOOP_CONF_DIR}/mapred-site.xml <<EOF
<?xml version="1.0"?>

<configuration>


<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>


<property>
<name>mapreduce.jobhistory.address</name>
<value>localhost:${JOBHISTORY_PORT}</value>
</property>


<property>
<name>mapreduce.jobhistory.webapp.address</name>
<value>localhost:${JOBHISTORY_WEB_PORT}</value>
</property>



</configuration>
EOF


}



###############################################################################
# Hive Configuration
###############################################################################

configure_hive(){


log_info "Updating Hive configuration"



cat >> ${HIVE_HOME}/conf/hive-site.xml <<EOF

EOF



}



###############################################################################
# Spark Configuration
###############################################################################

configure_spark(){


log_info "Updating Spark configuration"



cat >> ${SPARK_CONF_DIR}/spark-defaults.conf <<EOF


spark.yarn.historyServer.address localhost:${SPARK_HISTORY_PORT}


spark.sql.warehouse.dir /user/hive/warehouse


EOF



}



###############################################################################
# Environment
###############################################################################

configure_environment(){


log_info "Creating global environment"



cat > /etc/profile.d/bigdata.sh <<EOF


export JAVA_HOME=${JAVA_HOME}


export HADOOP_HOME=${HADOOP_HOME}

export HADOOP_CONF_DIR=${HADOOP_CONF_DIR}


export HIVE_HOME=${HIVE_HOME}


export SPARK_HOME=${SPARK_HOME}



export PATH=\$PATH:\${JAVA_HOME}/bin:\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin:\${HIVE_HOME}/bin:\${SPARK_HOME}/bin:\${SPARK_HOME}/sbin



EOF



}



###############################################################################
# Permission
###############################################################################

fix_permission(){


log_info "Fixing permissions"



chown -R \
${INSTALL_USER}:${INSTALL_GROUP} \
${INSTALL_ROOT}



chown -R \
${INSTALL_USER}:${INSTALL_GROUP} \
/data/hdfs



}



###############################################################################
# Main
###############################################################################

main(){


log_info "Applying platform configuration"



configure_hadoop


configure_yarn


configure_mapreduce


configure_hive


configure_spark


configure_environment


fix_permission



log_info "Configuration completed"


}



main "$@"
