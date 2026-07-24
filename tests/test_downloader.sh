
#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "${BASE_DIR}/scripts/downloader.sh"

download_all

echo
echo "Download test completed successfully."
