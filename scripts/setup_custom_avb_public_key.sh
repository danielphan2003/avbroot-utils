#! /usr/bin/env bash

PRJ_ROOT="$(pwd)"
TARGET=""

[[ $# -eq 1 ]] || {
    echo "expected one argument: TARGET"
    exit 1
}

TARGET=$1

fastboot erase avb_custom_key
fastboot flash avb_custom_key "$TARGET/avb_pkmd.bin"
