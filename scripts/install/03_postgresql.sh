#!/bin/bash

###############################################################################
#
# Big Data Platform Installer
#
# Module : 03 PostgreSQL
#
###############################################################################

set -e
set -o pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "${BASE_DIR}/version.conf"
source "${BASE_DIR}/scripts/common.sh"

###############################################################################
# Install PostgreSQL
###############################################################################

install_postgresql() {

    section "Install PostgreSQL"

    if command -v psql >/dev/null 2>&1; then
        log_info "PostgreSQL already installed."
        return
    fi

    apt-get update

    apt-get install -y \
        postgresql \
        postgresql-client \
        postgresql-contrib

}

###############################################################################
# Enable Service
###############################################################################

enable_postgresql() {

    section "Enable PostgreSQL"

    systemctl enable postgresql

    systemctl start postgresql

}

###############################################################################
# Wait Service
###############################################################################

wait_postgresql() {

    section "Waiting PostgreSQL"

    wait_port_open localhost 5432

}

###############################################################################
# Create Hive User
###############################################################################

create_hive_user() {

    section "Create PostgreSQL User"

sudo -u postgres psql <<EOF

DO
\$BODY\$
BEGIN

IF NOT EXISTS (
SELECT
FROM pg_catalog.pg_roles
WHERE rolname='${POSTGRES_USER}'
)

THEN

CREATE ROLE ${POSTGRES_USER}
LOGIN
PASSWORD '${POSTGRES_PASSWORD}';

END IF;

END
\$BODY\$;

EOF

}

###############################################################################
# Create Database
###############################################################################

create_metastore_database() {

    section "Create Hive Metastore"

sudo -u postgres psql <<EOF

SELECT 'CREATE DATABASE ${POSTGRES_DATABASE} OWNER ${POSTGRES_USER}'
WHERE NOT EXISTS
(
SELECT FROM pg_database
WHERE datname='${POSTGRES_DATABASE}'
)\gexec

EOF

}

###############################################################################
# Grant Privilege
###############################################################################

grant_privilege() {

    section "Grant Privilege"

sudo -u postgres psql <<EOF

GRANT ALL PRIVILEGES
ON DATABASE ${POSTGRES_DATABASE}
TO ${POSTGRES_USER};

EOF

}

###############################################################################
# Configure PostgreSQL
###############################################################################

configure_postgresql() {

    section "Configure PostgreSQL"

    PG_VERSION=$(ls /etc/postgresql)

    CONF="/etc/postgresql/${PG_VERSION}/main/postgresql.conf"

    HBA="/etc/postgresql/${PG_VERSION}/main/pg_hba.conf"

    backup_file "${CONF}"
    backup_file "${HBA}"

    sed -i \
's/^#listen_addresses.*/listen_addresses='\''*'\''/' \
"${CONF}"

    if ! grep -q "^host.*${POSTGRES_DATABASE}" "${HBA}"
    then

cat >> "${HBA}" <<EOF

host    ${POSTGRES_DATABASE}    ${POSTGRES_USER}    127.0.0.1/32    md5
host    ${POSTGRES_DATABASE}    ${POSTGRES_USER}    ::1/128         md5

EOF

    fi

}

###############################################################################
# Restart
###############################################################################

restart_postgresql() {

    section "Restart PostgreSQL"

    systemctl restart postgresql

}

###############################################################################
# Validation
###############################################################################

validate_postgresql() {

    section "Validate PostgreSQL"

    sudo -u postgres psql -c "\l"

    PGPASSWORD="${POSTGRES_PASSWORD}" \
    psql \
        -h localhost \
        -U "${POSTGRES_USER}" \
        -d "${POSTGRES_DATABASE}" \
        -c "SELECT current_database();"

    success "PostgreSQL ready."

}

###############################################################################
# Summary
###############################################################################

finish_postgresql() {

    section "PostgreSQL Installation Complete"

    echo

    echo "Database : ${POSTGRES_DATABASE}"
    echo "User     : ${POSTGRES_USER}"
    echo "Host     : localhost"
    echo "Port     : 5432"

    echo

}

###############################################################################
# Main
###############################################################################

main() {

    install_postgresql

    enable_postgresql

    wait_postgresql

    create_hive_user

    create_metastore_database

    grant_privilege

    configure_postgresql

    restart_postgresql

    validate_postgresql

    finish_postgresql

}

main "$@"
