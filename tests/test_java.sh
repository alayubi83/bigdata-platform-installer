#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sudo bash "${BASE_DIR}/scripts/install/02_java.sh"

echo

java -version

echo

javac -version

echo

echo "JAVA_HOME=${JAVA_HOME}"

echo

readlink -f /opt/bigdata/java

echo

echo "Java test passed."
