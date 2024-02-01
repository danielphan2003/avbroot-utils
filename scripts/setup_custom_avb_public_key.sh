#! /usr/bin/env bash

PRJ_ROOT="$(pwd)"
TARGET=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --target)
            TARGET="$2"
            shift 2
            ;;
    esac
done

if [ -z "$TARGET" ]; then
    echo "Error: --target flag is required."
    exit 1
fi

fastboot erase avb_custom_key
fastboot flash avb_custom_key "$TARGET/avb_pkmd.bin"
