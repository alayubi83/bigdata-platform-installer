#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sudo bash "${BASE_DIR}/scripts/install/03_postgresql.sh"

echo

echo "Testing PostgreSQL..."

PGPASSWORD=hive123 psql \
-h localhost \
-U hive \
-d metastore \
-c "SELECT version();"

echo

echo "PostgreSQL test passed."
