#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "${BASE_DIR}/scripts/template.sh"

render_all_templates

echo

echo "All templates rendered successfully."
