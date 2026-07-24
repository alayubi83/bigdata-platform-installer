#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "${BASE_DIR}/scripts/validator.sh"

run_validation

echo
echo "Validator test completed successfully."
