#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

sudo bash "${BASE_DIR}/scripts/environment.sh"

echo
echo "Environment test completed."
