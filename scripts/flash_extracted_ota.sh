#! /usr/bin/env bash
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --patched-ota)
            PATCHED_OTA="$2"
            PATCHED_OTA_FILE_NAME="${PATCHED_OTA##*/}"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

if [ -z "$PATCHED_OTA" ]; then
    echo "Error: --patched-ota flag is required."
    exit 1
fi

for image in extracted/$PATCHED_OTA_FILE_NAME/*.img; do
    partition=$(basename "${image}")
    partition=${partition%.img}

    fastboot flash "${partition}" "${image}"
done

