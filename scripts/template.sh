#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Template Engine
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

###############################################################################
# Load Configuration
###############################################################################

source "${BASE_DIR}/scripts/config.sh"

###############################################################################
# Render Template
###############################################################################

render_template() {

    local TEMPLATE="$1"
    local OUTPUT="$2"

    [ -f "${TEMPLATE}" ] || {
        echo "Template not found : ${TEMPLATE}"
        return 1
    }

    mkdir -p "$(dirname "${OUTPUT}")"

    cp "${TEMPLATE}" "${OUTPUT}"

    while IFS='=' read -r KEY VALUE
    do

        [[ "${KEY}" =~ ^# ]] && continue
        [[ -z "${KEY}" ]] && continue

        VALUE="${VALUE%\"}"
        VALUE="${VALUE#\"}"

        sed -i \
"s|{{${KEY}}}|${VALUE}|g" \
"${OUTPUT}"

    done < <(

        cat \
            "${BASE_DIR}/version.conf" \
            "${BASE_DIR}/config/installer.conf" \
            "${BASE_DIR}/config/cluster.conf" \
            "${BASE_DIR}/config/download.conf" \
            "${BASE_DIR}/config/environment.conf"

    )

}

###############################################################################
# Hadoop Template
###############################################################################

render_core_site() {

    render_template \
        "${BASE_DIR}/templates/hadoop/core-site.xml.tpl" \
        "/opt/bigdata/hadoop/etc/hadoop/core-site.xml"

}

render_hdfs_site() {

    render_template \
        "${BASE_DIR}/templates/hadoop/hdfs-site.xml.tpl" \
        "/opt/bigdata/hadoop/etc/hadoop/hdfs-site.xml"

}

render_mapred_site() {

    render_template \
        "${BASE_DIR}/templates/hadoop/mapred-site.xml.tpl" \
        "/opt/bigdata/hadoop/etc/hadoop/mapred-site.xml"

}

render_yarn_site() {

    render_template \
        "${BASE_DIR}/templates/hadoop/yarn-site.xml.tpl" \
        "/opt/bigdata/hadoop/etc/hadoop/yarn-site.xml"

}

render_workers() {

    render_template \
        "${BASE_DIR}/templates/hadoop/workers.tpl" \
        "/opt/bigdata/hadoop/etc/hadoop/workers"

}

render_hadoop_env() {

    render_template \
        "${BASE_DIR}/templates/hadoop/hadoop-env.sh.tpl" \
        "/opt/bigdata/hadoop/etc/hadoop/hadoop-env.sh"

}

render_hive_site() {

    render_template \
        "${BASE_DIR}/templates/hive/hive-site.xml.tpl" \
        "/opt/bigdata/hive/conf/hive-site.xml"

}

render_spark_env() {

    render_template \
        "${BASE_DIR}/templates/spark/spark-env.sh.tpl" \
        "/opt/bigdata/spark/conf/spark-env.sh"

}

render_spark_defaults() {

    render_template \
        "${BASE_DIR}/templates/spark/spark-defaults.conf.tpl" \
        "/opt/bigdata/spark/conf/spark-defaults.conf"

}

render_all_templates() {

    render_core_site

    render_hdfs_site

    render_mapred_site

    render_yarn_site

    render_workers

    render_hadoop_env

    render_hive_site

    render_spark_env

    render_spark_defaults

}
