#!/bin/bash

set -e

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

source "${BASE_DIR}/scripts/common.sh"

banner

echo
echo "========== TEST COMMON.SH =========="

section "Logging"

log_info "Info message"
log_warn "Warning message"
log_success "Success message"

echo
section "Output"

info "Info"
warn "Warning"
success "Success"

echo
section "CPU"

check_cpu

echo
section "Memory"

check_memory

echo
section "Disk"

check_disk

echo
section "Internet"

check_internet

echo
section "Command"

if command_exists curl; then
    success "curl found"
else
    error "curl not found"
fi

echo
section "Retry"

COUNT=0

dummy_command() {

    COUNT=$((COUNT+1))

    if [ "$COUNT" -lt 3 ]; then
        return 1
    fi

    return 0
}

retry dummy_command

success "Retry works"

echo
section "Progress"

for i in $(seq 1 100)
do
    progress "$i" 100
    sleep 0.02
done

echo

echo
section "Spinner"

(
sleep 5
) &

spinner $!

success "Spinner works"

echo
section "Directory"

create_directory /tmp/bigdata_test

if [ -d /tmp/bigdata_test ]; then
    success "Directory created"
else
    error "Directory failed"
fi

echo
section "Backup"

echo hello >/tmp/test.txt

backup_file /tmp/test.txt

if [ -f /tmp/test.txt.bak ]; then
    success "Backup OK"
else
    error "Backup failed"
fi

echo
section "Append"

append_if_missing /tmp/test.txt "world"

cat /tmp/test.txt

echo
section "Finish"

success "ALL TEST PASSED"
